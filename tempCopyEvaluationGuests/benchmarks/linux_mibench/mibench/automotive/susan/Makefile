FILE = susan.c 

SUITE = automotive
BENCHMARK = susan
OUTPUT_DIR = $(OUT_DIR)/$(SUITE)/$(BENCHMARK)
CC = $(CROSS_COMPILE)gcc

all: susan files

$(shell mkdir -p $(OUTPUT_DIR))

files:
	if [ -n "$$(ls -A ./*.dat 2>/dev/null)" ]; then cp ./*.dat $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.pgm 2>/dev/null)" ]; then cp ./*.pgm $(OUTPUT_DIR); fi
	if [ -n "$$(ls -A ./*.sh 2>/dev/null)" ]; then cp ./*.sh $(OUTPUT_DIR); fi

susan: ${FILE} Makefile
	$(CC) -static -O4 -o $(OUTPUT_DIR)/susan susan.c -lm 

clean:
	rm -rf susan output*
