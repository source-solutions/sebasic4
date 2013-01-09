rom=1
TARGET=se-$(rom).rom

# Point to z80-binutils installation (if required)
# #
#CROSSASM=$(HOME)/src/crossAsm

# Project sub-directories that need to be buit
#
SUBDIRS=

# Linker script (config)
# 
LDSCRIPT=sebasic.ld

# Library, link and include directories
# 
LIB_DIRS  =
LINK_LIBS =
INC_DIRS  = data

# COFF sections to output into target
# 
OUTSECTIONS= .text

# Parameter files that get processed first
#
PARAMFILES= sebasic.def

# Define file ending for src files (defaults to z8s)
# 
SRC_EXT=asm

# Source files
Z80_ASM =  \
sebasic.asm


# Local Makefile Targets
#
all: dirs $(TARGET) map
	@echo "Done."

fresh: clean all

dirs : 
	@for i in $(SUBDIRS); do \
	(cd $$i; echo "Info: Make $$i"; $(MAKE) $(MFLAGS) $(MYMAKEFLAGS) all); done

map :
	@rm -f $(SNAPSHOT)
	@( \
	    S=`grep __"start_of_startup__ = ." lst/*.map | cut -b 17-35`; \
	    X=`grep __"start_of_startup__ = ." lst/*.map | cut -b 17-35` ; \
	    E=`grep __"bss_end__ = ." lst/*.map | cut -b 17-35` ; \
	    echo "Start Addr is " $$S; \
	    echo "Exec  Addr is " $$X; \
	    echo "End   Addr is " $$E; \
	)

dump: sebasic.coff
	$(OBJDUMP) -s $?

#include $(CROSSASM)/z80/Makefile_Z80
include Makefile_Z80
