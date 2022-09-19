# makfile configuration
TARGET      = omsp_demo
SOURCES     = main.c per_uart.c per_i2c.c ihandler.c

# Compiler performance option (-Os / -O2 / -O3)
PORT_CFLAGS     = -O2

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
ifndef MSPGCC_PFX
MSPGCC_PFX      = msp430-elf
endif

#
OUTDIR      = output
OBJDIR      = obj
OBJECTS     = $(addprefix $(OBJDIR)\,$(patsubst %.c,%.o,$(SOURCES)))


# disable some warnings specific to the Dhrystone code
WARNINGS        =  -Wall

# Select flags depending on selected toolchain
ifeq ($(MSPGCC_PFX),msp430-elf)
#INCDIR          = -I /cad/ti/gcc/include
INCDIR          = -I C:\dev\msp430-gcc\include
CFLAGS		= -D PFX_MSP430_ELF $(INCDIR) $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=msp430 -mhwmult=16bit
else
CFLAGS		= -D PFX_MSP430               $(PORT_CFLAGS) ${WARNINGS} -g -mcpu=430    -mmpy=16	-mivcnt=16
endif

# Toolchain executables
CC              = ${MSPGCC_PFX}-gcc
LD              = ${MSPGCC_PFX}-ld
OBJCOPY         = ${MSPGCC_PFX}-objcopy
OBJDUMP         = ${MSPGCC_PFX}-objdump
OBJSIZE         = ${MSPGCC_PFX}-size

.SUFFIXES:
.SUFFIXES: .o .c

.PHONY: all FORCE clean download dist

#all should be the first target. it's built when make is runwithout args
#all: $(OUTDIR)\$(TARGET).elf $(OUTDIR)\$(TARGET).bin $(OUTDIR)\$(TARGET).a43 $(OUTDIR)\$(TARGET).lst $(OUTDIR)\$(TARGET).size $(OUTDIR)\$(TARGET).mif
all: $(OUTDIR)\$(TARGET).mif $(OUTDIR)\$(TARGET).a43 $(OUTDIR)\$(TARGET).lst $(OUTDIR)\$(TARGET).size


#confgigure the next line if you want to use the serial download
download: download-uart

#additional rules for files

#project dependencies
#$(OBJDIR)\main.o: main.c
#$(OBJDIR)\ihandler.o: ihandler.c



#link everything together
$(OUTDIR)\$(TARGET).elf: ${OBJECTS}
	${CC} ${CFLAGS} -T linker.${MSPGCC_PFX}.x -o $@ ${OBJECTS}

# binary image, then .MIF file for quartus
$(OUTDIR)\$(TARGET).bin: $(OUTDIR)\$(TARGET).elf
	${OBJCOPY} -O binary --gap-fill 255 $^ $@

$(OUTDIR)\$(TARGET).mif: $(OUTDIR)\$(TARGET).bin
	.\bin\mifwrite $^ $@

# ihex image
$(OUTDIR)\$(TARGET).a43: $(OUTDIR)\$(TARGET).elf
	${OBJCOPY} -O ihex $^ $@

# disassembler file
$(OUTDIR)\$(TARGET).lst: $(OUTDIR)\$(TARGET).elf
	${OBJDUMP} -dSt $^ >$@

$(OUTDIR)\$(TARGET).size: $(OUTDIR)\$(TARGET).elf
	${OBJSIZE}  $^ >$@

$(OBJDIR)\\%.o: %.c
	if not exist $(OUTDIR) md $(OUTDIR)
	if not exist $(OBJDIR) md $(OBJDIR)
	${CC} ${CFLAGS} -c -o $@ $^

clean:
	del /f $(OUTDIR)\$(TARGET).a43 $(OUTDIR)\$(TARGET).lst $(OUTDIR)\$(TARGET).bin $(OUTDIR)\$(TARGET).mif $(OUTDIR)\$(TARGET).elf $(OUTDIR)\$(TARGET).size $(OBJDIR)\*.o

#backup archive
dist:
	tar czf dist.tgz *.c *.h *.txt makefile

#dummy target as dependecy if something has to be build everytime
FORCE:


