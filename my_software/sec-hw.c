#include "sys/alt_stdio.h"
#include "system.h"
#include <stdint.h>

volatile unsigned int *IO_CUSTOM = (unsigned int *)GP_CUSTOM_0_BASE;

/* Block I/O addresses */
#define IN_TRIGGER 8
#define OUT_TRIGGER 9
#define IN_BUSY 10
#define OUT_BUSY 11
#define STOP_SIM 12

/* Accelerator register map */
#define REG_B0     16
#define REG_B1     17
#define REG_B2     18
#define REG_A1     19
#define REG_A2     20
#define REG_X_IN   21
#define REG_Y_OUT  22
#define REG_CTRL   23
#define REG_STATUS 24

static inline void set_coeffs_q28(int16_t b0, int16_t b1, int16_t b2, int16_t a1, int16_t a2) {
  IO_CUSTOM[REG_B0] = (uint16_t)b0;
  IO_CUSTOM[REG_B1] = (uint16_t)b1;
  IO_CUSTOM[REG_B2] = (uint16_t)b2;
  IO_CUSTOM[REG_A1] = (uint16_t)a1;
  IO_CUSTOM[REG_A2] = (uint16_t)a2;
}

static inline void clear_states(void) {
  IO_CUSTOM[REG_CTRL] = (1u<<1);  // CLR=1
}

static inline int16_t iir_step_hw(int16_t x) {
  IO_CUSTOM[REG_X_IN] = (uint16_t)x;
  IO_CUSTOM[REG_CTRL] = 1u;                      // START
  while ((IO_CUSTOM[REG_STATUS] & 0x1u) == 0);   // Wait for DONE (bit0)
  return (int16_t)IO_CUSTOM[REG_Y_OUT];
}

int main(void)
{
  /* Q2.8 coefficients */
  const int16_t b0 = 140, b1 = -280, b2 = 140, a1 = 225, a2 = -80;

  alt_putstr("--> Start of sec_hw <--\n");

  set_coeffs_q28(b0, b1, b2, a1, a2);
  clear_states();

  int block_count = 0;
  while (1) {
    /* Fetch 16 samples from TVC */
    IO_CUSTOM[IN_TRIGGER] = 1;
    while (IO_CUSTOM[IN_BUSY]);

    for (int i = 0; i <= 7; i++) {
      int w = IO_CUSTOM[i];

      /* Extract two 16-bit samples with sign extension */
      int16_t xin0, xin1;
      if (w & 0x00008000) {
        xin0 = w | 0xFFFF0000;
      } else {
        xin0 = w & 0x0000FFFF;
      }
      xin1 = (int16_t)(w >> 16);

      /* Process both samples through hardware accelerator */
      int16_t y0 = iir_step_hw(xin0);
      int16_t y1 = iir_step_hw(xin1);

      /* Combine outputs */
      IO_CUSTOM[i] = ((uint32_t)((uint16_t)y1) << 16) | (uint16_t)y0;
    }

    /* Send output block */
    IO_CUSTOM[OUT_TRIGGER] = 1;
    while (IO_CUSTOM[OUT_BUSY]);

    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
