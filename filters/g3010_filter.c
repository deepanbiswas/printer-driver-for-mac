/*
 * CUPS filter stub (Iteration 1): consume job data and exit successfully.
 * Invocation: filter job user title copies options [filename]
 * If filename is missing or "-", read from stdin.
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int copy_stream(FILE *in) {
  unsigned char buf[8192];
  size_t n;
  while ((n = fread(buf, 1, sizeof(buf), in)) > 0) {
    /* discard — stub does not print */
  }
  if (ferror(in)) {
    return -1;
  }
  return 0;
}

int main(int argc, char *argv[]) {
  FILE *in = stdin;

  if (argc > 6) {
    const char *path = argv[6];
    if (path[0] != '\0' && strcmp(path, "-") != 0) {
      in = fopen(path, "rb");
      if (in == NULL) {
        fprintf(stderr, "g3010_filter: cannot open input: %s: %s\n", path, strerror(errno));
        return 1;
      }
    }
  }

  if (copy_stream(in) != 0) {
    fprintf(stderr, "g3010_filter: read error\n");
    if (in != stdin) {
      fclose(in);
    }
    return 1;
  }

  if (in != stdin) {
    fclose(in);
  }

  return 0;
}
