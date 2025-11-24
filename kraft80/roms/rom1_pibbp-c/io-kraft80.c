/*
IO-KRAFT80.C
Support routines for the KRAFT 80
2025 - ARM Coder
LCD control functions by Wagner Rambo - WR Kits - wrkits.com.br
*/

#include <stdio.h>
#include "io-kraft80.h"

unsigned char dispcol = 0;

////////////////////////////////////////////////////////////////////////////////
char *lgets_noecho(char *buf, int bufsize){

    int i = 0;
    char a;
    for (;;){
    
        a = getchar();

        if (a == 0x0d){
            buf[i] = 0;
            return buf;
        }

        if (a == 0x08){
            if (i) --i;
            continue;
        }

        //if (i >= ' '){
            buf[i] = a;
            if (i < (bufsize-1))
                ++i;
        //}
    }
}

////////////////////////////////////////////////////////////////////////////////
char *lgets(char *buf, int bufsize){

    int i = 0;
    char a;
    for (;;){
    
        a = getchar();
        putchar(a);
        if (a == 0x0d){
            buf[i] = 0;
            return buf;
        }
        if (a == 0x08){
            if (i) --i;
            continue;
        }
        buf[i] = a;
        if (i < (bufsize-1))
            ++i;
    }
}

////////////////////////////////////////////////////////////////////////////////
void putstr(char *s){

    while(*s){
        putchar(*(s++));
    }
}
	
////////////////////////////////////////////////////////////////////////////////
int putchar_lcd (char a) __naked{
    __asm

    ld b,a
    call lcd_write
    ld l,#0
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void putstr_lcd(char *s){

    while(*s){
        putchar_lcd(*(s++));
    }
}

	
////////////////////////////////////////////////////////////////////////////////
int getchar() __naked{

    __asm

    rst #0x10
    jr z,_getchar
    ld e,a
    ld d,#0
    ret
    
    __endasm;
}
	
	
////////////////////////////////////////////////////////////////////////////////
int putchar (int a) __naked{

    __asm

    ld a,l
    rst #0x08
    ld l,#0
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void setleds(char leds) __naked{

    __asm

PORTA .equ 0x00

    out(PORTA),a
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
unsigned char readbuttons() __naked{

    __asm
PORTX .equ 0x00
    
    in a,(PORTX)
    ld l,a
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void d1ms() __naked{

    __asm

;d1ms:                 ; 4.25µs  17 T States (call)
    push bc           ; 2.75µs  11 T States 
    ld b,#0xDB         ; 1.75 µs  7 T States 
dloop:
    dec b             ; 1.0µs    4 T States 
    nop               ; 1.0µs    4 T States 
    jp nz,dloop       ; 2.5µs   10 T States 								
    pop bc            ; 2.5µs   10 T States 
    ret               ; 2.5µs   10 T States 

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void dx1ms() __naked{

    __asm
    
    call _d1ms         ; 1ms (delay time)
    dec d             ; 1.0µs    4 T States 
    jp nz,_dx1ms       ; 2.5µs   10 T States 		
    ret               ; 2.5µs   10 T States 

    __endasm;
}


////////////////////////////////////////////////////////////////////////////////
void d100ms() __naked{

    __asm

;d100ms:               ; 4.25µs  17 T States
    push bc           ; 2.75µs  11 T States 
    ld b,#0x97          ; 1.75µs   7 T States 
aux1:
    ld c,#0xBD         ; 1.75µs   7 T States 
aux2:
    dec c             ; 1.0µs    4 T States 
    jp nz,aux2        ; 2.5µs   10 T States 
    dec b             ; 1.0µs    4 T States 
    jp nz,aux1        ; 2.5µs   10 T States 
    pop bc            ; 2.5µs   10 T States 
    ret               ; 2.5µs   10 T States 

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void dx100ms() __naked{

    __asm

;dx100ms: 
    call _d100ms       ; 1ms (delay time)
    dec d             ; 1.0µs    4 T States 
    jp nz,_dx100ms     ; 2.5µs   10 T States 	
    ret						; 2.5µs   10 T States 

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void send_nibble() __naked{

    __asm

RS    .equ 0x01
EN    .equ 0x01
PORTB .equ 0x10

;send_nibble:
    ld a,#0x00          ;zera conteúdo de ACC
    bit 0,c           ;bit 0 de c em LOW?
    jp z,rs_clr       ;sim, desvia para manter RS limpo
    ld a,#0x00|RS       ;não, seta bit RS
rs_clr:
    bit 7,b           ;bit7 de B em LOW?
    jp z,b6aval       ;sim, desvia para avaliar bit6
    set 7,a           ;não, seta bit 7 de acc
b6aval:
    bit 6,b           ;bit6 de B em LOW?
    jp z,b5aval       ;sim, desvia para avaliar bit5
    set 6,a           ;não, seta bit 6 de acc
b5aval:
    bit 5,b           ;bit5 de B em LOW?
    jp z,b4aval       ;sim, desvia para avaliar bit4
    set 5,a           ;não, seta bit 5 de acc
b4aval:
    bit 4,b           ;bit4 de B em LOW?
    jp z,lcd_en       ;sim, desvia para pulso de enable
    set 4,a           ;não, set bit 4 de acc
lcd_en:
    set EN,a          ;pino enable em HIGH
    out (PORTB),a     ;escreve no PORTB 
    ld d,#2            ;carrega 2d em d 
    call _dx1ms        ;aguarda 2ms 
    res EN,a          ;pino enable em LOW 
    out (PORTB),a     ;escreve no PORTB 
    ld d,#2            ;carrega 2d em d
    call _dx1ms        ;aguarda 2ms 		
    ret               ;retorno da sub-rotina

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_cmd() __naked{

    __asm
    
;lcd_cmd:
    ld c,#0x00
    jr send_byte
lcd_write:

    ld a,(_dispcol)
    cp #16
    jr nz,lcd_w1
    call _lcd_home2
    jr lcd_w2
lcd_w1:
    cp #32
    jr nz,lcd_w2
    call _lcd_home
lcd_w2:
    ld a,(_dispcol)
    inc a
    ld (_dispcol),a
    ld c,#0x01        ;01h para envio de caracteres
send_byte:		
    call _send_nibble ;envia nibble mais significativo
    ld a,b            ;carrega conteúdo de b em acc
    rla               ;rotaciona acc para esquerda 4x
    rla               ;
    rla               ;
    rla               ;
    and #0xF0          ;máscara para preservar nibble mais significativo
    ld b,a            ;atualiza b
    call _send_nibble  ;envia nibble menos significativo
    ret						;retorno da sub-rotina

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_home() __naked{

    __asm
    
;lcd_home:
    push bc
    ld b,#0x02        ;return home
    call _lcd_cmd     ;envia 02h para o LCD
    push af
    xor a
    ld (_dispcol),a
    pop af
    pop bc
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_home2() __naked{

    __asm

;lcd_home2:
    push bc
    ld b,#0xC0         ;posiciona cursor na linha 1, coluna 0
    call _lcd_cmd      ;envia comando
    push af
    ld a,#16
    ld (_dispcol),a
    pop af
    pop bc
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_clear() __naked{

    __asm

;lcd_clear:
    ;ld b,#0x02       ;return home
    ;call _lcd_cmd     ;envia 02h para o LCD
    call _lcd_home
    ld b,#0x01        ;limpa o display
    call _lcd_cmd     ;envia 01h para o LCD
    xor a
    ld (_dispcol),a
    ret               ;retorno da sub-rotina		

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_beg2() __naked{

    __asm

    ld d,#2            ;carrega 2d em d 
    call _dx100ms      ;aguarda 500ms 				
    ld b,#0x0C          ;desliga cursor e blink 
    call _lcd_cmd      ;envia comando 
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_begin() __naked{

    __asm
    
    ld d,#50           ;carrega 50d em d 
    call _dx1ms        ;tempo para estabilização (50ms)
    ld b,#0x30          ;protocolo de inicialização
    ld c,#0x00          ;envio de comando
    call _send_nibble  ;envia 30h para o LCD
    ld d,#5            ;carrega 5d em d 
    call _dx1ms        ;aguarda 5ms (tempo superior ao datasheet)
    ld b,#0x30          ;protocolo de inicialização
    ld c,#0x00          ;envio de comando
    call _send_nibble  ;envia 30h para o LCD		
    call _d1ms         ;aguarda 1ms (tempo superior ao datasheet)
    ld b,#0x30          ;protocolo de inicialização
    ld c,#0x00          ;envio de comando
    call _send_nibble  ;envia 30h para o LCD
    ld b,#0x20          ;LCD no modo 4 bits
    ld c,#0x00          ;envio de comando
    call _send_nibble  ;envia 30h para o LCD
    ld b,#0x28          ;5x8 pontos por caractere, duas linhas
    call _lcd_cmd      ;envia comando 28h
    ld b,#0x0F          ;liga display, cursor e blink
    call _lcd_cmd      ;envia comando 0Fh
    ld b,#0x01          ;limpa LCD
    call _lcd_cmd      ;envia comando 01h
    ld b,#0x06          ;modo de incremento de endereço para direita, movendo apenas o cursor 
    call _lcd_cmd      ;envia comando 06h
    call _lcd_clear    ;limpa o display
    call _lcd_beg2
    ret               ;retorno da sub-rotina

    __endasm;
}

