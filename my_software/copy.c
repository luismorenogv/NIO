// -----------------------------------------------------------------------------
// File         : copy.c
// Description  : C-code for copy application in nios_siso system
// Author       : Sabih Gerez, University of Twente
// Creation date: August 2, 2105
// -----------------------------------------------------------------------------
// $Rev: 1$
// $Author: gerezsh$
// $Date: Thu Sep 29 12:04:15 CEST 2022$
// $Log$
// -----------------------------------------------------------------------------



#include "sys/alt_stdio.h"
#include "system.h"


// start address of memory space (GP_CUSTOM_0_BASE is in system.h)
volatile unsigned int *IO_CUSTOM=(unsigned int *)GP_CUSTOM_0_BASE;

// declare some mnemonics
#define IN_TRIGGER 8
#define OUT_TRIGGER 9
#define IN_BUSY 10
#define OUT_BUSY 11
#define STOP_SIM 12

// function name SHOULD BE main 
int main()
{
  // print to UART
  alt_putstr("--> Start of copy <--\n");

  // initiate data transfer from testbench to gp_custom
  // it is sufficient to assign "1", but a "3" is easier to
  // distinguish in simulation waveforms
  IO_CUSTOM[IN_TRIGGER] = 3;
  // wait until transfer is ready
  while (IO_CUSTOM[IN_BUSY]) 
    ;

  int i;

  int buffer[8];

  // copy siso data to buffer
  for (i=0; i <= 7; i++)
    buffer[i] = IO_CUSTOM[i];

  // copy data from buffer back to siso in reverse order
  for (i=0; i <= 7; i++) {
    // each buffer entry consists of two inputs, that also need to be
    // reversed
    int both = buffer[7-i];
    // shift 16 to the left to obtain right number followed by 16 zeroes
    int right2left = both << 16;
    // shift 16 to the right and use mask to have 16 initial zeroes
    int left2right = (both >> 16) & 0x0000FFFF;
    // now OR the two numbers and send out
    IO_CUSTOM[i] = right2left | left2right;
  }

  // initiate data transfer from gp_custom to testbench
  IO_CUSTOM[OUT_TRIGGER] = 1;
  // wait until transfer is ready
  while (IO_CUSTOM[OUT_BUSY]) 
    ;

  // print to UART
  alt_putstr("--> End of copy <--\n");

  // stop simulation
  IO_CUSTOM[STOP_SIM] = 1;

  // we never come here
  return 0;
}
