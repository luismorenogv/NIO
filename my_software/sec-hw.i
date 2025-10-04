# 1 "sec-hw.c"
# 1 "/home/s3608255/nio/my_software//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "sec-hw.c"







# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp//HAL/inc/sys/alt_stdio.h" 1
# 46 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp//HAL/inc/sys/alt_stdio.h"
# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdarg.h" 1 3 4
# 40 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdarg.h" 3 4

# 40 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdarg.h" 3 4
typedef __builtin_va_list __gnuc_va_list;
# 98 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdarg.h" 3 4
typedef __gnuc_va_list va_list;
# 47 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp//HAL/inc/sys/alt_stdio.h" 2







# 53 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp//HAL/inc/sys/alt_stdio.h"
int alt_getchar();
int alt_putchar(int c);
int alt_putstr(const char* str);
void alt_printf(const char *fmt, ...);
# 9 "sec-hw.c" 2
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 1
# 55 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h"
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/linker.h" 1
# 56 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 2
# 10 "sec-hw.c" 2
# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdint.h" 1 3 4
# 9 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdint.h" 3 4
# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 1 3 4
# 12 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 1 3 4







# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/sys/features.h" 1 3 4
# 9 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 2 3 4
# 27 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4

# 27 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef signed char __int8_t;

typedef unsigned char __uint8_t;
# 41 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef short int __int16_t;

typedef short unsigned int __uint16_t;
# 63 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef long int __int32_t;

typedef long unsigned int __uint32_t;
# 89 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef long long int __int64_t;

typedef long long unsigned int __uint64_t;
# 120 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef signed char __int_least8_t;

typedef unsigned char __uint_least8_t;
# 146 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef short int __int_least16_t;

typedef short unsigned int __uint_least16_t;
# 168 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef long int __int_least32_t;

typedef long unsigned int __uint_least32_t;
# 186 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef long long int __int_least64_t;

typedef long long unsigned int __uint_least64_t;
# 200 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/machine/_default_types.h" 3 4
typedef int __intptr_t;

typedef unsigned int __uintptr_t;
# 13 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 2 3 4
# 1 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/sys/_intsup.h" 1 3 4
# 14 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 2 3 4






typedef __int8_t int8_t ;
typedef __uint8_t uint8_t ;




typedef __int_least8_t int_least8_t;
typedef __uint_least8_t uint_least8_t;




typedef __int16_t int16_t ;
typedef __uint16_t uint16_t ;




typedef __int_least16_t int_least16_t;
typedef __uint_least16_t uint_least16_t;




typedef __int32_t int32_t ;
typedef __uint32_t uint32_t ;




typedef __int_least32_t int_least32_t;
typedef __uint_least32_t uint_least32_t;




typedef __int64_t int64_t ;
typedef __uint64_t uint64_t ;




typedef __int_least64_t int_least64_t;
typedef __uint_least64_t uint_least64_t;
# 74 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef int int_fast8_t;
  typedef unsigned int uint_fast8_t;
# 84 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef int int_fast16_t;
  typedef unsigned int uint_fast16_t;
# 94 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef int int_fast32_t;
  typedef unsigned int uint_fast32_t;
# 104 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef long long int int_fast64_t;
  typedef long long unsigned int uint_fast64_t;
# 153 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef long long int intmax_t;
# 162 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/nios2-elf/include/stdint.h" 3 4
  typedef long long unsigned int uintmax_t;






typedef __intptr_t intptr_t;
typedef __uintptr_t uintptr_t;
# 10 "/remote/labware/packages/intel/quartus/18.1/nios2eds/bin/gnu/H-x86_64-pc-linux-gnu/lib/gcc/nios2-elf/5.3.0/include/stdint.h" 2 3 4
# 11 "sec-hw.c" 2



# 13 "sec-hw.c"
volatile unsigned int *IO_CUSTOM = (unsigned int *)0x21000;
# 33 "sec-hw.c"
static inline void set_coeffs_q28(int16_t b0, int16_t b1, int16_t b2,
                                  int16_t a1, int16_t a2) {
  IO_CUSTOM[16] = (uint16_t)b0;
  IO_CUSTOM[17] = (uint16_t)b1;
  IO_CUSTOM[18] = (uint16_t)b2;
  IO_CUSTOM[19] = (uint16_t)a1;
  IO_CUSTOM[20] = (uint16_t)a2;
}


static inline void clear_states(void) {
  IO_CUSTOM[23] = (1u << 1);
}


static inline int16_t iir_step_hw(int16_t x) {
  IO_CUSTOM[21] = (uint16_t)x;
  IO_CUSTOM[23] = 1u;
  while (IO_CUSTOM[24] & 0x2u) ;
  return (int16_t)IO_CUSTOM[22];
}

int main(void)
{

  const int16_t b0 = 140, b1 = -280, b2 = 140, a1 = 225, a2 = -80;

  alt_putstr("--> Start of sec_hw <--\n");

  set_coeffs_q28(b0, b1, b2, a1, a2);
  clear_states();

  int block_count = 0;
  while (1) {

    IO_CUSTOM[8] = 1;
    while (IO_CUSTOM[10]) ;

    for (int i = 0; i <= 7; i++) {
      int w = IO_CUSTOM[i];


      int16_t xin0 = (w & 0x00008000) ? (int16_t)(w | 0xFFFF0000)
                                      : (int16_t)(w & 0x0000FFFF);
      int16_t xin1 = (int16_t)(w >> 16);


      int16_t y0 = iir_step_hw(xin0);
      int16_t y1 = iir_step_hw(xin1);


      IO_CUSTOM[i] = ((uint32_t)((uint16_t)y1) << 16) | (uint16_t)y0;
    }


    IO_CUSTOM[9] = 1;
    while (IO_CUSTOM[11]) ;

    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
