;Program compiled by Great Cow BASIC (0.98.06 2019-06-12 (Darwin 64 bit))
;Need help? See the GCBASIC forums at http://sourceforge.net/projects/gcbasic/forums,
;check the documentation or email w_cholmondeley at users dot sourceforge dot net.

;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=16F18875, r=DEC
#include <P16F18875.inc>
 __CONFIG _CONFIG1, _CLKOUTEN_OFF & _RSTOSC_HFINT32 & _FEXTOSC_OFF
 __CONFIG _CONFIG2, _MCLRE_OFF
 __CONFIG _CONFIG3, _WDTE_OFF
 __CONFIG _CONFIG4, _LVP_OFF
 __CONFIG _CONFIG5, _CP_OFF

;********************************************************************************

;Set aside memory locations for variables
DELAYTEMP	EQU	112
DELAYTEMP2	EQU	113
LCDBYTE	EQU	32
LCDREADY	EQU	33
LCD_STATE	EQU	34
SYSLCDTEMP	EQU	35
SYSREPEATTEMP1	EQU	36
SYSWAITTEMP10US	EQU	117
SYSWAITTEMPMS	EQU	114
SYSWAITTEMPMS_H	EQU	115
SYSWAITTEMPS	EQU	116
SYSWAITTEMPUS	EQU	117
SYSWAITTEMPUS_H	EQU	118

;********************************************************************************

;Vectors
	ORG	0
	pagesel	BASPROGRAMSTART
	goto	BASPROGRAMSTART
	ORG	4
	retfie

;********************************************************************************

;Start of program memory page 0
	ORG	5
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS
	call	INITLCD

;Start of the main program
	bcf	TRISD,3
	bcf	TRISD,2
	bcf	TRISD,0
	bcf	TRISD,1
	bsf	TRISA,1
//	#DEFINE	4 4 ;?F1L17S0I17?
//	#DEFINE	SYSLCDTEMP.1 PORTB.0 ;?F1L18S0I18?
//	#DEFINE	SYSLCDTEMP.0 PORTB.1 ;?F1L19S0I19?
//	#DEFINE	SYSLCDTEMP.0 PORTB.2 ;?F1L20S0I20?
//	#DEFINE	LCD_D4 PORTB.4 ;?F1L21S0I21?
//	#DEFINE	LCD_D5 PORTB.5 ;?F1L22S0I22?
//	#DEFINE	LCD_D6 PORTB.6 ;?F1L23S0I23?
//	#DEFINE	LCD_D7 PORTB.7 ;?F1L24S0I24?
//	#DEFINE	LCD_LINES 2 ;?F1L25S0I25?
//	#DEFINE	20 16 ;?F1L26S0I26?
//	#DEFINE	LCD_SPEED FAST ;?F1L27S0I27?
//	DIR	SYSLCDTEMP.1 OUT ;?F1L29S0I29?
//	DIR	SYSLCDTEMP.0 OUT ;?F1L30S0I30?
//	DIR	SYSLCDTEMP.0 OUT ;?F1L31S0I31?
//	DIR	LCD_D4 OUT ;?F1L32S0I32?
//	DIR	LCD_D5 OUT ;?F1L33S0I33?
//	DIR	LCD_D6 OUT ;?F1L34S0I34?
//	DIR	LCD_D7 OUT ;?F1L35S0I35?
	bcf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bcf	LATD,1
	call	FW
SysDoLoop_S1
	btfsc	PORTA,1
	goto	ENDIF1
	call	BW
	movlw	1
	movwf	SysWaitTempS
	call	Delay_S
	call	FW
ENDIF1
//	CLS	;?F1L84S0I14?
//	LOCATE	0, 0 ;?F1L85S0I15?
//	PRINT	;STRING1; ;?F1L86S0I16?
	goto	SysDoLoop_S1
SysDoLoop_E1
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

BW
	bcf	LATD,3
	bsf	LATD,2
	bcf	LATD,0
	bsf	LATD,1
	return

;********************************************************************************

CLS
	bcf	SYSLCDTEMP,1
	movlw	1
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	4
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	movlw	128
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	12
	movwf	SysWaitTemp10US
	goto	Delay_10US

;********************************************************************************

Delay_10US
D10US_START
	movlw	25
	movwf	DELAYTEMP
DelayUS0
	decfsz	DELAYTEMP,F
	goto	DelayUS0
	nop
	decfsz	SysWaitTemp10US, F
	goto	D10US_START
	return

;********************************************************************************

Delay_MS
	incf	SysWaitTempMS_H, F
DMS_START
	movlw	14
	movwf	DELAYTEMP2
DMS_OUTER
	movlw	189
	movwf	DELAYTEMP
DMS_INNER
	decfsz	DELAYTEMP, F
	goto	DMS_INNER
	decfsz	DELAYTEMP2, F
	goto	DMS_OUTER
	decfsz	SysWaitTempMS, F
	goto	DMS_START
	decfsz	SysWaitTempMS_H, F
	goto	DMS_START
	return

;********************************************************************************

Delay_S
DS_START
	movlw	232
	movwf	SysWaitTempMS
	movlw	3
	movwf	SysWaitTempMS_H
	call	Delay_MS
	decfsz	SysWaitTempS, F
	goto	DS_START
	return

;********************************************************************************

FW
	bsf	LATD,3
	bcf	LATD,2
	bsf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

INITLCD
	bcf	TRISSYSLCDTEMP,1
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
SysWaitLoop1
	call	FN_LCDREADY
	movf	LCDREADY,F
	btfsc	STATUS,Z
	goto	SysWaitLoop1
	bcf	SYSLCDTEMP,1
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	movlw	15
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	bsf	SYSLCDTEMP,0
	bsf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS1
	decfsz	DELAYTEMP,F
	goto	DelayUS1
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS2
	decfsz	DELAYTEMP,F
	goto	DelayUS2
	bcf	SYSLCDTEMP,0
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	movlw	3
	movwf	SysRepeatTemp1
SysRepeatLoop1
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS3
	decfsz	DELAYTEMP,F
	goto	DelayUS3
	bcf	SYSLCDTEMP,0
	movlw	2
	movwf	DELAYTEMP2
DelayUSO4
	clrf	DELAYTEMP
DelayUS4
	decfsz	DELAYTEMP,F
	goto	DelayUS4
	decfsz	DELAYTEMP2,F
	goto	DelayUSO4
	movlw	19
	movwf	DELAYTEMP
DelayUS5
	decfsz	DELAYTEMP,F
	goto	DelayUS5
	decfsz	SysRepeatTemp1,F
	goto	SysRepeatLoop1
SysRepeatLoopEnd1
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	bcf	SYSLCDTEMP,0
	bsf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS6
	decfsz	DELAYTEMP,F
	goto	DelayUS6
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS7
	decfsz	DELAYTEMP,F
	goto	DelayUS7
	bcf	SYSLCDTEMP,0
	movlw	133
	movwf	DELAYTEMP
DelayUS8
	decfsz	DELAYTEMP,F
	goto	DelayUS8
	movlw	40
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	6
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	12
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	call	CLS
	movlw	12
	movwf	LCD_STATE
	return

;********************************************************************************

INITSYS
;osccon type is 100
	movlw	96
	banksel	OSCCON1
	movwf	OSCCON1
	clrf	OSCCON3
	clrf	OSCEN
	clrf	OSCTUNE
;the mcu is a chip family 15
;osccon type is 102
	movlw	6
	movwf	OSCFRQ
	banksel	ADCON0
	bcf	ADCON0,ADFRM0
	bcf	ADCON0,ADON
	banksel	ANSELA
	clrf	ANSELA
	clrf	ANSELB
	clrf	ANSELC
	clrf	ANSELD
	clrf	ANSELE
	banksel	CM2CON0
	bcf	CM2CON0,C2ON
	bcf	CM1CON0,C1ON
	banksel	PORTA
	clrf	PORTA
	clrf	PORTB
	clrf	PORTC
	clrf	PORTD
	clrf	PORTE
	return

;********************************************************************************

LCDNORMALWRITEBYTE
SysWaitLoop2
	call	FN_LCDREADY
	movf	LCDREADY,F
	btfsc	STATUS,Z
	goto	SysWaitLoop2
	bcf	SYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	TRISSYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	btfsc	LCDBYTE,7
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,6
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,5
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,4
	bsf	SYSLCDTEMP,0
	movlw	2
	movwf	DELAYTEMP
DelayUS9
	decfsz	DELAYTEMP,F
	goto	DelayUS9
	nop
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS10
	decfsz	DELAYTEMP,F
	goto	DelayUS10
	bcf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS11
	decfsz	DELAYTEMP,F
	goto	DelayUS11
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	btfsc	LCDBYTE,3
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,2
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,1
	bsf	SYSLCDTEMP,0
	btfsc	LCDBYTE,0
	bsf	SYSLCDTEMP,0
	movlw	2
	movwf	DELAYTEMP
DelayUS12
	decfsz	DELAYTEMP,F
	goto	DelayUS12
	nop
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS13
	decfsz	DELAYTEMP,F
	goto	DelayUS13
	bcf	SYSLCDTEMP,0
	movlw	5
	movwf	DELAYTEMP
DelayUS14
	decfsz	DELAYTEMP,F
	goto	DelayUS14
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	bcf	SYSLCDTEMP,0
	movlw	213
	movwf	DELAYTEMP
DelayUS15
	decfsz	DELAYTEMP,F
	goto	DelayUS15
	btfsc	SYSLCDTEMP,1
	goto	ENDIF13
	movlw	16
	subwf	LCDBYTE,W
	btfsc	STATUS, C
	goto	ENDIF14
	movf	LCDBYTE,W
	sublw	7
	btfsc	STATUS, C
	goto	ENDIF15
	movf	LCDBYTE,W
	movwf	LCD_STATE
ENDIF15
ENDIF14
ENDIF13
	return

;********************************************************************************

FN_LCDREADY
	clrf	LCDREADY
	bcf	SYSLCDTEMP,2
	btfsc	SYSLCDTEMP,1
	bsf	SYSLCDTEMP,2
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bcf	SYSLCDTEMP,1
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bsf	SYSLCDTEMP,0
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bsf	TRISSYSLCDTEMP,0
	btfsc	SYSLCDTEMP,0
	goto	ENDIF2
	movlw	255
	movwf	LCDREADY
ENDIF2
	bcf	SYSLCDTEMP,0
	movlw	25
	movwf	SysWaitTemp10US
	call	Delay_10US
	bcf	SYSLCDTEMP,1
	btfsc	SYSLCDTEMP,2
	bsf	SYSLCDTEMP,1
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
