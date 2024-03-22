#include <common.h>

#define RINGBUF_SIZE 10

char ringbuf[RINGBUF_SIZE][128];
int start = 0, end = 0;

void record_ringbuf(vaddr_t pc, vaddr_t snpc, uint8_t *inst) {
	end = (end + 1) % RINGBUF_SIZE;
	if (start == end) 
		start = (start + 1) % RINGBUF_SIZE;
	char *p = ringbuf[end];
	p += snprintf(p, sizeof(ringbuf[end]), FMT_WORD ":", pc);
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
	disassemble(p, ringbuf[end] + sizeof(ringbuf[end]) - p,
			MUXDEF(CONFIG_ISA_x86, snpc, pc), inst, ilen);
}

void display_ringbuf(){
	while (start != end) {
		start = (start + 1) % RINGBUF_SIZE;
		if (start == end) 
			printf("--> ");
		printf("    %s\n", ringbuf[start]);
	}
}
