#!/bin/bash

/home/afonso/baopi/wrkdir/src/qemu/build/qemu-system-aarch64 \
    -nographic \
    -machine virt,secure=on, \
    -machine gic-version=3 \
    -machine virtualization=on \
    -cpu cortex-a53 \
    -smp 4 \
    -m 4G \
    -bios bl1.bin \
    -semihosting-config enable=on,target=native \
    -device virtio-serial-device -chardev pty,id=serial3 -device virtconsole,chardev=serial3
