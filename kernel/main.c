
#include <debug.h>
#include <sched.h>
#include <asm/system.h>

void trap_init();
int k_reenter;

void main()
{
	k_reenter = -1;
	
	trap_init();
	sched_init();
	sti();
	move_to_user_mode();
	
	// ring3
	testFunc();
}

void delay(int time)
{
	int i, j, k;
	for (k = 0; k < time; k++) {
		for (i = 0; i < 10; i++) {
			for (j = 0; j < 10000; j++) {}
		}
	}
}

void testFunc()
{
	int i = 0;
	while(1)
	{
		display_string("3");
		delay(1);
	}
}