#ifndef _SCHED_H
#define _SCHED_H

#define NR_TASKS 64
#define HZ 100

#define FIRST_TASK task[0]
#define LAST_TASK task[NR_TASKS-1]

#include <head.h>
#include <mm.h>

typedef struct _tss_struct {
	long	back_link;	/* 16 high bits zero */
	long	esp0;
	long	ss0;		/* 16 high bits zero */
	long	esp1;
	long	ss1;		/* 16 high bits zero */
	long	esp2;
	long	ss2;		/* 16 high bits zero */
	long	cr3;
	long	eip;
	long	eflags;
	long	eax,ecx,edx,ebx;
	long	esp;
	long	ebp;
	long	esi;
	long	edi;
	long	es;		/* 16 high bits zero */
	long	cs;		/* 16 high bits zero */
	long	ss;		/* 16 high bits zero */
	long	ds;		/* 16 high bits zero */
	long	fs;		/* 16 high bits zero */
	long	gs;		/* 16 high bits zero */
	long	ldt;		/* 16 high bits zero */
	long	trace_bitmap;	/* bits: trace 0, bitmap 16-31 */
	//struct i387_struct i387;
}tss_struct;

typedef struct _task_struct
{
	long pid;
	char p_name[16];
	/* 0: null, 1: cs, 2: ds&ss*/
	desc_struct ldt[3];
	tss_struct tss;
}task_struct;

extern void testFunc();
extern long page_dir;

#define INIT_TASK \
{ \
	0, "Idle", \
	{ \
		{0, 0},\
		{0x0FFFF, 0xCFFA00}, \
		{0x0FFFF, 0xCFF200}, \
	}, \
	{ \
		0, PAGE_SIZE+(long)&init_task, 0x10, 0, 0, 0, 0, (long)&page_dir, \
		0, 0, 0, 0, 0, 0, 0, 0, \
		0, 0, 0x17, 0x0F, 0x17, 0x17, 0x17, 0x1B, \
		_LDT(0), 0x80000000, \
	}, \
}

/*
 * Entry into gdt where to find first TSS. 0-nul, 1-cs, 2-ds, 3-video
 * 4-TSS0, 5-LDT0, 6-TSS1 etc ...
 */
#define FIRST_TSS_ENTRY 4
#define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY + 1)
#define _TSS(n) ((((unsigned long) n)<<4) + (FIRST_TSS_ENTRY<<3))
#define _LDT(n) ((((unsigned long) n)<<4) + (FIRST_LDT_ENTRY<<3))
#define ltr(n) __asm__("ltr %%ax"::"a" (_TSS(n)))
#define lldt(n) __asm__("lldt %%ax"::"a" (_LDT(n)))

extern task_struct *task[NR_TASKS];
extern task_struct *current;

#endif