# SUBDIRS = basicmath bitcount qsort susan

# .PHONY: subdirs $(SUBDIRS)

# subdirs: $(SUBDIRS)

# $(SUBDIRS):
# 	$(MAKE) -C $@


dir_list = $(patsubst %/,%,$(dir $(wildcard $(1)/*/.)))

ROOT_DIR:=$(realpath .)

OUT_DIR = $(ROOT_DIR)/build/mibench
SUITES:=automotive
benchmarks:=$(foreach suite,$(SUITES),$(wildcard $(suite)/*/Makefile) $(wildcard $(suite)/*/src/Makefile))
benchmarks:=$(dir $(benchmarks))
INSTALL_DIR:=_install
INSTALL_DIR:=$(abspath $(INSTALL_DIR))
export

all: $(benchmarks) update_rootfs

$(benchmarks):
	$(MAKE) -C $@ $(MAKECMDGOALS) INSTALL_DIR=$(INSTALL_DIR)/$@

install: | $(INSTALL_DIR)
	cp ./runme.sh $(INSTALL_DIR)

$(INSTALL_DIR):
	mkdir -p $@

update_rootfs:
	$(shell mkdir -p $(OUT_DIR))
	cp ./run_all.sh $(OUT_DIR)/run_all.sh

.PHONY: all $(benchmarks)


