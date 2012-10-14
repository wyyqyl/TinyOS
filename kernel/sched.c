
#include <sched.h>
#include <asm/system.h>
#include <asm/io.h>
#include <debug.h>

#define LATCH (1193180/HZ)

void timer_interrupt();

typedef union _task_union
{
	task_struct task;
	char stack[PAGE_SIZE];	// kernel stack
} task_union;

static task_union init_task = {INIT_TASK,};

task_struct *task[NR_TASKS] = {&(init_task.task),};
task_struct *current = &(init_task.task);

long user_stack[PAGE_SIZE >> 2];	// user stack
struct {
	long *a;
	short b;
} stack_start = { &user_stack[PAGE_SIZE >> 2], 0x10};


void sched_init()
{
	set_tss_desc(gdt + FIRST_TSS_ENTRY, &(init_task.task.tss));
	set_ldt_desc(gdt + FIRST_LDT_ENTRY, &(init_task.task.ldt));
	// Clear Nested Task Flag
	__asm__("pushfl; andl $0xffffbfff, (%esp); popfl");
	ltr(0);
	lldt(0);
	// Init 8253 timer
	outb_p(0x36,0x43);		/* binary, mode 3, LSB/MSB, ch 0 */
	outb_p(LATCH & 0xff , 0x40);	/* LSB */
	outb(LATCH >> 8 , 0x40);	/* MSB */
	set_intr_gate(0x20, &timer_interrupt);	/* set timer interrupt */
	outb(inb_p(0x21) & ~0x01, 0x21);	/* Enable timer interrupt */
}
