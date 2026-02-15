#
# Makefile for Linux
#
# Structure of ZXZVM: There are five modules: ZXZVM, P3IO, RESIO,
# JOYCEIO and ANNEIO. 
# Files common to all are listed under INC and ZXIO; the others
# under the modules' names.
#
# "Joyce" and "PCW10" refer to the 4MHz PCWs: PCW8000 series, PCW9000
# series and PCW10.
# "Anne"  refers to the PCW16.
#

INC   = in_zxzvm.inc in_wrhex.inc in_ver.inc
ZXIO  = zxio.zsm zxp3dos.zsm zxvers.zsm zx64.zsm zxfnt323.zsm
ZXGENFNT = zxfont64.zsm zxfnt643.zsm
ZXZVM = vm.zsm vmvar.zsm vm0ops.zsm vm1ops.zsm vm2ops.zsm vmvops.zsm \
        vmeops.zsm vmarith.zsm vmobj.zsm vmprop.zsm vmzchar.zsm vmdebug.zsm \
	vmdict.zsm
P3IO = p3dep.zsm
RESIIO = residep.zsm
ESXIO = esxdep.zsm
ZXFNT32 = zxfnt32.zsm zxfont32.bin
BASFILES = p3bas.tap resibas.tap disk.txt
JOYCEIO = joyceio.zsm joyuserf.zsm joybdos.zsm joycescr.zsm joycemem.zsm \
        joycrtp.zsm joyceinp.zsm
JOYGENFNT = joyfont3.zsm joyfonta.zsm
ANNEIO = anneio.zsm annedisc.zsm annemenu.zsm annevt.zsm annedbg.zsm \
	annescr.zsm annescrl.zsm annemem.zsm \
	anneos.inc annecall.inc \
	annelint
#
# The fonts for the Spectrum and PCW10 versions are stored in XBM format.
#
XBM   = zxfont64.xbm zxfnt643.xbm joyfont3.xbm joyfonta.xbm
#
# xbm2zsm converts the .XBMs to Z80 source.
#
CFILES = xbm2zsm.c 
CC     = gcc
CFLAGS = -g
#
# Documentation, and the distribution tarfiles
#
DOCS   = README zxzvm.doc pcw16.doc file_id.diz copying
SRCDOC = source.doc
SRCTAR = zxzvm.src.zip
BINTAR = zxzvm.zip
#
# v0.03: Now packing with zip, not tar. 
#
TAR   = zip
#TAR  = tar zcf

all:	zxzvm.tap zxzvm.tzx resizvm.tap resizvm.tzx \
	zxzvm.bin anneio.prg joyceio.com disc16.ufi

esxdos:	zxzvm.bin zxio.bin zxfnt32.bin zxfnt323.bin

zxzvm.tap: zxvm.tap zxio.tap p3bas.tap zxfnt32.tap zxfnt323.tap
	cat p3bas.tap zxfnt323.tap zxfnt32.tap zxvm.tap zxio.tap > zxzvm.tap

zxzvm.tzx: zxzvm.tap
	tapeconv zxzvm.tap zxzvm.tzx

resizvm.tap: resivm.tap resiio.tap resibas.tap zxfnt32.tap zxfnt323.tap
	cat resibas.tap zxfnt323.tap zxfnt32.tap resivm.tap resiio.tap > resizvm.tap

resizvm.tzx: resizvm.tap
	tapeconv resizvm.tap resizvm.tzx

zxzvm.bin: ${ZXZVM} ${INC}
	pasmo --nocase --equ ZJT=04000h vm.zsm $@ zxzvm.sym

zxzvm.zxb: ${ZXZVM} ${INC}
	pasmo --nocase --plus3dos --equ ZJT=04000h vm.zsm $@ zxzvm.sym

zxvm.tap: ${ZXZVM} ${INC}
	pasmo --nocase --tap --name zxvm --equ ZJT=04000h \
        vm.zsm zxvm.tap zxvm.sym

resivm.tap: ${ZXZVM} ${INC} 
	pasmo --nocase --tap --name resivm --equ ZJT=0E020h \
        vm.zsm resivm.tap resivm.sym

zxio.tap: ${ZXIO} ${ZXGENFNT} ${P3IO} ${INC}
	pasmo --nocase --tap --name zxio --equ ZJT=04000h \
	 p3dep.zsm zxio.tap zxio.sym

zxio.zxb: ${ZXIO} ${ZXGENFNT} ${P3IO} ${INC}
	pasmo --nocase --plus3dos --equ ZJT=04000h p3dep.zsm zxio.zxb zxio.sym

zxio.bin: ${ZXGENFNT}
	pasmo --nocase --name zxio --equ ZJT=04000h esxdep.zsm zxio.bin zxio.sym

zxfnt323.tap: zxfnt323.zsm
	pasmo --nocase --tap --name zxgrph zxfnt323.zsm zxfnt323.tap

resiio.tap: ${ZXIO} ${ZXGENFNT} ${RESIIO} ${INC}
	pasmo --nocase --tap --name resiio --equ ZJT=0E020h \
	residep.zsm resiio.tap resiio.sym

zxfnt32.tap: ${ZXFNT32}
	pasmo --nocase --tap --name zxfnt zxfnt32.zsm zxfnt32.tap

zxfnt32.bin: ${ZXFNT32}
	pasmo --nocase --name zxfnt zxfnt32.zsm zxzvm32.fnt


zxfnt323.bin: zxfnt323.zsm
	pasmo --nocase --name zxgrph zxfnt323.zsm zxgrph32.fnt

anneio.prg: ${ANNEIO} ${INC}
	./annelint
	pasmo --nocase --equ ZJT=04000h anneio.zsm anneio.prg anneio.sym

joyceio.com: ${JOYCEIO} ${JOYGENFNT} ${INC} 
	pasmo --nocase --equ ZJT=04000h joyceio.zsm joyceio.com joyceio.sym

pcwzvm.com: joyceio.com
	cp joyceio.com pcwzvm.com
#
# "make run" to run the Spectrum program within fuse. The original makefile
# couldn't inject files into a DSK, but now I have cpmtools...
#
run:	disk zxzvm.zxb zxio.zxb
	dskform -format pcw720 diska.dsk
	cpmcp -f amstrad diska.dsk disk zxzvm.zxb zxio.zxb \
		zxgrph.zxb beyzork.z5 gntests.z5 etude.z5 \
		bear.z5 mst3k1.z5 zxfont32.zxb 0:
	#fuse diska.dsk
	#fuse zxzvm.tap
	xzx -ma 3 -scale 2 -fda diska.dsk

disk:	disk.txt
	zmakebas -p -a 0 -o $@ $<
#
# "make pcwrun" to run the PCW program within JOYCE.
#
pcwrun:	joyceio.com zxzvm.bin
	ln -s -f zxzvm.bin ZXZVM.BIN
	ln -s -f zxzvm.sym ZXZVM.SYM
	ln -s -f joyceio.com JOYCEIO.COM
	ln -s -f joyceio.sym JOYCEIO.SYM
	xjoyce -B diskb.dsk -A \#8

pcw16copy: anneio.prg zxzvm.bin
	cp zxzvm.bin ~/Joyce/PcW16FS/PCW/FOLDER02/Z-machine\ support.BIN
	cp anneio.prg ~/Joyce/PcW16FS/PCW/FOLDER02/Z-machine.PRG

pcw16run: pcw16copy
	xanne

disc16.ufi:	disc16_0.ufi anneio.prg zxzvm.bin
	cp disc16_0.ufi disc16.ufi
	mcopy -oi disc16.ufi anneio.prg ::/pcw/folder01/pcw003.prg
	mcopy -oi disc16.ufi zxzvm.bin  ::/pcw/folder01/pcw000.bin


#
# "make disc" to transfer the Anne programs to a floppy for loading into a
# real PCW16. The "pcw???.???" names will vary depending on which floppy is
# used; these are for the example floppy (disc16.ufi).
#
disc:	anneio.prg zxzvm.bin
	mcopy -noO anneio.prg a:/pcw/folder01/pcw003.prg
	mcopy -noO zxzvm.bin  a:/pcw/folder01/pcw000.bin
#	copy anneio.prg a:\pcw\folder01\pcw003.prg
#	copy zxzvm.bin  a:\pcw\folder01\pcw000.bin

clean:
	rm -f zxzvm.tap resizvm.tap zxvm.tap resivm.tap zxfnt32.tap \
		zxfnt323.tap zxio.tap resiio.tap \
		zxzvm.tzx resizvm.tzx \
                anneio.prg joyceio.com pcwzvm.com zxzvm.bin \
                ${ZXGENFNT} ${JOYGENFNT} \
                xbm2zsm *.sym *.zip

srctar:	${ZXIO} ${ANNEIO} ${JOYCEIO} ${P3IO} ${RESIIO} \
        ${ZXZVM} ${ZXFNT32} ${BASFILES} \
        ${INC} ${XBM} ${CFILES} ${SRCDOC} Makefile \
	${DOCS} disc16_0.ufi
	${TAR} ${SRCTAR} ${ZXIO} ${ANNEIO} ${JOYCEIO} ${P3IO} ${RESIIO} \
        ${ZXZVM} ${ZXFNT32} ${BASFILES} \
        ${INC} ${XBM} ${CFILES} ${SRCDOC} Makefile \
	${DOCS} disc16_0.ufi

bintar:	zxzvm.tap resizvm.tap zxzvm.tzx resizvm.tzx \
	pcwzvm.com disc16.ufi ${DOCS}
	${TAR} ${BINTAR} zxzvm.tap resizvm.tap zxzvm.tzx resizvm.tzx \
	pcwzvm.com disc16.ufi zxzvm.bin ${DOCS}

joyfont3.zsm:	joyfont3.xbm xbm2zsm
	./xbm2zsm joyfont3.xbm 32 > joyfont3.zsm

joyfonta.zsm:	joyfonta.xbm xbm2zsm
	./xbm2zsm joyfonta.xbm 32 > joyfonta.zsm

zxfont64.zsm:	zxfont64.xbm xbm2zsm
	./xbm2zsm zxfont64.xbm 64 > zxfont64.zsm

zxfnt643.zsm:	zxfnt643.xbm xbm2zsm
	./xbm2zsm zxfnt643.xbm 64 > zxfnt643.zsm

xbm2zsm: xbm2zsm.c
	${CC} ${CFLAGS} -o xbm2zsm xbm2zsm.c
