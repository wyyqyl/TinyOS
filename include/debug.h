
#define DEBUG

#ifdef DEBUG
	#define irpt(num) \
		__asm__ ("int %0\n\t" \
				::"N"(num))
	#define mbp() __asm__ ("xchg %%bx, %%bx"::)
#else
	#define irpt(num)
	#define mbp()
#endif