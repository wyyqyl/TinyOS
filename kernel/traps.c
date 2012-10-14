
#include <asm/system.h>
#include <asm/io.h>
#include <head.h>
#include <debug.h>

void display_string(char *str);
void display_int(int n);

void divide_error();
void debug();
void nmi();
void int3();
void overflow();
void bounds();
void invalid_op();
void device_not_available();
void double_fault();
void coprocessor_segment_overrun();
void invalid_TSS();
void segment_not_present();
void stack_segment();
void general_protection();
void page_fault();
void coprocessor_error();
void reserved();
void parallel_interrupt();
void irq13();

static void die(char *str, long esp_ptr, long nr)
{
	long *esp = (long *)esp_ptr;
	display_string(str);
	display_string(": ");
	display_int(nr);
	
	display_string("\nCS: ");
	display_int(esp[1]);
	display_string(", EIP: ");
	display_int(esp[0]);
	display_string(", EFLAGS: ");
	display_int(esp[2]);
	display_string(", SS: ");
	display_int(esp[4]);
	display_string(", ESP: ");
	display_int(esp[3]);
	display_return();
	
}

void do_double_fault(long esp, long error_code)
{
	die("double fault", esp, error_code);
}

void do_general_protection(long esp, long error_code)
{
	die("general protection", esp, error_code);
}

void do_divide_error(long esp, long error_code)
{
	die("divide error", esp, error_code);
}

void do_int3(long esp, long error_code)
{
	die("int3", esp, error_code);
}

void do_nmi(long esp, long error_code)
{
	die("nmi", esp, error_code);
}

void do_debug(long esp, long error_code)
{
	die("debug", esp, error_code);
}

void do_overflow(long esp, long error_code)
{
	die("overflow", esp, error_code);
}

void do_bounds(long esp, long error_code)
{
	die("bounds", esp, error_code);
}

void do_invalid_op(long esp, long error_code)
{
	die("invalid operand", esp, error_code);
}

void do_device_not_available(long esp, long error_code)
{
	die("device not available", esp, error_code);
}

void do_coprocessor_segment_overrun(long esp, long error_code)
{
	die("coprocessor segment overrun", esp, error_code);
}

void do_invalid_TSS(long esp,long error_code)
{
	die("invalid TSS", esp, error_code);
}

void do_segment_not_present(long esp,long error_code)
{
	die("segment not present", esp, error_code);
}

void do_stack_segment(long esp,long error_code)
{
	die("stack segment", esp, error_code);
}

void do_coprocessor_error(long esp, long error_code)
{
	die("coprocessor error", esp, error_code);
}

void do_reserved(long esp, long error_code)
{
	die("reserved (15,17-47) error", esp, error_code);
}

void trap_init()
{
	int i;
	set_trap_gate(0, &divide_error);
	set_trap_gate(1, &debug);
	set_trap_gate(2, &nmi);
	set_system_gate(3, &int3);	/* int3-5 can be called from all */
	set_system_gate(4, &overflow);
	set_system_gate(5, &bounds);
	set_trap_gate(6, &invalid_op);
	//set_trap_gate(7, &device_not_available);
	set_trap_gate(8, &double_fault);
	set_trap_gate(9, &coprocessor_segment_overrun);
	set_trap_gate(10, &invalid_TSS);
	set_trap_gate(11, &segment_not_present);
	set_trap_gate(12, &stack_segment);
	set_trap_gate(13, &general_protection);
	//set_trap_gate(14,&page_fault);
	set_trap_gate(15, &reserved);
	//set_trap_gate(16, &coprocessor_error);
	for (i = 17; i < 48; i++)				// it will be set when corresponding
		set_trap_gate(i, &reserved);		// hardware is initialized
	//set_trap_gate(45, &irq13);
	outb_p(inb_p(0x21) & 0xfb, 0x21);		// enable NMI
	outb(inb_p(0xA1) & 0xdf, 0xA1);		// enable FPU
	//set_trap_gate(39, &parallel_interrupt);
}
