#include <common.h>

#define RINGBUF_SIZE 10

typedef struct ringbuf_node{
	vaddr_t pc, snpc;
	uint8_t *inst;
} ringbuf_node;
ringbuf_node ringbuf[RINGBUF_SIZE];
int start = 0, end = 0;

void record_ringbuf(vaddr_t pc, vaddr_t snpc, uint8_t *inst) {
	end = (end + 1) % RINGBUF_SIZE;
	if (start == end) 
		start = (start + 1) % RINGBUF_SIZE;
	ringbuf[end].pc = pc;
	ringbuf[end].snpc = snpc;
	ringbuf[end].inst = inst;
}

void display_ringbuf(){
	while (start != end) {
		start = (start + 1) % RINGBUF_SIZE;
		if (start == end) 
			printf("--> ");
		vaddr_t pc = ringbuf[end].pc;
		vaddr_t snpc = ringbuf[end].snpc;
		uint8_t *inst = ringbuf[end].inst;
		char buf[128] = {'\0'};
		char *p = buf;
		p += snprintf(p, sizeof(buf), FMT_WORD ":", pc);
		int ilen = snpc - pc;
		for (int i = ilen - 1; i >= 0; i--)
			p += snprintf(p, 4, " %02x", inst[i]);
		int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
		int space_len = ilen_max - ilen;
		if (space_len < 0) space_len = 0;
		space_len = space_len * 3 + 1;
		memset(p, ' ', space_len);
		p += space_len;
	
		void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
		disassemble(p, buf + sizeof(buf) - p,
			MUXDEF(CONFIG_ISA_x86, snpc, pc), inst, ilen);
		printf("    %s\n", buf);
	}
}
