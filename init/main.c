#define		BLACK			 0
#define		BLUE			 1
#define		GREEN			 2
#define		CYAN			 3
#define		RED				 4
#define		MAGENTA			 5
#define		BROWN			 6
#define		LIGHTGRAY		 7
#define		DARKGRAY		 8
#define		LIGHTBLUE		 9
#define		LIGHTGREEN		10
#define		LIGHTCYAN		11
#define		LIGHTRED		12
#define		LIGHTMAGENTA	13
#define		YELLOW			14
#define		WHITE			15
#define		BLINK			28

void write_string(char *pstring, int color, int row, int column)
{
	int addr = 0xB8000 + 2 * (80 * row + column);
	char *pvideo = (char *)addr;
	while(*pstring)
	{
		*pvideo++ = *pstring++;
		*pvideo++ = color;
	}
}

void main(){
	unsigned int column = (unsigned int)(*(char *)0x90000);
	unsigned int row = (unsigned int)(*(char *)(0x90001));
	write_string("Hello,TinyOS World!", RED, row, column);
}
