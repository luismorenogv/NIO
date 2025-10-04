// -----------------------------------------------------------------------------
// File         : sec_flex.c
// Description  : Second-order IIR in software on nios system, multiplies
//                offloaded to HW
// Author       : Luis Moreno and Lucas Zutphen, University of Twente
// Creation date: September 31, 2025
// -----------------------------------------------------------------------------
#include "sys/alt_stdio.h"
#include "system.h"
#include <stdint.h>

volatile unsigned int *IO_CUSTOM = (unsigned int *)GP_CUSTOM_0_BASE;

// SISO block I/O (unchanged) 
#define IN_TRIGGER   8
#define OUT_TRIGGER  9
#define IN_BUSY      10
#define OUT_BUSY     11

// Flexible accelerator register map (matches VHDL) 
#define REG_OPA      16      // W: int16_t
#define REG_OPB      17      // W: int16_t
#define REG_ACC_WR   18      // W: preset ACC (optional)
#define REG_ACC_RD   21      // R: int32_t ACC
#define REG_RES      22      // R: int32_t (A*B)>>8
#define REG_CTRL     23      // W: bit0 START, bit1 CLR_ACC, bit2 MODE(0=mul,1=mac)
#define REG_STATUS   24      // R: bit1 BUSY, bit0 DONE

// Start one hw multiply (MODE=0) and return (A*B)>>8 as 32-bit Q2.8 
static inline int hw_mul_q28(int16_t a, int16_t b) {
  IO_CUSTOM[REG_OPA]  = (uint16_t)a;
  IO_CUSTOM[REG_OPB]  = (uint16_t)b;
  IO_CUSTOM[REG_CTRL] = 1u;              // START, MODE=0 (mul)
  while (IO_CUSTOM[REG_STATUS] & 0x2u) ; // wait while BUSY
  return (int)IO_CUSTOM[REG_RES];
}

// ACC helpers
static inline void hw_acc_set(int32_t val) { // preset ACC to any Q2.8 value
  IO_CUSTOM[REG_ACC_WR] = (uint32_t)val;
}
static inline void hw_acc_clear(void) {
  IO_CUSTOM[REG_CTRL] = (1u << 1);       // CLR_ACC
}
static inline void hw_mac_q28(int16_t a, int16_t b) {
  IO_CUSTOM[REG_OPA]  = (uint16_t)a;
  IO_CUSTOM[REG_OPB]  = (uint16_t)b;
  IO_CUSTOM[REG_CTRL] = (1u | (1u << 2)); // START + MODE=1 (MAC)
  while (IO_CUSTOM[REG_STATUS] & 0x2u) ;
}
static inline int hw_acc_read(void) {
  return (int)IO_CUSTOM[REG_ACC_RD];
}

int main(void)
{
  // State variables (Q2.8 in int32) 
  int z1 = 0;
  int z2 = 0;

  // Coefficients (Q2.8) 
  const int16_t b0 = 140;
  const int16_t b1 = -280;
  const int16_t b2 = 140;
  const int16_t a1 = 225;
  const int16_t a2 = -80;

  alt_putstr("--> Start of sec_flex (HW mul) <--\n");

  int block_count = 0;
  while (1) {
    // Get 16 input samples from TVC 
    IO_CUSTOM[IN_TRIGGER] = 1;
    while (IO_CUSTOM[IN_BUSY]) ;

    for (int i = 0; i <= 7; i++) {
      int w = IO_CUSTOM[i];

      // Unpack two signed 16-bit samples 
      int in0 = (w & 0x00008000) ? (w | 0xFFFF0000) : (w & 0x0000FFFF);
      int in1 = (w >> 16); // arithmetic shift keeps sign on Nios II 

      int in_pair[2]  = { in0, in1 };
      int out_pair[2];

      for (int j = 0; j < 2; j++) {
        int16_t x16 = (int16_t)in_pair[j]; // current sample

        /* y = z2 + b0*x  ->  ACC := z2; ACC += b0*x; y := ACC */
        hw_acc_set(z2);
        hw_mac_q28(b0, x16);
        int y = hw_acc_read();
        int16_t y16 = (int16_t)y;

        /* z1_next = b2*x + a2*y  ->  ACC := 0; ACC += b2*x; ACC += a2*y */
        hw_acc_clear();
        hw_mac_q28(b2, x16);
        hw_mac_q28(a2, y16);
        int z1_next = hw_acc_read();

        /* z2_next = z1 + b1*x + a1*y  ->  ACC := z1; ACC += b1*x; ACC += a1*y */
        hw_acc_set(z1);
        hw_mac_q28(b1, x16);
        hw_mac_q28(a1, y16);
        int z2_next = hw_acc_read();

        /* Commit state + output */
        z1 = z1_next;
        z2 = z2_next;
        out_pair[j] = y;
      }

      // Repack two 16-bit outputs to one 32-bit word 
      IO_CUSTOM[i] = ((uint32_t)((uint16_t)out_pair[1]) << 16) |
                      (uint16_t)out_pair[0];
    }

    // Send block to TVC 
    IO_CUSTOM[OUT_TRIGGER] = 1;
    while (IO_CUSTOM[OUT_BUSY]) ;

    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
