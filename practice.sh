#!/usr/bin/env bash
# Organize genuine commands and logs; take screenshots yourself.
set -euo pipefail
cd "$(dirname "$0")"
export LANG=C.UTF-8
mkdir -p logs screenshots
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
case "${1:-}" in
    1) { run bash lab/check_environment.sh; run git log -1 --oneline; } 2>&1 | tee logs/practice-1.log ;;
    2) { run make -f Makefile.lab all; run file build/menu;
         printf '\n$ printf "help\\nhello\\nquit\\n" | ./build/menu\n';
         printf 'help\nhello\nquit\n' | ./build/menu;
       } 2>&1 | tee logs/practice-2.log ;;
    3) { run make -f Makefile.lab rootfs;
         printf '\n$ gzip -dc rootfs.img | cpio -itv\n';
         gzip -dc rootfs.img | cpio -itv;
       } 2>&1 | tee logs/practice-3.log ;;
    4) printf 'Interactive QEMU run; log saved in logs/qemu-interactive.typescript\n';
       script -q -e -c 'bash lab/run_qemu.sh' logs/qemu-interactive.typescript ;;
    5) { run git status --short; run git diff --stat;
         run git log -5 --oneline; run git remote -v;
       } 2>&1 | tee logs/practice-5.log ;;
    *) printf 'Usage: bash practice.sh 1|2|3|4|5\n'; exit 2 ;;
esac
