    org $8000

    incbin "example.bin"

    org $8100

dll_init:
    pop hl;                             // get return address

    ld e, l;                            // store it in
    ld d, h;                            // DE

    dec hl;                             // point to init address
    dec hl;                             //
    dec hl;                             //

    push hl;                            // stack it

    ex de, hl;                          // first label to HL

label:
    ld c, (hl);                         // label address to BC
    inc hl;                             //
    ld b, (hl);                         // 

    inc hl;                             // next word

    ld a, c;                            // test for final end marker
    or b;                               //
    jr z, init_patch;                   // jump if so

    ex de, hl;                          // store index pointer in DE
    pop hl;                             // get init address
    push hl;                            // restack it
    add hl, bc;                         // get real addres
    ld c, l;                            // store it in
    ld b, h;                            // BC
    ex de, hl;                          // restore index pointer to HL

patch:
    ld e, (hl);                         // patch address to DE
    inc hl;                             //
    ld d, (hl);                         //

    inc hl;                             // next word

    ld a, e;                            // test for patch end marker
    or d;                               //
    jr z, label;                        // jump if so to do next label

    push hl;                            // store HL
    pop ix;                             // in IX
    pop hl;                             // get init address
    push hl;                            // restack it
    add hl, de;                         // label address to HL
    ld (hl), c;                         // write low byte of label address
    inc hl;                             // address high byte
    ld (hl), b;                         // write high byte of label address
    push ix;                            // restore IX
    pop hl;                             // to HL

    jr patch;                           // loop for next address

init_patch;
    ex de, hl;                          // start address to DE
    pop hl;                             // init address to HL
   
    push hl;                            // restack it

    ld (hl), $c3;                       // jump instruction
    inc hl;                             // next address
    ld (hl), e;                         // low byte of start
    inc hl;                             // next address
    ld (hl), d;                         // high byte of start

    pop hl;                             // unstack init address

    jp (hl);                            // immedaite jump (execute routine)
