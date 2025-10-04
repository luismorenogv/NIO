// -----------------------------------------------------------------------------
// File         : sec-hw.c
// Description  : Full-hardware implementation of second-order filter
//                on nios_siso system
// Author       : Luis Moreno and Lucas Zutphen, University of Twente
// Creation date: September 31, 2025
// -----------------------------------------------------------------------------
#include "sys/alt_stdio.h"
#include "system.h"
#include <stdint.h>

// Base address for the custom peripheral (from system.h) 
volatile unsigned int *IO_CUSTOM = (unsigned int *)GP_CUSTOM_0_BASE;

// Block I/O
#define IN_TRIGGER  8
#define OUT_TRIGGER 9
#define IN_BUSY     10
#define OUT_BUSY    11

// Accelerator register map 
#define REG_B0      16
#define REG_B1      17
#define REG_B2      18
#define REG_A1      19
#define REG_A2      20
#define REG_X_IN    21
#define REG_Y_OUT   22
#define REG_CTRL    23 // W: bit0=START, bit1=CLR 
#define REG_STATUS  24 // R: bit1=BUSY

// Write Q2.8 coefficients to the accelerator 
static inline void set_coeffs_q28(int16_t b0, int16_t b1, int16_t b2,
                                  int16_t a1, int16_t a2) {
  IO_CUSTOM[REG_B0] = (uint16_t)b0;
  IO_CUSTOM[REG_B1] = (uint16_t)b1;
  IO_CUSTOM[REG_B2] = (uint16_t)b2;
  IO_CUSTOM[REG_A1] = (uint16_t)a1;
  IO_CUSTOM[REG_A2] = (uint16_t)a2;
}

// Clear internal IIR states in hardware 
static inline void clear_states(void) {
  IO_CUSTOM[REG_CTRL] = (1u << 1); // CLR=1 
}

// Process one sample in hardware 
static inline int16_t iir_step_hw(int16_t x) {
  IO_CUSTOM[REG_X_IN] = (uint16_t)x;
  IO_CUSTOM[REG_CTRL] = 1u; // START=1
  while (IO_CUSTOM[REG_STATUS] & 0x2u) ; // wait while BUSY (bit1) 
  return (int16_t)IO_CUSTOM[REG_Y_OUT]; // sign-extended by HW 
}

int main(void)
{
  // Q2.8 coefficients
  const int16_t b0 = 140, b1 = -280, b2 = 140, a1 = 225, a2 = -80;

  alt_putstr("--> Start of sec_hw <--\n");

  set_coeffs_q28(b0, b1, b2, a1, a2);
  clear_states();

  int block_count = 0;
  while (1) {
    // Fetch 16 input samples (8 words) from TVC 
    IO_CUSTOM[IN_TRIGGER] = 1;
    while (IO_CUSTOM[IN_BUSY]) ;

    for (int i = 0; i <= 7; i++) {
      int w = IO_CUSTOM[i];

      // Extract two 16-bit samples with sign extension 
      int16_t xin0 = (w & 0x00008000) ? (int16_t)(w | 0xFFFF0000)
                                      : (int16_t)(w & 0x0000FFFF);
      int16_t xin1 = (int16_t)(w >> 16); // sign extension automatically added

      // Run each sample through the accelerator 
      int16_t y0 = iir_step_hw(xin0);
      int16_t y1 = iir_step_hw(xin1);

      // Pack two outputs back to one 32-bit word 
      IO_CUSTOM[i] = ((uint32_t)((uint16_t)y1) << 16) | (uint16_t)y0;
    }

    // Send output block back to TVC 
    IO_CUSTOM[OUT_TRIGGER] = 1;
    while (IO_CUSTOM[OUT_BUSY]) ;

    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
