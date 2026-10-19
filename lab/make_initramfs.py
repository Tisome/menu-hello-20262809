#!/usr/bin/env python3
"""Create a minimal gzip/newc initramfs, including console nodes without sudo.

Device nodes are encoded as archive metadata, not created on the Windows drive.
The archive's /init is the compiled menu program itself (PID 1 in the guest).
"""
from pathlib import Path
import gzip
import hashlib
import io
import stat

ROOT = Path(__file__).resolve().parent.parent


def main():
    stream = io.BytesIO()
    inode = 0

    def entry(name, mode, data=b"", major=0, minor=0):
        nonlocal inode
        inode += 1
        name_bytes = name.encode("utf-8") + b"\0"
        fields = (inode, mode, 0, 0, 2 if stat.S_ISDIR(mode) else 1,
                  0, len(data), 0, 0, major, minor, len(name_bytes), 0)
        header = b"070701" + b"".join(f"{v:08x}".encode("ascii") for v in fields)
        stream.write(header)
        stream.write(name_bytes)
        stream.write(b"\0" * (-stream.tell() % 4))
        stream.write(data)
        stream.write(b"\0" * (-stream.tell() % 4))

    entry(".", stat.S_IFDIR | 0o755)
    entry("dev", stat.S_IFDIR | 0o755)
    entry("dev/console", stat.S_IFCHR | 0o600, major=5, minor=1)
    entry("dev/null", stat.S_IFCHR | 0o666, major=1, minor=3)
    for name, binary in (("init", "menu"), ("hello", "hello")):
        data = (ROOT / "build" / binary).read_bytes()
        if data[:5] != b"\x7fELF\x01":
            raise SystemExit(f"{binary}: expected a 32-bit ELF; build with Makefile.lab")
        entry(name, stat.S_IFREG | 0o755, data)
    entry("TRAILER!!!", 0)
    destination = ROOT / "rootfs.img"
    with destination.open("wb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as out:
            out.write(stream.getvalue())
    print("Created rootfs.img (gzip-compressed newc initramfs)")
    print("Contents: /init (menu), /hello, /dev/console, /dev/null")
    print("SHA256:", hashlib.sha256(destination.read_bytes()).hexdigest())


if __name__ == "__main__":
    main()
