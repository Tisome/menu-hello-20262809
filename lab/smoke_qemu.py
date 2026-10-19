#!/usr/bin/env python3
"""Actual automated QEMU precheck; it produces logs, never screenshots."""
from pathlib import Path
import os
import selectors
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    (ROOT / "logs").mkdir(exist_ok=True)
    process = subprocess.Popen(
        ["bash", "lab/run_qemu.sh"], cwd=ROOT,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    output = bytearray()
    commands = [b"help\n", b"hello\n", b"time\n", b"time-asm\n", b"quit\n"]
    sent = 0
    consumed_prompts = 0
    finished = False
    deadline = time.monotonic() + 100
    try:
        while time.monotonic() < deadline and process.poll() is None:
            for key, _ in selector.select(timeout=0.5):
                chunk = os.read(key.fd, 65536)
                if not chunk:
                    continue
                output.extend(chunk)
                sys.stdout.buffer.write(chunk)
                sys.stdout.buffer.flush()
            marker = output.find(b"| PID: 1")
            if marker < 0:
                continue
            prompts = output[marker:].count(b"MenuOS>>")
            if prompts > consumed_prompts:
                consumed_prompts = prompts
                if sent < len(commands):
                    process.stdin.write(commands[sent])
                    process.stdin.flush()
                    sent += 1
                elif b"hello 20262809" in output and b"PID 1 stays running." in output:
                    finished = True
                    break
        if finished:
            process.stdin.write(b"\x01x")
            process.stdin.flush()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.terminate()
        else:
            process.terminate()
    finally:
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        tail = process.stdout.read()
        if tail:
            output.extend(tail)
            sys.stdout.buffer.write(tail)
        selector.close()
        (ROOT / "logs" / "qemu-precheck.log").write_bytes(output)
    errors = []
    if not finished:
        errors.append("menu did not complete the expected interaction in time")
    if b"Kernel panic" in output:
        errors.append("guest kernel panic")
    if output.count(b"time:") < 2:
        errors.append("time and time-asm commands did not both return")
    if b"help - Menu List" not in output or b"* hello -" not in output:
        errors.append("help did not list the new hello command")
    if b"quit - Quit from MenuOS" not in output or b"PID 1 stays running." not in output:
        errors.append("quit did not preserve PID 1")
    if errors:
        raise SystemExit("\nQEMU precheck FAILED: " + "; ".join(errors))
    print("\nQEMU precheck PASS: guest PID 1, help, hello, time, time-asm and quit verified.")


if __name__ == "__main__":
    main()
