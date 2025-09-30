// -----------------------------------------------------------------------------
// File         : sec_soft.c
// Description  : Full-software implementation of second-order filter
//                on nios_siso system
// Author       : Sabih Gerez, University of Twente
// Creation date: August 26, 2015
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

// auxiliary function for fixed-point multiply (2 integer, 8
// fractional bits)

// inline int fxmult_2_8(int left, int right) 
static inline int fxmult_2_8(int left, int right) 
{
  int tmp = left * right;
  return (tmp >> 8);
}


// top-level function name is always called "main"
int main()
{
  // state variables
  int z1 = 0;
  int z2 = 0;

  // constants
  const int b0 = 140;
  const int b1 = -280;
  const int b2 = 140;
  const int a1 = 225;
  const int a2 = -80;

  // temporary variables
  int m1, m2, m3, m4, m5;
  int z1_next, z2_temp, z2_next, y;

  // print to UART
  alt_putstr("--> Start of sec_soft <--\n");

  // repeat until end of input file is reached
  int block_count = 0;
  while (1) {

    // initiate data transfer from testbench to ioport
    IO_CUSTOM[IN_TRIGGER] = 1;
    // wait until transfer is ready
    while (IO_CUSTOM[IN_BUSY]) 
      ;

    // iteration indices
    int i,j;

    for (i=0; i <= 7; i++) {
      // each data transfer gives two signal samples
      int current_pair = IO_CUSTOM[i];

      // arrays of length two, to hold split input and output
      int in_pair[2], out_pair[2];

      // split pair; think of sign extension
      if (current_pair & 0x00008000)  // negative?
         in_pair[0] = current_pair | 0xFFFF0000;
      else
         in_pair[0] = current_pair & 0x0000FFFF;
      in_pair[1] = current_pair >> 16; // shift automatially extends sign

      // process both samples

      for (j=0; j <= 1; j++) {
        // multiplications and additions
        m1 = fxmult_2_8(b0, in_pair[j]);
        m2 = fxmult_2_8(b1, in_pair[j]);
        m4 = fxmult_2_8(b2, in_pair[j]);
        y  = z2 + m1;
        m3 = fxmult_2_8(a1, y);
        m5 = fxmult_2_8(a2, y);
        z1_next = m4 + m5;
        z2_temp = z1 + m2;
        z2_next = z2_temp + m3;
        // state uptdate
        z1 = z1_next;
        z2 = z2_next;
        // result sample
        out_pair[j] = y;
      }
      // write output by combining output pair
      IO_CUSTOM[i] = ((out_pair[1] << 16) & 0xFFFF0000) | 
                     (out_pair[0] & 0x0000FFFF);
    }

    // initiate data transfer from ioport to testbench
    IO_CUSTOM[OUT_TRIGGER] = 1;
    while (IO_CUSTOM[OUT_BUSY]) 
      ;
    
    // print sign of life
    // alt_printf only supports %x, %s, %c, and %%
    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
