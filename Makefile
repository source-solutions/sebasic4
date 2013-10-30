TARGET=se-$(rom).rom

# Point to z80-binutils installation (if required)
# #
#CROSSASM=$(HOME)/src/crossAsm

# Project sub-directories that need to be buit
#
SUBDIRS=

# Linker script (config)
# 
LDSCRIPT=sebasic4.ld

# Library, link and include directories
# 
LIB_DIRS  =
LINK_LIBS =
INC_DIRS  = data modules

# COFF sections to output into target
# 
OUTSECTIONS= .text

# Parameter files that get processed first
#
PARAMFILES= sebasic4.def

# Define file ending for src files (defaults to z8s)
# 
SRC_EXT=asm

# Source files
Z80_ASM =  \
sebasic4.asm

all: rom0 rom1

rom0: dirs clean $(Z80_ASM)
	@make build rom=0

rom1: dirs clean $(Z80_ASM)
	@make build rom=1

announce:
	@echo "Info: Building SE Basic IV ROM $(rom) : $(TARGET)"

build: dirs announce $(TARGET) map
	@cp $(TARGET) bin/
	@echo "Done."
	@echo ""

# Local Makefile Targets
#
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

dump: sebasic4.coff
	$(OBJDUMP) -s $?

#include $(CROSSASM)/z80/Makefile_Z80
include Makefile_Z80
