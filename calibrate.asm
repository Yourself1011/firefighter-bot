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
I	EQU	32
I_H	EQU	33
LCDBYTE	EQU	34
LCDCOLUMN	EQU	35
LCDLINE	EQU	36
LCDREADY	EQU	37
LCDVALUE	EQU	38
LCDVALUETEMP	EQU	40
LCDVALUE_H	EQU	39
LCD_STATE	EQU	41
SYSBYTETEMPA	EQU	117
SYSBYTETEMPB	EQU	121
SYSBYTETEMPX	EQU	112
SYSCALCTEMPX	EQU	112
SYSCALCTEMPX_H	EQU	113
SYSDIVLOOP	EQU	116
SYSDIVMULTA	EQU	119
SYSDIVMULTA_H	EQU	120
SYSDIVMULTB	EQU	123
SYSDIVMULTB_H	EQU	124
SYSDIVMULTX	EQU	114
SYSDIVMULTX_H	EQU	115
SYSLCDTEMP	EQU	42
SYSREPEATTEMP1	EQU	43
SYSTEMP1	EQU	44
SYSTEMP1_H	EQU	45
SYSWAITTEMP10US	EQU	117
SYSWAITTEMPMS	EQU	114
SYSWAITTEMPMS_H	EQU	115
SYSWAITTEMPS	EQU	116
SYSWAITTEMPUS	EQU	117
SYSWAITTEMPUS_H	EQU	118
SYSWORDTEMPA	EQU	117
SYSWORDTEMPA_H	EQU	118
SYSWORDTEMPB	EQU	121
SYSWORDTEMPB_H	EQU	122
SYSWORDTEMPX	EQU	112
SYSWORDTEMPX_H	EQU	113

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
	bcf	TRISB,0
	bcf	TRISB,1
	bcf	TRISB,2
	bcf	TRISB,4
	bcf	TRISB,5
	bcf	TRISB,6
	bcf	TRISB,7
	bcf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bcf	LATD,1
	movlw	241
	movwf	I
	movlw	255
	movwf	I_H
SysForLoop1
	movlw	25
	addwf	I,F
	movlw	0
	addwfc	I_H,F
	call	CLS
	clrf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
	movf	I,W
	movwf	LCDVALUE
	movf	I_H,W
	movwf	LCDVALUE_H
	call	PRINT117
	call	TURN_RIGHT
	movf	I,W
	movwf	SysWaitTempMS
	movf	I_H,W
	movwf	SysWaitTempMS_H
	call	Delay_MS
	call	HARD_STOP
	movlw	1
	movwf	SysWaitTempS
	call	Delay_S
	call	TURN_LEFT
	movf	I,W
	movwf	SysWaitTempMS
	movf	I_H,W
	movwf	SysWaitTempMS_H
	call	Delay_MS
	call	HARD_STOP
	movlw	2
	movwf	SysWaitTempS
	call	Delay_S
	movf	I,W
	movwf	SysWORDTempA
	movf	I_H,W
	movwf	SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	btfsc	SysByteTempX,0
	goto	SysForLoop1
SysForLoopEnd1
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

CLS
	bcf	LATB,0
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

HARD_STOP
	bsf	LATD,3
	bsf	LATD,2
	bsf	LATD,0
	bsf	LATD,1
	return

;********************************************************************************

INITLCD
	bcf	TRISB,0
	bcf	TRISB,2
	bcf	TRISB,1
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
SysWaitLoop1
	call	FN_LCDREADY
	movf	LCDREADY,F
	btfsc	STATUS,Z
	goto	SysWaitLoop1
	bcf	LATB,0
	bcf	TRISB,4
	bcf	TRISB,5
	bcf	TRISB,6
	bcf	TRISB,7
	bcf	LATB,1
	movlw	15
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	bsf	LATB,4
	bsf	LATB,5
	bcf	LATB,6
	bcf	LATB,7
	movlw	5
	movwf	DELAYTEMP
DelayUS1
	decfsz	DELAYTEMP,F
	goto	DelayUS1
	bsf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS2
	decfsz	DELAYTEMP,F
	goto	DelayUS2
	bcf	LATB,2
	movlw	5
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	movlw	3
	movwf	SysRepeatTemp1
SysRepeatLoop1
	bsf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS3
	decfsz	DELAYTEMP,F
	goto	DelayUS3
	bcf	LATB,2
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
	bcf	LATB,4
	bsf	LATB,5
	bcf	LATB,6
	bcf	LATB,7
	movlw	5
	movwf	DELAYTEMP
DelayUS6
	decfsz	DELAYTEMP,F
	goto	DelayUS6
	bsf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS7
	decfsz	DELAYTEMP,F
	goto	DelayUS7
	bcf	LATB,2
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
	bcf	LATB,1
	bcf	TRISB,4
	bcf	TRISB,5
	bcf	TRISB,6
	bcf	TRISB,7
	bcf	LATB,4
	bcf	LATB,5
	bcf	LATB,6
	bcf	LATB,7
	btfsc	LCDBYTE,7
	bsf	LATB,7
	btfsc	LCDBYTE,6
	bsf	LATB,6
	btfsc	LCDBYTE,5
	bsf	LATB,5
	btfsc	LCDBYTE,4
	bsf	LATB,4
	movlw	2
	movwf	DELAYTEMP
DelayUS9
	decfsz	DELAYTEMP,F
	goto	DelayUS9
	nop
	bsf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS10
	decfsz	DELAYTEMP,F
	goto	DelayUS10
	bcf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS11
	decfsz	DELAYTEMP,F
	goto	DelayUS11
	bcf	LATB,4
	bcf	LATB,5
	bcf	LATB,6
	bcf	LATB,7
	btfsc	LCDBYTE,3
	bsf	LATB,7
	btfsc	LCDBYTE,2
	bsf	LATB,6
	btfsc	LCDBYTE,1
	bsf	LATB,5
	btfsc	LCDBYTE,0
	bsf	LATB,4
	movlw	2
	movwf	DELAYTEMP
DelayUS12
	decfsz	DELAYTEMP,F
	goto	DelayUS12
	nop
	bsf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS13
	decfsz	DELAYTEMP,F
	goto	DelayUS13
	bcf	LATB,2
	movlw	5
	movwf	DELAYTEMP
DelayUS14
	decfsz	DELAYTEMP,F
	goto	DelayUS14
	bcf	LATB,7
	bcf	LATB,6
	bcf	LATB,5
	bcf	LATB,4
	movlw	85
	movwf	DELAYTEMP
DelayUS15
	decfsz	DELAYTEMP,F
	goto	DelayUS15
	btfsc	PORTB,0
	goto	ENDIF18
	movlw	16
	subwf	LCDBYTE,W
	btfsc	STATUS, C
	goto	ENDIF19
	movf	LCDBYTE,W
	sublw	7
	btfsc	STATUS, C
	goto	ENDIF20
	movf	LCDBYTE,W
	movwf	LCD_STATE
ENDIF20
ENDIF19
ENDIF18
	return

;********************************************************************************

FN_LCDREADY
	clrf	LCDREADY
	bcf	SYSLCDTEMP,2
	btfsc	PORTB,0
	bsf	SYSLCDTEMP,2
	bsf	LATB,1
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bcf	LATB,0
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bsf	LATB,2
	movlw	5
	movwf	SysWaitTemp10US
	call	Delay_10US
	bsf	TRISB,7
	btfsc	PORTB,7
	goto	ENDIF7
	movlw	255
	movwf	LCDREADY
ENDIF7
	bcf	LATB,2
	movlw	25
	movwf	SysWaitTemp10US
	call	Delay_10US
	bcf	LATB,0
	btfsc	SYSLCDTEMP,2
	bsf	LATB,0
	return

;********************************************************************************

LOCATE
	bcf	LATB,0
	movf	LCDLINE,W
	sublw	1
	btfsc	STATUS, C
	goto	ENDIF2
	movlw	2
	subwf	LCDLINE,F
	movlw	16
	addwf	LCDCOLUMN,F
ENDIF2
	movf	LCDLINE,W
	movwf	SysBYTETempA
	movlw	64
	movwf	SysBYTETempB
	call	SysMultSub
	movf	LCDCOLUMN,W
	addwf	SysBYTETempX,W
	movwf	SysTemp1
	movlw	128
	iorwf	SysTemp1,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	5
	movwf	SysWaitTemp10US
	goto	Delay_10US

;********************************************************************************

;Overloaded signature: WORD:
PRINT117
	bsf	LATB,0
	clrf	LCDVALUETEMP
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	16
	movwf	SysWORDTempB
	movlw	39
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF3
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	16
	movwf	SysWORDTempB
	movlw	39
	movwf	SysWORDTempB_H
	call	SysDivSub16
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	goto	LCDPRINTWORD1000
ENDIF3
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF4
LCDPRINTWORD1000
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	call	SysDivSub16
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	goto	LCDPRINTWORD100
ENDIF4
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF5
LCDPRINTWORD100
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysDivSub16
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	goto	LCDPRINTWORD10
ENDIF5
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF6
LCDPRINTWORD10
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysDivSub16
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
ENDIF6
	movlw	48
	addwf	LCDVALUE,W
	movwf	LCDBYTE
	goto	LCDNORMALWRITEBYTE

;********************************************************************************

SYSCOMPEQUAL16
	clrf	SYSBYTETEMPX
	movf	SYSWORDTEMPA, W
	subwf	SYSWORDTEMPB, W
	btfss	STATUS, Z
	return
	movf	SYSWORDTEMPA_H, W
	subwf	SYSWORDTEMPB_H, W
	btfss	STATUS, Z
	return
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

SYSCOMPLESSTHAN16
	clrf	SYSBYTETEMPX
	movf	SYSWORDTEMPA_H,W
	subwf	SYSWORDTEMPB_H,W
	btfss	STATUS,C
	return
	movf	SYSWORDTEMPB_H,W
	subwf	SYSWORDTEMPA_H,W
	btfss	STATUS,C
	goto	SCLT16TRUE
	movf	SYSWORDTEMPB,W
	subwf	SYSWORDTEMPA,W
	btfsc	STATUS,C
	return
SCLT16TRUE
	comf	SYSBYTETEMPX,F
	return

;********************************************************************************

SYSDIVSUB16
	movf	SYSWORDTEMPA,W
	movwf	SYSDIVMULTA
	movf	SYSWORDTEMPA_H,W
	movwf	SYSDIVMULTA_H
	movf	SYSWORDTEMPB,W
	movwf	SYSDIVMULTB
	movf	SYSWORDTEMPB_H,W
	movwf	SYSDIVMULTB_H
	clrf	SYSDIVMULTX
	clrf	SYSDIVMULTX_H
	movf	SYSDIVMULTB,W
	movwf	SysWORDTempA
	movf	SYSDIVMULTB_H,W
	movwf	SysWORDTempA_H
	clrf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysCompEqual16
	btfss	SysByteTempX,0
	goto	ENDIF21
	clrf	SYSWORDTEMPA
	clrf	SYSWORDTEMPA_H
	return
ENDIF21
	movlw	16
	movwf	SYSDIVLOOP
SYSDIV16START
	bcf	STATUS,C
	rlf	SYSDIVMULTA,F
	rlf	SYSDIVMULTA_H,F
	rlf	SYSDIVMULTX,F
	rlf	SYSDIVMULTX_H,F
	movf	SYSDIVMULTB,W
	subwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	subwfb	SYSDIVMULTX_H,F
	bsf	SYSDIVMULTA,0
	btfsc	STATUS,C
	goto	ENDIF22
	bcf	SYSDIVMULTA,0
	movf	SYSDIVMULTB,W
	addwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	addwfc	SYSDIVMULTX_H,F
ENDIF22
	decfsz	SYSDIVLOOP, F
	goto	SYSDIV16START
	movf	SYSDIVMULTA,W
	movwf	SYSWORDTEMPA
	movf	SYSDIVMULTA_H,W
	movwf	SYSWORDTEMPA_H
	movf	SYSDIVMULTX,W
	movwf	SYSWORDTEMPX
	movf	SYSDIVMULTX_H,W
	movwf	SYSWORDTEMPX_H
	return

;********************************************************************************

SYSMULTSUB
	clrf	SYSBYTETEMPX
MUL8LOOP
	movf	SYSBYTETEMPA, W
	btfsc	SYSBYTETEMPB, 0
	addwf	SYSBYTETEMPX, F
	bcf	STATUS, C
	rrf	SYSBYTETEMPB, F
	bcf	STATUS, C
	rlf	SYSBYTETEMPA, F
	movf	SYSBYTETEMPB, F
	btfss	STATUS, Z
	goto	MUL8LOOP
	return

;********************************************************************************

TURN_LEFT
	bsf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bsf	LATD,1
	return

;********************************************************************************

TURN_RIGHT
	bcf	LATD,3
	bsf	LATD,2
	bsf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
