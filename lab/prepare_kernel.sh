#!/usr/bin/env bash
# Downloads/extracts a distribution kernel for QEMU; does not install it in WSL.
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=C.UTF-8
mkdir -p runtime/kernel-package
if [[ -s runtime/bzImage && -s runtime/kernel-source.txt ]]; then
    printf 'Reusing recorded QEMU kernel:\n'
    cat runtime/kernel-source.txt
    sha256sum runtime/bzImage
    exit 0
fi
package="${KERNEL_PACKAGE:-$(apt-cache depends linux-image-generic | awk '$1=="Depends:" && $2 ~ /^linux-image-[0-9]/ { print $2; exit }')}"
[[ "$package" =~ ^linux-image-[0-9][A-Za-z0-9.+-]*-generic$ ]] || {
    printf 'Cannot determine an Ubuntu generic kernel package. Run sudo apt update first.\n'; exit 1;
}
metadata=$(apt-cache show "$package")
version=$(awk '/^Version:/ {print $2; exit}' <<< "$metadata")
expected=$(awk '/^SHA256:/ {print $2; exit}' <<< "$metadata")
filename=$(awk '/^Filename:/ {print $2; exit}' <<< "$metadata")
[[ -n "$version" && "$expected" =~ ^[0-9a-f]{64}$ && -n "$filename" ]]
(
    cd runtime/kernel-package
    apt-get download "${package}=${version}"
)
archive="runtime/kernel-package/${filename##*/}"
printf '%s  %s\n' "$expected" "$archive" | sha256sum -c -
mkdir -p runtime/kernel-extracted
dpkg-deb -x "$archive" runtime/kernel-extracted
image=$(find runtime/kernel-extracted/boot -maxdepth 1 -type f -name 'vmlinuz-*' -print -quit)
[[ -n "$image" ]] || { printf 'No vmlinuz in the downloaded package.\n'; exit 1; }
cp "$image" runtime/bzImage
config=$(find runtime/kernel-extracted/boot -maxdepth 1 -type f -name 'config-*' -print -quit)
if [[ -n "$config" ]]; then
    cp "$config" runtime/kernel.config
    grep -E '^CONFIG_(IA32_EMULATION|BINFMT_ELF|BLK_DEV_INITRD|RD_GZIP|SERIAL_8250_CONSOLE)=' runtime/kernel.config || true
fi
{
    printf 'Package: %s\nVersion: %s\nRepository path: %s\nPackage SHA256: %s\n' "$package" "$version" "$filename" "$expected"
    printf 'Prepared at: %s\n' "$(TZ=Asia/Shanghai date --iso-8601=seconds)"
    printf 'Kernel SHA256: '
    sha256sum runtime/bzImage
    printf 'Use: QEMU guest only; the WSL kernel has not been replaced.\n'
} | tee runtime/kernel-source.txt
