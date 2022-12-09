/******************************************************************************/
/*                                                                            */
/******************************************************************************/

#include <REG89S52.h>

#define DBYTE ((unsigned char volatile idata*) 0)
#define XBYTE ((unsigned char volatile xdata*) 0)

/*  XBYTE[0xF000] = 0xAA;         AAh in den ext. Datenspeicher Adresse F000h */
/*  DBYTE[0x80] = 0xAA;             AAh in den int. Datenspeicher Adresse 80h */

unsigned char intvar;                   /* Variable im internen Datenspeicher */
unsigned char xdata extvar;             /* Variable im externen Datenspeicher */

/******************************************************************************/
/* Timer 0 Interrupt                                                          */
/******************************************************************************/

void timer0 (void) interrupt 1 using 1     /* Int Vector at 000BH, Reg Bank 1 */
{
}

/******************************************************************************/
/***************************      MAIN PROGRAM      ***************************/
/******************************************************************************/

void main (void)
{
  while (1);
}
