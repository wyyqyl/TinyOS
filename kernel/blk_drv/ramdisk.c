/*
 *  linux/kernel/blk_drv/ramdisk.c
 *
 *  Written by Theodore Ts'o, 12/2/91
 */
#define MAJOR_NR 1
#include "blk.h"

char	*rd_start;
int	rd_length = 0;

void do_rd_request(void)
{

}

/*
 * Returns amount of memory which needs to be reserved.
 */
long rd_init(long mem_start, int length)
{
	int	i;
	char	*cp;

	blk_dev[MAJOR_NR].request_fn = DEVICE_REQUEST;
	rd_start = (char *) mem_start;
	rd_length = length;
	cp = rd_start;
	for (i=0; i < length; i++)
		*cp++ = '\0';
	return(length);
}
