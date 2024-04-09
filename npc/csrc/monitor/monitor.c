#include <stdio.h>
#include <assert.h>
#include <memory.h>

static char *img_file = NULL;

static void load_img() {
	if (img_file == NULL) {
		printf("No image is given. Use the default build-in image.\n");
		return;
	}

	FILE *fp = fopen(img_file, "rb");
	assert(fp);

	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);

	fseek(fp, 0, SEEK_SET);
	int ret = fread(guest2host(MEM_BASE), size, 1, fp);
	assert(ret == 1);

	fclose(fp);
}

void init_monitor(int argc, char **argv) {
	if (argc > 0) img_file = argv[1];

	init_memory();

	load_img();
}
