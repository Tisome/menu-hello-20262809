#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/utsname.h>
#include "menu.h"

#define FONTSIZE 10
int PrintMenuOS()
{
    int i, j;
    char data_M[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "  *    *  ",
        " ***  *** ",
        " * *  * * ",
        " * *  * * ",
        " *  **  * ",
        " *      * ",
        " *      * ",
        " *      * ",
        "          "
    };
    char data_e[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "          ",
        "    **    ",
        "   *  *   ",
        "  *    *  ",
        "  ******  ",
        "  *       ",
        "   *      ",
        "    ***   ",
        "          "
    };
    char data_n[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "          ",
        "    **    ",
        "   *  *   ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "          "
    };
    char data_u[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "          ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "  *    *  ",
        "   *  **  ",
        "    **  * ",
        "          "
    };
    char data_O[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "   ****   ",
        "  *    *  ",
        " *      * ",
        " *      * ",
        " *      * ",
        " *      * ",
        "  *    *  ",
        "   ****   ",
        "          "
    };
    char data_S[FONTSIZE][FONTSIZE] =
    {
        "          ",
        "    ****  ",
        "   **     ",
        "  **      ",
        "   ***    ",
        "     **   ",
        "      **  ",
        "     **   ",
        "  ****    ",
        "          "
    };

    for(i=0; i<FONTSIZE; i++)
    {
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_M[i][j]);
        }
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_e[i][j]);
        }
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_n[i][j]);
        }
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_u[i][j]);
        }
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_O[i][j]);
        }
        for(j=0; j<FONTSIZE; j++)
        {
            printf("%c", data_S[i][j]);
        }
        printf("\n");
    }
    return 0;
}

int Quit(int argc, char *argv[])
{
    (void)argc;
    (void)argv;
    if (getpid() != 1) {
        exit(0);
    }
    /* PID 1 must stay alive; terminate QEMU with Ctrl-a, then x. */
    puts("PID 1 stays running. Exit QEMU with Ctrl-a, then x.");
    return 0;
}

/* Coursework command: type hello at the MenuOS>> prompt. */
int Hello(int argc, char *argv[])
{
    (void)argc;
    (void)argv;
    puts("hello 20262809");
    return 0;
}

int Time(int argc, char *argv[])
{
    time_t tt;
    struct tm *t;
    tt = time(NULL);
    t = localtime(&tt);
    printf("time:%d:%d:%d:%d:%d:%d\n",t->tm_year+1900, t->tm_mon+1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
    return 0;
}

int TimeAsm(int argc, char *argv[])
{
    time_t tt;
    struct tm *t;
    /* i386 time(2): eax=13, ebx=NULL, result in eax. */
    asm volatile("int $0x80"
                 : "=a" (tt)
                 : "0" (13), "b" (0)
                 : "memory", "cc");
    t = localtime(&tt);
    printf("time:%d:%d:%d:%d:%d:%d\n",t->tm_year+1900, t->tm_mon+1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
    return 0;
}
int main()
{
    struct utsname system_info;
    /* Serial consoles and pipes must show prompts immediately. */
    setvbuf(stdout, NULL, _IONBF, 0);
    PrintMenuOS();
    if (uname(&system_info) == 0) {
        printf("Kernel: %s %s %s | PID: %ld\n",
               system_info.sysname, system_info.release,
               system_info.machine, (long)getpid());
    }
    SetPrompt("MenuOS>>");
    MenuConfig("version","MenuOS coursework - student 20262809",NULL);
    MenuConfig("hello","Print hello and student ID",Hello);
    MenuConfig("quit","Quit from MenuOS",Quit);
    MenuConfig("time","Show System Time",Time);
    MenuConfig("time-asm","Show System Time(asm)",TimeAsm);
    ExecuteMenu();
}

