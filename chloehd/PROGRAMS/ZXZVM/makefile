# Makefile for ZXZVM Chloe port
# Copyright (C) 2024 Source Solutions, Inc.

# Define paths
SRCDIR = SRC
PRGDIR = PRG
RSCDIR = RSC
SCRIPTDIR = ../../../../scripts

# Define tools  
ASM = rasm
ASMFLAGS = -s

# Target files
TARGET = $(PRGDIR)/ZXZVM.PRG
MAIN_SRC = $(SRCDIR)/zxzvm.asm

# Source files
SOURCES = $(SRCDIR)/zxzvm.asm \
          $(SRCDIR)/chloedep.asm \
          $(SRCDIR)/in_zxzvm.inc

all: $(TARGET)

$(TARGET): $(SOURCES) | $(PRGDIR)
	cd $(SRCDIR) && $(ASM) zxzvm.asm -o ../PRG/ZXZVM $(ASMFLAGS)
	mv PRG/ZXZVM.bin PRG/ZXZVM.PRG

$(PRGDIR):
	mkdir -p $(PRGDIR)

clean:
	rm -f $(TARGET)
	rm -f $(PRGDIR)/*.bin
	rm -f $(PRGDIR)/*.sym
	rm -f $(SRCDIR)/*.bin
	rm -f $(SRCDIR)/*.map

test: $(TARGET)
	@echo "ZXZVM for Chloe built successfully!"
	@echo "Copy a Z-machine game file (.z3, .z5, .z8) to the RSC directory"
	@echo "Run from BASIC with: RUN \"ZXZVM\""

.PHONY: all clean test