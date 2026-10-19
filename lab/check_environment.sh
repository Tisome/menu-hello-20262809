#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=C.UTF-8
mkdir -p build runtime logs screenshots output
printf '=== WSL host ===\n'
uname -a
cat /etc/os-release
for tool in gcc make git python3 cpio gzip qemu-system-x86_64 file readelf sha256sum dpkg-deb; do
    command -v "$tool" >/dev/null || { printf 'Missing: %s\n' "$tool"; exit 1; }
done
printf '\n=== Tool versions ===\n'
gcc --version | head -n 1
make --version | head -n 1
qemu-system-x86_64 --version | head -n 1
git --version
printf 'int main(void) { return 0; }\n' > build/compiler_probe.c
gcc -m32 -static -pthread build/compiler_probe.c -o build/compiler_probe
file build/compiler_probe
if readelf -l build/compiler_probe | grep -q INTERP; then
    printf 'ERROR: probe is dynamically linked.\n'; exit 1
fi
printf '\n32-bit static compilation: PASS\n'
if [[ -s runtime/bzImage ]]; then
    file runtime/bzImage
    sha256sum runtime/bzImage
else
    printf 'Kernel not downloaded yet: bash lab/prepare_kernel.sh\n'
fi
