# 1 "copy.c"
# 1 "/home/s3608255/nio/my_software//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "copy.c"
# 15 "copy.c"
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
# 16 "copy.c" 2
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 1
# 55 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h"
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/linker.h" 1
# 56 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 2
# 17 "copy.c" 2



volatile unsigned int *IO_CUSTOM=(unsigned int *)0x21000;
# 30 "copy.c"
int main()
{

  alt_putstr("--> Start of copy <--\n");




  IO_CUSTOM[8] = 3;

  while (IO_CUSTOM[10])
    ;

  int i;

  int buffer[8];


  for (i=0; i <= 7; i++)
    buffer[i] = IO_CUSTOM[i];


  for (i=0; i <= 7; i++) {


    int both = buffer[7-i];

    int right2left = both << 16;

    int left2right = (both >> 16) & 0x0000FFFF;

    IO_CUSTOM[i] = right2left | left2right;
  }


  IO_CUSTOM[9] = 1;

  while (IO_CUSTOM[11])
    ;


  alt_putstr("--> End of copy <--\n");


  IO_CUSTOM[12] = 1;


  return 0;
}
