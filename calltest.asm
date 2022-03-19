    org 40000;
    call $45F0; path to IX

loop:
    ld a, (ix);
    cp 13; carriage return?
    ret z; return if so 
    rst $10; print a character
    jr loop;
