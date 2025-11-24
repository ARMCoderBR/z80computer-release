; =============================================================================
;
;   KRAFT 80 Z80 Computer
;   Monitor Program for the Kraft 80 computer
;   2025-May-08
;   Milton Maldonado Jr. (ARMCoder)
;
;   This hardware+software project was based on the project quoted below:
;
;   ==QUOTE============================
;   " Z80 WR Kits Microcomputer       "
;   " Monitor Program for Alpha Z80   " 
;   "                                 "
;   " amon\amon.asm                   "
;   " Input  PORTX address 01h        "
;   " Output PORTA address 02h        "
;   " Output PORTB address 04h        "
;   "                                 "
;   " 2816 EEPROM  2kB  0000h - 07FFh "
;   " 6116 SRAM    2kB  0800h - 0FFFh "
;   "                                 "
;   "                                 "
;   " Compiler: Tasm                  "
;   "                                 "
;   " Author: Dr. Eng. Wagner Rambo   "
;   " Date:   2025, January           "       
;   =========================ENDQUOTE==
;
; =============================================================================


; =============================================================================
; --- Hardware Mapping ---
PORTX           .equ 0x00 ;PORTX address (Read) 
PORTA           .equ 0x00 ;PORTA address (Write)
PORTB           .equ 0x10 ;PORTB address (Write)
EN		.equ	0x01				;LCD enable pin (PORTB bit 1)
RS		.equ	0x01				;LCD RS pin (uses or logic)

ROMBASE         .equ 0
ROMSZ           .equ 0x2000
RAMBASE         .equ 0x2000
RAMSZ           .equ 0xE000

; =============================================================================
; --- General Purpose Registers ---
AUX 	 .equ	(RAMBASE+RAMSZ - 1)	;auxiliar para armazenamento 
WR_RD	 .equ	(RAMBASE+RAMSZ - 2)	;registrador de escrita '1' / leitura '0' 
STACKTOP .equ	(RAMBASE+RAMSZ - 2)

; =============================================================================
; --- Reset Vector ---

    .area	_HEADER (ABS)

		.org	0x0000			;origem no endereço 00h de memória
	

; =============================================================================
; --- Main Program ---
begin:

		ld	sp,#STACKTOP		;pilha de memória 
		call	lcd_begin		;inicializa LCD no modo 4 bits		
		ld	d,#2			;carrega 2d em d 
		call	dx100ms			;aguarda 500ms 				
		ld	b,#0x0C			;desliga cursor e blink 
		call	lcd_cmd 		;envia comando 
		call	msg_init 		;escreve título "Alpha Z80" 
		ld	d,#10			;carrega 10d em d 
		call	dx100ms			;aguarda 1 seg. 
		
		ld	a,#0x00			;carrega acc com 00h 
		ld	(WR_RD),a 		;zera registrador de escrita/leitura para iniciar em modo leitura 
		
		ld	hl,#RAMBASE		;endereço inicial da RAM é carregado no par hl
		call	exmem			;exibe endereço e respectivo conteúdo no LCD "examine memory"
		
loop:
		call	read_keyb 		;chama sub-rotina para leitura do teclado 
		jr	loop 			;ad infinitum 


; =============================================================================
; --- Sub-Rotinas ---


; =============================================================================
; --- read_keyb ---
read_keyb:
		in 		a,(PORTX)		;lê o conteúdo de PORTX 
		bit		7,a				;bit 7 ativo?
		jp		z,px7			;sim, desvia para label px7
		bit		6,a				;não, bit 6 ativo?
		jp		z,px6			;sim, desvia para label px6
		bit		5,a				;não, bit 5 ativo?
		jp		z,px5			;sim, desvia para label px5
		bit		4,a				;não, bit 4 ativo?
		jp		z,px4			;sim, desvia para label px4	
		bit		3,a				;bit 3 ativo?
		jp		z,px3			;sim, desvia para label px3
		bit		2,a				;não, bit 2 ativo?
		jp		z,px2			;sim, desvia para label px2
		bit		1,a				;não, bit 1 ativo?
		jp		z,px1			;sim, desvia para label px1
		bit		0,a				;não, bit 0 ativo?
		jp		z,px0			;sim, desvia para label px0
		ret 					;retorna, se nenhum botão estiver pressionado


px7:							;incrementa nibble mais significativo do endereço / seta dado com o valor 88h
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,SET_88H		;se for 01h (escrita), desvia para SET_88H 
		ld		de,#0x100		;do contrário é modo leitura: carrega 100h no par de 
		add		hl,de 			;incrementa o par hl (endereço atual) em 10h 
		jp		final_kb		;desvia para saída da sub-rotina
		
SET_88H:
		ld		(hl),#0x88
		jp		final_kb		;desvia para saída da sub-rotina
		
		
px6:							;incrementa segundo nibble do endereço / incrementa nibble mais significativo do dado 
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,INC_DTH		;se for 01h (escrita), desvia para INC_DTH
		ld		de,#0x10		;do contrário é modo leitura: carrega 10h no par de 
		add		hl,de 			;incrementa o par hl (endereço atual) em 10h 
		jp		final_kb		;desvia para saída da sub-rotina 
		
INC_DTH:						;incrementa dado HIGH 
		ld		a,(hl)			;carrega conteúdo do endereço atual em acc
		add		a,#0x10			;incrementa nibble mais significativo do dado 
		ld		(hl),a			;escreve na memória 
		jp		final_kb		;desvia para saída da sub-rotina 
		
		
px5:							;incrementa nibble menos significativo do endereço / incrementa nibble menos significativo do dado 
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,INC_DTL		;se for 01h (escrita), desvia para INC_DTL 
		inc		hl				;do contrário é modo leitura: incrementa endereço 
		jr		final_kb		;desvia para saída da sub-rotina

INC_DTL:						;incrementa dado LOW 
		ld		a,(hl)			;carrega conteúdo do endereço atual em acc
		inc		a				;incrementa nibble menos significativo do dado 
		ld		(hl),a			;escreve na memória 
		jr		final_kb		;desvia para saída da sub-rotina 
	
	
px4:							;alterna entre o modo leitura/escrita 
		ld		a,(WR_RD)		;carrega acc com valor de WR_RD
		xor		#0x01			;inverte bit menos significativo de acc
		ld		(WR_RD),a		;inverte bit menos sig. de WR_RD
		jr		final_kb		;desvia para saída da sub-rotina
		
		
px3:							;decrementa nibble mais significativo do endereço / seta dado com o valor 00h 	
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,SET_00H		;se for 01h (escrita), desvia para SET_00H 	
		ld		de,#0x100		;carrega 100h no par de 
		sbc		hl,de 			;decrementa o par hl (endereço atual) em 100h 
		jr		final_kb		;desvia para saída da sub-rotina

SET_00H:
		ld		(hl),#0x00
		jr		final_kb		;desvia para saída da sub-rotina
	
	
px2:							;decrementa segundo nibble do endereço / decrementa nibble mais significativo do dado 
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,DEC_DTH		;se for 01h (escrita), desvia para WR_NH
		ld		de,#0x10		;do contrário é modo leitura: carrega 10h no par de 
		sbc		hl,de 			;decrementa o par hl (endereço atual) em 10h 
		jr		final_kb		;desvia para saída da sub-rotina 

DEC_DTH:						;decrementa dado HIGH 		
		ld		a,(hl)			;carrega conteúdo do endereço atual em acc
		sbc		a,#0x10			;decrementa nibble mais significativo do dado 
		ld		(hl),a			;escreve na memória 
		jr		final_kb		;desvia para saída da sub-rotina
		
		
px1:
		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,DEC_DTL		;se for 01h (escrita), desvia para DEC_DTL 
		dec 	hl				;do contrário é modo leitura: decrementa endereço 
		jr		final_kb		;desvia para saída da sub-rotina  

DEC_DTL:						;decrementa dado LOW 
		ld		a,(hl)			;carrega conteúdo do endereço atual em acc
		dec		a				;decrementa nibble menos significativo do dado 
		ld		(hl),a			;escreve na memória 
		jr		final_kb		;desvia para saída da sub-rotina 
		
		
px0:							;roda o software contido na RAM 
		ld		b,#' '			;escreve "run"...
		call	lcd_write		; ...
		ld		b,#'r'			; ...
		call	lcd_write		; ...
		ld		b,#'u'			; ...
		call	lcd_write		; ...
		ld		b,#'n'			; ...
		call	lcd_write		; no lcd
		call	RAMBASE			;roda o programa a partir do endereço inicial da RAM


final_kb:
		call	exmem 			;exibe memória atual
		ld		d,#2				;carrega d com 2 
		call	dx100ms			;anti-bouncing (200ms)			 		
		ret 					;retorna da sub-rotina 


; =============================================================================
; --- exmem: Examine Memory ---
; --- Gera linha 1 do programa monitor no formato:
;     0000h: 00h R                                   ---
exmem:
		call	lcd_clear		;limpa lcd
		ld		a,h				;armazena byte HIGH de endereço em acc
		call	lcd_hex			;mostra em hexadecimal
		ld		a,l				;armazena byte LOW de endereço em acc
		call	lcd_hex			;mostra em hexadecimal
		ld		b,#'h'			;armazena byte 'h' no acc
		call	lcd_write		;escreve no lcd
		ld		b,#':'			;armazena byte ':' no acc
		call	lcd_write		;escreve no lcd
		ld		b,#' '			;armazena byte ' ' no acc
		call	lcd_write		;escreve no lcd
		ld		a,(hl)			;armazena conteúdo do endereço atual em acc
		call	lcd_hex			;mostra em hexadecimal
		ld		b,#'h'			;armazena byte 'h' no acc
		call	lcd_write		;escreve no lcd
		ld		b,#' '			;armazena byte ' ' no acc
		call	lcd_write		;escreve no lcd

		ld		a,(WR_RD)		;carrega registrador de escrita/leitura em acc
		cp		#0x00			;compara com 00h
		jp		nz,WR_MODE		;se for 01h (escrita), desvia para WR_MODE
		ld		b,#'R'			;do contrário, informa que é modo leitura
		call	lcd_write		;escreve no display
		ret						;retorna da sub-rotina

WR_MODE:
		ld		b,#'W'			;informa que é modo escrita
		call	lcd_write		;escreve no display
		ret						;retorna da sub-rotina


;=======================================================
; --- Exibe conteúdo em hexadecimal no LCD ---
lcd_hex:
		ld		(AUX),a			;armazena cópia do acc na RAM
		rra						;rotação de acc 4x para...
		rra						; a direita para separar...
		rra						; o nibble mais...
		rra						; significativo
		and		#0x0F				;preserva o nibble mais sig. na posição menos sig.
		cp		#0x0A				;compara acc com 0Ah
		jp		nc,gt9H			;se não houve carry, acc > 9 e desvia para gt9H
		add		a,#0x30			;do contrário, acc <= 9 e soma 30h para o '0' da ASCII
		jr		nibbleL			;desvia para calcular nibble menos significativo
gt9H:
		add		a,#0x37			;soma 37h para o 'A' da ASCII (41h - 0Ah) 
nibbleL:
		ld		b,a				;carrega b com acc
		call	lcd_write		;escreve nibble mais significativo no display
		ld		a,(AUX)			;recupera acc da RAM
		and		#0x0F			;preserva nibble menos sig.
		cp		#0x0A			;compara acc com 0Ah
		jp		nc,gt9L			;se não houve carry, acc > 9 e desvia para gt9L
		add		a,#0x30			;do contrário, acc <= 9 e soma 30h para o '0' da ASCII
		jr		data_end		;desvia para finalizar escrita do dado
gt9L:
		add		a,#0x37			;soma 37h para o 'A' da ASCII (41h - 0Ah)
data_end:
		ld		b,a				;carrega b com acc
		call	lcd_write		;escreve nibble menos significativo no display
		ret						;retorno da sub-rotina


; =============================================================================
; --- Inicializa LCD modo de 4 bits ---
lcd_begin:
		ld		d,#50		;carrega 50d em d 
		call	dx1ms			;tempo para estabilização (50ms)
		ld		b,#0x30		;protocolo de inicialização
		ld		c,#0x00		;envio de comando
		call	send_nibble		;envia 30h para o LCD
		ld		d,#5		;carrega 5d em d 
		call	dx1ms			;aguarda 5ms (tempo superior ao datasheet)
		ld		b,#0x30		;protocolo de inicialização
		ld		c,#0x00		;envio de comando
		call	send_nibble		;envia 30h para o LCD		
		call	d1ms 			;aguarda 1ms (tempo superior ao datasheet)
		ld		b,#0x30		;protocolo de inicialização
		ld		c,#0x00		;envio de comando
		call	send_nibble		;envia 30h para o LCD
		ld		b,#0x20		;LCD no modo 4 bits
		ld		c,#0x00		;envio de comando
		call	send_nibble		;envia 30h para o LCD
		ld		b,#0x28		;5x8 pontos por caractere, duas linhas
		call	lcd_cmd			;envia comando 28h
		ld		b,#0x0F		;liga display, cursor e blink
		call	lcd_cmd			;envia comando 0Fh
		ld		b,#0x01		;limpa LCD
		call	lcd_cmd			;envia comando 01h
		ld		b,#0x06		;modo de incremento de endereço para direita, movendo apenas o cursor 
		call	lcd_cmd			;envia comando 06h
		call	lcd_clear		;limpa o display
		ret						;retorno da sub-rotina
		

; =============================================================================
; --- Envia Comandos / Escreve no LCD ---
lcd_cmd:
		ld		c,#0x00
		jr		send_byte
lcd_write:
		ld		c,#0x01			;01h para envio de caracteres
send_byte:		
		call	send_nibble		;envia nibble mais significativo
		ld		a,b				;carrega conteúdo de b em acc
		rla						;rotaciona acc para esquerda 4x
		rla						;
		rla						;
		rla						;
		and		#0xF0			;máscara para preservar nibble mais significativo
		ld		b,a				;atualiza b
		call	send_nibble		;envia nibble menos significativo
		ret						;retorno da sub-rotina
		

;==============================================================================
; --- Envia cada nibble separadamente e gera pulso de enable ---
send_nibble:
		ld		a,#0x00			;zera conteúdo de ACC
		bit		0,c				;bit 0 de c em LOW?
		jp		z,rs_clr		;sim, desvia para manter RS limpo
		ld		a,#(0x00|RS)		;não, seta bit RS
rs_clr:
		bit		7,b				;bit7 de B em LOW?
		jp		z,b6aval		;sim, desvia para avaliar bit6
		set		7,a				;não, seta bit 7 de acc
b6aval:
		bit		6,b				;bit6 de B em LOW?
		jp		z,b5aval		;sim, desvia para avaliar bit5
		set		6,a				;não, seta bit 6 de acc
b5aval:
		bit		5,b				;bit5 de B em LOW?
		jp		z,b4aval		;sim, desvia para avaliar bit4
		set		5,a				;não, seta bit 5 de acc
b4aval:
		bit		4,b				;bit4 de B em LOW?
		jp		z,lcd_en		;sim, desvia para pulso de enable
		set		4,a				;não, set bit 4 de acc
lcd_en:
		set		EN,a			;pino enable em HIGH
		out		(PORTB),a		;escreve no PORTB 
		ld		d,#2				;carrega 2d em d 
		call    dx1ms           ;aguarda 2ms 
		res		EN,a			;pino enable em LOW 
		out		(PORTB),a 		;escreve no PORTB 
		ld		d,#2				;carrega 2d em d
		call    dx1ms           ;aguarda 2ms 		
		ret						;retorno da sub-rotina
		

; =============================================================================
; --- Limpa LCD ---
lcd_clear:
		ld		b,#0x02		;return home
		call	lcd_cmd			;envia 02h para o LCD
		ld		b,#0x01		;limpa o display
		call	lcd_cmd			;envia 01h para o LCD
		ret						;retorno da sub-rotina		
		

; =============================================================================
; --- Imprime o título na segunda linha do LCD ---
msg_init:
		ld		b,#0xC0		;posiciona cursor na linha 1, coluna 0
		call	lcd_cmd			;envia comando 
		ld		b,#'A' 			;imprime "Alpha Z80" 
		call	lcd_write 
		ld		b,#'l'
		call 	lcd_write 
		ld		b,#'p'
		call 	lcd_write 
		ld		b,#'h'
		call 	lcd_write 
		ld		b,#'a'
		call 	lcd_write
		ld		b,#' '
		call 	lcd_write 	
		ld		b,#'Z'
		call 	lcd_write 
		ld		b,#'8'
		call 	lcd_write 		
		ld		b,#'0'
		call 	lcd_write 		
		ld		b,#0x80		;posiciona cursor na linha 0, coluna 0
		call	lcd_cmd			;envia comando 
		ret						;retorna da sub-rotina 


; =============================================================================
; --- dx1ms multiplies 1ms delay ---	
dx1ms:				
		call	d1ms			; 1ms (delay time)
		dec 	d 				; 1.0µs    4 T States 
		jp 		nz,dx1ms  		; 2.5µs   10 T States 		
		ret						; 2.5µs   10 T States 


; =============================================================================
; --- aprox. 1ms delay (clock 4MHz) ---
d1ms:							; 4.25µs  17 T States (call)
		push	bc				; 2.75µs  11 T States 
		ld		b,#0xDB			; 1.75 µs  7 T States 
dloop:
		dec		b				; 1.0µs    4 T States 
		nop 					; 1.0µs    4 T States 
		jp		nz,dloop		; 2.5µs   10 T States 								
		pop		bc				; 2.5µs   10 T States 
		ret						; 2.5µs   10 T States 


; =============================================================================
; --- dx100ms multiplies 100ms delay ---	
dx100ms: 
		call	d100ms			; 1ms (delay time)
		dec 	d 				; 1.0µs    4 T States 
		jp 		nz,dx100ms 		; 2.5µs   10 T States 	
		ret						; 2.5µs   10 T States 
		
		
; =============================================================================
; --- aprox. 100ms delay (clock 4MHz) ---
d100ms:							; 4.25µs  17 T States
		push	bc 				; 2.75µs  11 T States 
		ld		b,#0x97			; 1.75µs   7 T States 
aux1:
		ld		c,#0xBD			; 1.75µs   7 T States 
aux2:
		dec		c				; 1.0µs    4 T States 
		jp		nz,aux2 		; 2.5µs   10 T States 
		dec		b 				; 1.0µs    4 T States 
		jp		nz,aux1 		; 2.5µs   10 T States 
		pop		bc 				; 2.5µs   10 T States 
		ret 					; 2.5µs   10 T States 


;=======================================================
; --- Final do Programa ---
		.area _DATA


		
		
