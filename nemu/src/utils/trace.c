#include <common.h>

//code of iringbuf
#define RINGBUF_SIZE 10

typedef struct ringbuf_node{
	vaddr_t pc, snpc;
	uint32_t inst;
} ringbuf_node;
ringbuf_node ringbuf[RINGBUF_SIZE];
int start = 0, end = 0;

void record_ringbuf(vaddr_t pc, vaddr_t snpc, uint32_t inst) {
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
		else printf("    ");
		vaddr_t pc = ringbuf[start].pc;
		vaddr_t snpc = ringbuf[start].snpc;
		uint8_t *inst = (uint8_t *)&ringbuf[start].inst;
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
		printf("%s\n", buf);
	}
}

//code of mtrace

#define MTRACE_SIZE 4096
#define MTRACE_ADDR_START 0x80000000
#define MTRACE_ADDR_END 0x87ffffff

typedef struct {
	paddr_t addr;
	int len;
	int type;
	word_t data;
} mtrace_node;
mtrace_node mtrace[MTRACE_SIZE];
int tail = 0;

void record_mtrace(paddr_t addr, int len, word_t data, int type) {
	Assert(tail < MTRACE_SIZE, "mtrace overflow");
	if (addr < MTRACE_ADDR_START || addr > MTRACE_ADDR_END)
		return;
	mtrace[tail].addr = addr;
	mtrace[tail].len = len;
	mtrace[tail].data = data;
	mtrace[tail].type = type;
	tail ++;
}

void display_mtrace() {
	for (int i = 0; i < tail; ++i) {
		if (mtrace[i].type == MEM_READ)
			printf("read ");
		else printf("write");
		printf(" addr: %#x, len: %d, data: %0#10x\n", mtrace[i].addr, mtrace[i].len, mtrace[i].data);
	}
}
