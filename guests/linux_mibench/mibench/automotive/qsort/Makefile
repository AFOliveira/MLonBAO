FILE1 = qsort_small.c
FILE2 = qsort_large.c

SUITE = automotive
BENCHMARK = qsort
OUTPUT_DIR = $(OUT_DIR)/$(SUITE)/$(BENCHMARK)
CC = $(CROSS_COMPILE)gcc

all: qsort_small qsort_large files

$(shell mkdir -p $(OUTPUT_DIR))

files:
	if [ -n "$$(ls -A ./*.dat 2>/dev/null)" ]; then cp ./*.dat $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.pgm 2>/dev/null)" ]; then cp ./*.pgm $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.sh 2>/dev/null)" ]; then cp ./*.sh $(OUTPUT_DIR); fi

qsort_small: qsort_small.c Makefile
	$(CC) -static qsort_small.c -O3 -o $(OUTPUT_DIR)/qsort_small -lm
qsort_large: qsort_large.c Makefile
	$(CC) -static qsort_large.c -O3 -o $(OUTPUT_DIR)/qsort_large -lm

clean:
	rm -rf qsort_small qsort_large output*
