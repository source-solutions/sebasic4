/*
 */
MEMORY 
{
    rom    : ORIGIN = 0x0000,          LENGTH = 0x4000

    /* 0x1b08 is used instead of 0x1b00 because some space is used after the
     * screen for snapshot file storage.... When creating _real_ speccy progs
     * loaded from tape/tzx then this space can be reclaimed. Though we're
     * only talking about 8 bytes....
     */
}

SECTIONS 
{
      . = 0x0;

      /* Define location of section .startup at beginning of usable 16K space
       */
      .text : 
      { 
          *(.text)
      } >rom

}
_end = .;
__bss_end__ = .; 

__end__ = . ;

PROVIDE (end = .);
/* end */
