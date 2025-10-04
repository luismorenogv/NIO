# 1 "sec_soft.c"
# 1 "/home/s3608255/nio/my_software//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "sec_soft.c"
# 15 "sec_soft.c"
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
# 16 "sec_soft.c" 2
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 1
# 55 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h"
# 1 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/linker.h" 1
# 56 "/home/socadmin/CPU/nios-system-2022/nios_siso/simulation/mentor/libraries/../../../software/nios_siso_bsp/system.h" 2
# 17 "sec_soft.c" 2



volatile unsigned int *IO_CUSTOM=(unsigned int *)0x21000;
# 33 "sec_soft.c"
static inline int fxmult_2_8(int left, int right)
{
  int tmp = left * right;
  return (tmp >> 8);
}



int main()
{

  int z1 = 0;
  int z2 = 0;


  const int b0 = 140;
  const int b1 = -280;
  const int b2 = 140;
  const int a1 = 225;
  const int a2 = -80;


  int m1, m2, m3, m4, m5;
  int z1_next, z2_temp, z2_next, y;


  alt_putstr("--> Start of sec_soft <--\n");


  int block_count = 0;
  while (1) {


    IO_CUSTOM[8] = 1;

    while (IO_CUSTOM[10])
      ;


    int i,j;

    for (i=0; i <= 7; i++) {

      int current_pair = IO_CUSTOM[i];


      int in_pair[2], out_pair[2];


      if (current_pair & 0x00008000)
         in_pair[0] = current_pair | 0xFFFF0000;
      else
         in_pair[0] = current_pair & 0x0000FFFF;
      in_pair[1] = current_pair >> 16;



      for (j=0; j <= 1; j++) {

        m1 = fxmult_2_8(b0, in_pair[j]);
        m2 = fxmult_2_8(b1, in_pair[j]);
        m4 = fxmult_2_8(b2, in_pair[j]);
        y = z2 + m1;
        m3 = fxmult_2_8(a1, y);
        m5 = fxmult_2_8(a2, y);
        z1_next = m4 + m5;
        z2_temp = z1 + m2;
        z2_next = z2_temp + m3;

        z1 = z1_next;
        z2 = z2_next;

        out_pair[j] = y;
      }

      IO_CUSTOM[i] = ((out_pair[1] << 16) & 0xFFFF0000) |
                     (out_pair[0] & 0x0000FFFF);
    }


    IO_CUSTOM[9] = 1;
    while (IO_CUSTOM[11])
      ;



    alt_printf("Block nr. = %x\n", ++block_count);
  }
}
