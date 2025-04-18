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
LCDCOLUMN	EQU	33
LCDLINE	EQU	34
LCDREADY	EQU	35
LCDVALUE	EQU	36
LCDVALUETEMP	EQU	38
LCDVALUE_H	EQU	37
LCD_STATE	EQU	39
OVERFLOWS	EQU	40
OVERFLOWS_H	EQU	41
PRINTLEN	EQU	42
SAVEPCLATH	EQU	43
STRINGPOINTER	EQU	44
SYSBSR	EQU	45
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
SYSLCDTEMP	EQU	46
SYSPRINTDATAHANDLER	EQU	47
SYSPRINTDATAHANDLER_H	EQU	48
SYSPRINTTEMP	EQU	49
SYSREPEATTEMP1	EQU	50
SYSSTATUS	EQU	127
SYSSTRINGA	EQU	119
SYSSTRINGA_H	EQU	120
SYSTEMP1	EQU	51
SYSTEMP1_H	EQU	52
SYSW	EQU	126
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
TIME	EQU	53
TIME_H	EQU	54
TMRNUMBER	EQU	55
TMRPOST	EQU	56
TMRPRES	EQU	57
TMRSOURCE	EQU	58

;********************************************************************************

;Alias variables
AFSR0	EQU	4
AFSR0_H	EQU	5

;********************************************************************************

;Vectors
	ORG	0
	pagesel	BASPROGRAMSTART
	goto	BASPROGRAMSTART
	ORG	4
Interrupt

;********************************************************************************

;Save Context
	movwf	SysW
	swapf	STATUS,W
	movwf	SysSTATUS
	movf	BSR,W
	banksel	STATUS
	movwf	SysBSR
;Store system variables
	movf	PCLATH,W
	movwf	SavePCLATH
	clrf	PCLATH
;On Interrupt handlers
	banksel	PIE0
	btfss	PIE0,TMR0IE
	goto	NotTMR0IF
	btfss	PIR0,TMR0IF
	goto	NotTMR0IF
	banksel	STATUS
	call	TIMEROVERFLOW
	banksel	PIR0
	bcf	PIR0,TMR0IF
	goto	INTERRUPTDONE
NotTMR0IF
;User Interrupt routine
INTERRUPTDONE
;Restore Context
;Restore system variables
	banksel	SAVEPCLATH
	movf	SavePCLATH,W
	movwf	PCLATH
	movf	SysBSR,W
	movwf	BSR
	swapf	SysSTATUS,W
	movwf	STATUS
	swapf	SysW,F
	swapf	SysW,W
	retfie

;********************************************************************************

;Start of program memory page 0
	ORG	34
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS
	call	INITLCD
;Enable interrupts
	bsf	INTCON,GIE
	bsf	INTCON,PEIE

;Start of the main program
	bcf	TRISB,0
	bcf	TRISB,1
	bcf	TRISB,2
	bcf	TRISB,4
	bcf	TRISB,5
	bcf	TRISB,6
	bcf	TRISB,7
	clrf	OVERFLOWS
	clrf	OVERFLOWS_H
	movlw	1
	movwf	TMRSOURCE
	movlw	128
	movwf	TMRPRES
	movlw	1
	movwf	TMRPOST
	call	INITTIMER0153
	bcf	T0CON0,T016BIT
	movlw	160
	movwf	TMR0H
	clrf	TMR0L
	clrf	TMRNUMBER
	call	STARTTIMER
	banksel	PIE0
	bsf	PIE0,TMR0IE
	banksel	TIME
	clrf	TIME
	clrf	TIME_H
SysDoLoop_S1
	call	CLS
	clrf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
	movlw	low StringTable1
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable1) | 128
	movwf	SysPRINTDATAHandler_H
	call	PRINT108
	movf	TIME,W
	movwf	LCDVALUE
	movf	TIME_H,W
	movwf	LCDVALUE_H
	call	PRINT110
	movlw	1
	movwf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
	movf	OVERFLOWS,W
	movwf	LCDVALUE
	movf	OVERFLOWS_H,W
	movwf	LCDVALUE_H
	call	PRINT110
	incf	TIME,F
	btfsc	STATUS,Z
	incf	TIME_H,F
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	call	Delay_MS
	goto	SysDoLoop_S1
SysDoLoop_E1
SysDoLoop_S2
	call	CLS
	clrf	LCDLINE
	clrf	LCDCOLUMN
	call	LOCATE
	movlw	low StringTable2
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable2) | 128
	movwf	SysPRINTDATAHandler_H
	call	PRINT108
	movlw	1
	movwf	SysWaitTempS
	call	Delay_S
	goto	SysDoLoop_S2
SysDoLoop_E2
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

;Overloaded signature: BYTE:BYTE:BYTE:
INITTIMER0153
	movlw	240
	andwf	T0CON1,W
	movwf	SysTemp1
	iorwf	TMRPRES,F
	decf	TMRSOURCE,W
	btfsc	STATUS, Z
	goto	ELSE30_1
	bsf	TMRPOST,5
	goto	ENDIF30
ELSE30_1
	bcf	TMRPOST,5
ENDIF30
	movf	TMRPRES,W
	movwf	T0CON1
	movlw	224
	andwf	T0CON0,W
	movwf	SysTemp1
	iorwf	TMRPOST,F
	bcf	TMRPOST,4
	movf	TMRPOST,W
	movwf	T0CON0
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
	goto	ENDIF20
	movlw	16
	subwf	LCDBYTE,W
	btfsc	STATUS, C
	goto	ENDIF21
	movf	LCDBYTE,W
	sublw	7
	btfsc	STATUS, C
	goto	ENDIF22
	movf	LCDBYTE,W
	movwf	LCD_STATE
ENDIF22
ENDIF21
ENDIF20
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
	goto	ENDIF9
	movlw	255
	movwf	LCDREADY
ENDIF9
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
	goto	ENDIF1
	movlw	2
	subwf	LCDLINE,F
	movlw	16
	addwf	LCDCOLUMN,F
ENDIF1
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

;Overloaded signature: STRING:
PRINT108
	movf	SysPRINTDATAHandler,W
	movwf	AFSR0
	movf	SysPRINTDATAHandler_H,W
	movwf	AFSR0_H
	movf	INDF0,W
	movwf	PRINTLEN
	movf	PRINTLEN,F
	btfsc	STATUS, Z
	return
	bsf	LATB,0
	clrf	SYSPRINTTEMP
	movlw	1
	subwf	PRINTLEN,W
	btfss	STATUS, C
	goto	SysForLoopEnd1
SysForLoop1
	incf	SYSPRINTTEMP,F
	movf	SYSPRINTTEMP,W
	addwf	SysPRINTDATAHandler,W
	movwf	AFSR0
	movlw	0
	addwfc	SysPRINTDATAHandler_H,W
	movwf	AFSR0_H
	movf	INDF0,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movf	PRINTLEN,W
	subwf	SYSPRINTTEMP,W
	btfss	STATUS, C
	goto	SysForLoop1
SysForLoopEnd1
	return

;********************************************************************************

;Overloaded signature: WORD:
PRINT110
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
	goto	ENDIF5
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
ENDIF5
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
	goto	ENDIF6
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
ENDIF6
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
	goto	ENDIF7
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
ENDIF7
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
	goto	ENDIF8
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
ENDIF8
	movlw	48
	addwf	LCDVALUE,W
	movwf	LCDBYTE
	goto	LCDNORMALWRITEBYTE

;********************************************************************************

STARTTIMER
	movf	TMRNUMBER,F
	btfsc	STATUS, Z
	bsf	T0CON0,T0EN
	decf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF24
	banksel	T1CON
	bsf	T1CON,TMR1ON
ENDIF24
	movlw	2
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF25
	banksel	T2CON
	bsf	T2CON,TMR2ON
ENDIF25
	movlw	3
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF26
	banksel	T3CON
	bsf	T3CON,TMR3ON
ENDIF26
	movlw	4
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF27
	banksel	T4CON
	bsf	T4CON,TMR4ON
ENDIF27
	movlw	5
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF28
	banksel	T5CON
	bsf	T5CON,TMR5ON
ENDIF28
	movlw	6
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF29
	banksel	T6CON
	bsf	T6CON,TMR6ON
ENDIF29
	banksel	STATUS
	return

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
	goto	ENDIF31
	clrf	SYSWORDTEMPA
	clrf	SYSWORDTEMPA_H
	return
ENDIF31
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
	goto	ENDIF32
	bcf	SYSDIVMULTA,0
	movf	SYSDIVMULTB,W
	addwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	addwfc	SYSDIVMULTX_H,F
ENDIF32
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

SysStringTables
	movf	SysStringA_H,W
	movwf	PCLATH
	movf	SysStringA,W
	incf	SysStringA,F
	btfsc	STATUS,Z
	incf	SysStringA_H,F
	movwf	PCL

StringTable1
	retlw	6
	retlw	115	;s
	retlw	116	;t
	retlw	97	;a
	retlw	114	;r
	retlw	116	;t
	retlw	32	; 


StringTable2
	retlw	5
	retlw	97	;a
	retlw	109	;m
	retlw	111	;o
	retlw	110	;n
	retlw	103	;g


;********************************************************************************

TIMEROVERFLOW
	incf	OVERFLOWS,F
	btfsc	STATUS,Z
	incf	OVERFLOWS_H,F
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
