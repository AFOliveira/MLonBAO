FILE1 = basicmath_small.c rad2deg.c cubic.c isqrt.c
FILE2 = basicmath_large.c rad2deg.c cubic.c isqrt.c

SUITE = automotive
BENCHMARK = basicmath
OUTPUT_DIR = /home/afonso/evaluation-guests/benchmarks/linux_iPerf/mibench/build/mibench/automotive/basicmath
CC = $(CROSS_COMPILE)gcc

all: basicmath_small basicmath_large files

$(shell mkdir -p $(OUTPUT_DIR))

files:
	if [ -n "$$(ls -A ./*.dat 2>/dev/null)" ]; then cp ./*.dat $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.pgm 2>/dev/null)" ]; then cp ./*.pgm $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.sh 2>/dev/null)" ]; then cp ./*.sh $(OUTPUT_DIR); fi

basicmath_small: ${FILE1} Makefile
	$(CC) -static -O3 ${FILE1} -o $(OUTPUT_DIR)/basicmath_small -lm
basicmath_large: ${FILE2} Makefile
	$(CC) -static -O3 ${FILE2} -o $(OUTPUT_DIR)/basicmath_large -lm

clean:
	rm -rf basicmath_small basicmath_large output*
