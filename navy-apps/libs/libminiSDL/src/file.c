#include <sdl-file.h>
#include <stdlib.h>

int64_t file_size (SDL_RWops *f);
int64_t file_seek (SDL_RWops *f, int64_t offset, int whence);
size_t  file_read (SDL_RWops *f, void *buf, size_t size, size_t nmemb);
size_t  file_write(SDL_RWops *f, const void *buf, size_t size, size_t nmemb);
int     file_close(SDL_RWops *f);

SDL_RWops* SDL_RWFromFile(const char *filename, const char *mode) {
	SDL_RWops *f = malloc(sizeof(SDL_RWops));
	f->fp    = fopen(filename, mode);
	f->size  = file_size;
	f->seek  = file_seek;
	f->read  = file_read;
	f->write = file_write;
	f->close = file_close;
	f->type  = RW_TYPE_FILE;
	f->mem.size = SDL_RWsize(f);
  return f;
}

SDL_RWops* SDL_RWFromMem(void *mem, int size) {
	SDL_RWops *f = malloc(sizeof(SDL_RWops));
	f->fp    = fmemopen(mem, size, "r+");
	f->size  = file_size;
	f->seek  = file_seek;
	f->read  = file_read;
	f->write = file_write;
	f->close = file_close;
	f->type  = RW_TYPE_MEM;
	f->mem.base = mem;
	f->mem.size = size;
  return f;
}

// file
int64_t file_size(SDL_RWops *f) {
	long current_offset = ftell(f->fp);
	fseek(f->fp, 0, SEEK_END);
	long size = ftell(f->fp);
	fseek(f->fp, current_offset, SEEK_SET);
	return size;
}

int64_t file_seek(SDL_RWops *f, int64_t offset, int whence) {
	return fseek(f->fp, offset, whence);
}

size_t file_read(SDL_RWops *f, void *buf, size_t size, size_t nmemb) {
	return fread(buf, size, nmemb, f->fp);
}

size_t file_write(SDL_RWops *f, const void *buf, size_t size, size_t nmemb) {
	return fwrite(buf, size, nmemb, f->fp);
}

int file_close(SDL_RWops *f) {
	return fclose(f->fp);
}
