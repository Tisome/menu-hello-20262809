menu
====

cmdline menu libary

## Coursework: hello 20262809

This checkout preserves the upstream menu framework and adds a `hello` menu
command in `test.c`. It prints `hello 20262809`.

The original Makefile is preserved. For this WSL/QEMU lab, use:

```bash
bash lab/check_environment.sh
bash lab/prepare_kernel.sh
make -f Makefile.lab rootfs
bash lab/run_qemu.sh
```

At the guest's `MenuOS>>` prompt, type `help`, `hello`, and `version`.
Exit QEMU with Ctrl-a, then x. The guest runs the menu as `/init`, PID 1;
`quit` therefore keeps the guest init alive.

The Ubuntu QEMU kernel is downloaded and extracted, not installed as the WSL
kernel. A 32-bit static menu is used to preserve the i386 syscall example.
Install GCC multilib, Python 3, cpio and QEMU as documented in the manual.

Read [推进方案](推进方案.md), [执行步骤手册](执行步骤手册.md), and
[代码改动讲解](代码改动讲解.md) for reproduction and screenshot steps.

Upstream baseline: `f61389b6cb759dc80d14e3081957c95a74815ffe`.
The original license and attribution are preserved.

example code 
----

    #include <stdio.h>
    #include <stdlib.h>
    #include "menu.h"
    
    int Quit(int argc, char *argv[])
    {
        /* add XXX clean ops */
        exit(0);
    }
    
    int main()
    {
    
        MenuConfig("version","XXX V1.0(Menu program v1.0 inside)",NULL);
        MenuConfig("quit","Quit from XXX",Quit);
        
        ExecuteMenu();
    }


## User Links

* [工程化编程实战](https://mooc.study.163.com/course/1000103000?_trace_c_p_k2_=2b68c5974ba8438894c4518ef342e21b&share=2&shareId=1000001002#/info)
* [代码中的软件工程](https://gitee.com/mengning997/se/blob/master/README.md#%E4%BB%A3%E7%A0%81%E4%B8%AD%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%B7%A5%E7%A8%8B)
* [庖丁解牛Linux内核](https://mooc.study.163.com/course/1000072000?_trace_c_p_k2_=3f48b65c40864fdba6b25b986796ac82&share=2&shareId=1000001002#/info)
