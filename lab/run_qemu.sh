#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -s runtime/bzImage && -s rootfs.img ]] || {
    printf 'First run: bash lab/prepare_kernel.sh && make -f Makefile.lab rootfs\n'; exit 1;
}
printf 'Starting QEMU guest. Type help, hello, version at the menu prompt.\n'
printf 'Exit: press Ctrl-a, release, then press x.\n'
exec qemu-system-x86_64 \
    -accel tcg -m 512M -smp 1 -nic none \
    -kernel runtime/bzImage -initrd rootfs.img \
    -append 'console=ttyS0,115200 rdinit=/init loglevel=3 panic=0' \
    -nographic -no-reboot
