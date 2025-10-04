# -----------------------------------------------------------------------------
# File         : Makefile
# Description  : makefile for NIOS software
# Author       : Sabih Gerez, University of Twente
# Creation date: August 26, 2015 (adapted from Leon Makefile)
# -----------------------------------------------------------------------------
# $Rev: 1$
# $Author: gerezsh$
# $Date: Thu Sep 29 12:04:15 CEST 2022$
# $Log$
# -----------------------------------------------------------------------------


# declare here all user *.c files that are separate tests for the NIOS
ALL_PROGRAMS = copy.c sec_soft.c sec-hw.c sec_flex.c

# comment/uncomment to activate only one of the two following lines
MY_OPTIONS = -save-temps -O0
# MY_OPTIONS = -save-temps -O3

# do not edit below this line

ALL_HEX = $(ALL_PROGRAMS:%.c=%.hex)
PWD := $(shell pwd)
  
export MY_OPTIONS

all: $(ALL_HEX)
	touch all

# generic rule for user programs
%.hex: %.c
	echo cd $(PWD) > local-script
	echo $(MAKE) -f Altera.mk hex MY_APP=$* >> local-script
	$(QUARTUS_ROOTDIR)/../nios2eds/nios2_command_shell.sh < local-script
	cp mem_init/nios_siso_on_chip_ra.hex $*.hex

clean:
	-rm -rf *.elf *.hex *.map *.objdump *.i *.s
	-rm -rf local-script
	-rm -rf obj
	-rm -rf mem_init
	-rm -rf all
