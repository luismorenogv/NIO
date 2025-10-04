# 1 "sec_flex.c"
# 1 "/home/s3608255/nio/my_software//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "sec_flex.c"







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
# 9 "sec_flex.c" 2
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 1
# 55 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h"
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/linker.h" 1
# 56 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 2
# 10 "sec_flex.c" 2
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
# 11 "sec_flex.c" 2


# 12 "sec_flex.c"
volatile unsigned int *IO_CUSTOM = (unsigned int *)0x21000;
# 30 "sec_flex.c"
static inline int hw_mul_q28(int16_t a, int16_t b) {
  IO_CUSTOM[16] = (uint16_t)a;
  IO_CUSTOM[17] = (uint16_t)b;
  IO_CUSTOM[23] = 1u;
  while (IO_CUSTOM[24] & 0x2u) ;
  return (int)IO_CUSTOM[22];
}


static inline void hw_acc_clear(void) {
  IO_CUSTOM[23] = (1u << 1);
}
static inline void hw_mac_q28(int16_t a, int16_t b) {
  IO_CUSTOM[16] = (uint16_t)a;
  IO_CUSTOM[17] = (uint16_t)b;
  IO_CUSTOM[23] = (1u | (1u << 2));
  while (IO_CUSTOM[24] & 0x2u) ;
}
static inline int hw_acc_read(void) {
  return (int)IO_CUSTOM[21];
}

int main(void)
{

  int z1 = 0;
  int z2 = 0;


  const int16_t b0 = 140;
  const int16_t b1 = -280;
  const int16_t b2 = 140;
  const int16_t a1 = 225;
  const int16_t a2 = -80;

  alt_putstr("--> Start of sec_flex (HW mul) <--\n");

  int block_count = 0;
  while (1) {

    IO_CUSTOM[8] = 1;
    while (IO_CUSTOM[10]) ;

    for (int i = 0; i <= 7; i++) {
      int w = IO_CUSTOM[i];


      int in0 = (w & 0x00008000) ? (w | 0xFFFF0000) : (w & 0x0000FFFF);
      int in1 = (w >> 16);

      int in_pair[2] = { in0, in1 };
      int out_pair[2];

      for (int j = 0; j < 2; j++) {

        int m1 = hw_mul_q28(b0, (int16_t)in_pair[j]);
        int m2 = hw_mul_q28(b1, (int16_t)in_pair[j]);
        int m4 = hw_mul_q28(b2, (int16_t)in_pair[j]);


        int y = z2 + m1;


        int16_t y16 = (int16_t)y;
        int m3 = hw_mul_q28(a1, y16);
        int m5 = hw_mul_q28(a2, y16);


        int z1_next = m4 + m5;
        int z2_next = z1 + m2 + m3;

        z1 = z1_next;
        z2 = z2_next;

        out_pair[j] = y;
      }


      IO_CUSTOM[i] = ((uint32_t)((uint16_t)out_pair[1]) << 16) |
                      (uint16_t)out_pair[0];
    }


    IO_CUSTOM[9] = 1;
    while (IO_CUSTOM[11]) ;

    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
