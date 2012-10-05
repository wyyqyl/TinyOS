/*
 * linux/kernel/math/math_emulate.c
 *
 * (C) 1991 Linus Torvalds
 */

/*
 * This directory should contain the math-emulation code.
 * Currently only results in a signal.
 */

#include <signal.h>

#include <linux/sched.h>
#include <linux/kernel.h>

void math_emulate(long edi, long esi, long ebp, long sys_call_ret,
	long eax,long ebx,long ecx,long edx,
	unsigned short fs,unsigned short es,unsigned short ds,
	unsigned long eip,unsigned short cs,unsigned long eflags,
	unsigned short ss, unsigned long esp)
{

}

void math_error(void)
{
	__asm__("fnclex");
	if (last_task_used_math)
		last_task_used_math->signal |= 1<<(SIGFPE-1);
}

