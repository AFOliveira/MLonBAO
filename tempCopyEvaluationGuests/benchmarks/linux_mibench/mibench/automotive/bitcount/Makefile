FILE = bitcnt_1.c bitcnt_2.c bitcnt_3.c bitcnt_4.c bitcnts.c bitfiles.c bitstrng.c bstr_i.c 

SUITE = automotive
BENCHMARK = bitcount
OUTPUT_DIR = $(OUT_DIR)/$(SUITE)/$(BENCHMARK)
CC = $(CROSS_COMPILE)gcc

all: bitcnts files

$(shell mkdir -p $(OUTPUT_DIR))

files:
	if [ -n "$$(ls -A ./*.dat 2>/dev/null)" ]; then cp ./*.dat $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.pgm 2>/dev/null)" ]; then cp ./*.pgm $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.sh 2>/dev/null)" ]; then cp ./*.sh $(OUTPUT_DIR); fi

bitcnts: ${FILE} Makefile
	$(CC) -static ${FILE} -O3 -o $(OUTPUT_DIR)/bitcnts

clean:
	rm -rf bitcnts output*
