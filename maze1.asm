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
ADREADPORT	EQU	32
DELAYTEMP	EQU	112
DELAYTEMP2	EQU	113
DIRECTION	EQU	33
DIRECTIONS	EQU	9194
DIRECTIONTIMES	EQU	9188
FLAMECD	EQU	34
FLAMECD_H	EQU	35
FLAMEIN	EQU	36
FLAMEIN_H	EQU	37
I	EQU	38
IMMUNE	EQU	39
LASTDIRTIME	EQU	40
LASTDIRTIME_H	EQU	41
LASTFLAME	EQU	42
LASTFLAME_H	EQU	43
LCDBYTE	EQU	44
LCDCOLUMN	EQU	45
LCDLINE	EQU	46
LCDREADY	EQU	47
LCDVALUE	EQU	48
LCDVALUETEMP	EQU	50
LCDVALUE_H	EQU	49
LCD_STATE	EQU	51
LINECOUNT	EQU	52
MAXFLAME	EQU	53
MAXFLAME_H	EQU	54
MINWALL	EQU	55
MINWALL_H	EQU	56
OVERFLOWS	EQU	57
OVERFLOWS_H	EQU	58
POINTEREND	EQU	59
POINTERSTART	EQU	60
PRINTLEN	EQU	61
READAD	EQU	62
READAD10	EQU	63
READAD10_H	EQU	65
REFRESHTIME	EQU	66
REFRESHTIME_H	EQU	67
SAVEPCLATH	EQU	68
SEARCHCD	EQU	69
SEARCHCD_H	EQU	70
STRINGPOINTER	EQU	71
SYSBITVAR0	EQU	72
SYSBSR	EQU	73
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
SYSLCDTEMP	EQU	74
SYSPRINTDATAHANDLER	EQU	75
SYSPRINTDATAHANDLER_H	EQU	76
SYSPRINTTEMP	EQU	77
SYSREPEATTEMP1	EQU	78
SYSSTATUS	EQU	127
SYSSTRINGA	EQU	119
SYSSTRINGA_H	EQU	120
SYSTEMP1	EQU	79
SYSTEMP1_H	EQU	80
SYSTEMP2	EQU	81
SYSTEMP2_H	EQU	82
SYSTEMP3	EQU	83
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
TIME	EQU	84
TMRNUMBER	EQU	85
TMRPOST	EQU	86
TMRPRES	EQU	87
TMRSOURCE	EQU	88
WALL1DIST	EQU	89
WALL1DIST_H	EQU	90
WALL1IN	EQU	91
WALL1IN_H	EQU	92
WALL2DIST	EQU	93
WALL2DIST_H	EQU	94
WALL2IN	EQU	95
WALL2IN_H	EQU	96

;********************************************************************************

;Alias variables
AFSR0	EQU	4
AFSR0_H	EQU	5
SYSREADAD10WORD	EQU	63
SYSREADAD10WORD_H	EQU	65
SYSREADADBYTE	EQU	62

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
	pagesel	TIMEROVERFLOW
	call	TIMEROVERFLOW
	pagesel	$
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
	ORG	36
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS
	call	INITLCD
;Enable interrupts
	bsf	INTCON,GIE
	bsf	INTCON,PEIE

;Start of the main program
	bcf	TRISD,3
	bcf	TRISD,2
	bcf	TRISD,0
	bcf	TRISD,1
	bsf	TRISA,1
	bsf	TRISA,2
	bsf	TRISA,3
	bsf	TRISA,4
	bcf	TRISA,5
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
	pagesel	INITTIMER0171
	call	INITTIMER0171
	pagesel	$
	bcf	T0CON0,T016BIT
	movlw	160
	movwf	TMR0H
	clrf	TMR0L
	clrf	TMRNUMBER
	pagesel	STARTTIMER
	call	STARTTIMER
	pagesel	$
	banksel	PIE0
	bsf	PIE0,TMR0IE
	banksel	LATD
	bcf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bcf	LATD,1
	clrf	REFRESHTIME
	clrf	REFRESHTIME_H
	clrf	LINECOUNT
	bsf	SYSBITVAR0,0
	bsf	SYSBITVAR0,1
	clrf	LASTFLAME
	clrf	LASTFLAME_H
	movlw	255
	movwf	MAXFLAME
	movwf	MAXFLAME_H
	bcf	SYSBITVAR0,2
	clrf	SEARCHCD
	clrf	SEARCHCD_H
	clrf	FLAMECD
	clrf	FLAMECD_H
	clrf	I
SysForLoop1
	incf	I,F
	movlw	low(DIRECTIONS)
	addwf	I,W
	movwf	AFSR0
	clrf	SysTemp1
	movlw	high(DIRECTIONS)
	addwfc	SysTemp1,W
	movwf	AFSR0_H
	clrf	INDF0
	movlw	low(DIRECTIONTIMES)
	addwf	I,W
	movwf	AFSR0
	clrf	SysTemp1
	movlw	high(DIRECTIONTIMES)
	addwfc	SysTemp1,W
	movwf	AFSR0_H
	clrf	INDF0
	movlw	5
	subwf	I,W
	btfss	STATUS, C
	goto	SysForLoop1
SysForLoopEnd1
	movlw	1
	movwf	POINTERSTART
	movlw	1
	movwf	POINTEREND
	clrf	LASTDIRTIME
	clrf	LASTDIRTIME_H
	bsf	SYSBITVAR0,3
	bcf	SYSBITVAR0,4
	clrf	MINWALL
	clrf	MINWALL_H
	clrf	IMMUNE
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
SysDoLoop_S1
	bcf	SYSBITVAR0,0
	btfsc	PORTA,1
	bsf	SYSBITVAR0,0
	clrf	SysByteTempX
	btfss	SYSBITVAR0,0
	comf	SysByteTempX,F
	movf	SysByteTempX,W
	movwf	SysTemp1
	clrf	SysByteTempX
	btfsc	SYSBITVAR0,1
	comf	SysByteTempX,F
	movf	SysTemp1,W
	andwf	SysByteTempX,W
	movwf	SysTemp2
	btfss	SysTemp2,0
	goto	ENDIF2
	incf	LINECOUNT,F
	movf	LINECOUNT,W
	movwf	SysTemp1
	btfss	SysTemp1,0
	goto	ENDIF8
	bcf	SYSBITVAR0,3
	movlw	75
	addwf	OVERFLOWS,W
	movwf	SEARCHCD
	movlw	0
	addwfc	OVERFLOWS_H,W
	movwf	SEARCHCD_H
ENDIF8
ENDIF2
	bcf	SYSBITVAR0,1
	btfsc	SYSBITVAR0,0
	bsf	SYSBITVAR0,1
	call	MAKEREADINGS
	movf	REFRESHTIME,W
	movwf	SysWORDTempA
	movf	REFRESHTIME_H,W
	movwf	SysWORDTempA_H
	movf	OVERFLOWS,W
	movwf	SysWORDTempB
	movf	OVERFLOWS_H,W
	movwf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	btfss	SysByteTempX,0
	goto	ENDIF3
	call	PRINTDEBUG
	pagesel	$
	movlw	10
	addwf	OVERFLOWS,W
	movwf	REFRESHTIME
	movlw	0
	addwfc	OVERFLOWS_H,W
	movwf	REFRESHTIME_H
ENDIF3
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	btfsc	STATUS, Z
	call	WALLHUG
	movf	WALL1DIST,W
	movwf	SysWORDTempB
	movf	WALL1DIST_H,W
	movwf	SysWORDTempB_H
	movlw	40
	movwf	SysWORDTempA
	clrf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	btfss	SysByteTempX,0
	goto	ELSE5_1
	pagesel	CLEARQUEUE
	call	CLEARQUEUE
	pagesel	$
	movlw	1
	movwf	DIRECTION
	movlw	10
	movwf	TIME
	call	ADDDIRECTION
	movlw	7
	movwf	DIRECTION
	movlw	5
	movwf	TIME
	call	ADDDIRECTION
	movlw	4
	movwf	DIRECTION
	movlw	40
	movwf	TIME
	call	ADDDIRECTION
	movlw	1
	movwf	DIRECTION
	movlw	60
	movwf	TIME
	call	ADDDIRECTION
	goto	ENDIF5
ELSE5_1
	movf	WALL2DIST,W
	movwf	SysWORDTempA
	movf	WALL2DIST_H,W
	movwf	SysWORDTempA_H
	movlw	20
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	btfss	SysByteTempX,0
	goto	ENDIF5
	pagesel	CLEARQUEUE
	call	CLEARQUEUE
	pagesel	$
	movlw	1
	movwf	DIRECTION
	movlw	10
	movwf	TIME
	call	ADDDIRECTION
	movlw	1
	movwf	DIRECTION
	movlw	10
	movwf	TIME
	call	ADDDIRECTION
	movlw	7
	movwf	DIRECTION
	movlw	5
	movwf	TIME
	call	ADDDIRECTION
	movlw	3
	movwf	DIRECTION
	movlw	40
	movwf	TIME
	call	ADDDIRECTION
	movlw	1
	movwf	DIRECTION
	movlw	60
	movwf	TIME
	call	ADDDIRECTION
ENDIF5
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	btfsc	STATUS, Z
	goto	ELSE6_1
	call	MOVE
	goto	ENDIF6
ELSE6_1
	pagesel	FW
	call	FW
	pagesel	$
ENDIF6
	movf	FLAMEIN,W
	movwf	SysWORDTempA
	movf	FLAMEIN_H,W
	movwf	SysWORDTempA_H
	movlw	25
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysByteTempX,W
	movwf	SysTemp1
	movf	WALL2DIST,W
	movwf	SysWORDTempA
	movf	WALL2DIST_H,W
	movwf	SysWORDTempA_H
	movlw	20
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysTemp1,W
	andwf	SysByteTempX,W
	movwf	SysTemp2
	btfss	SysTemp2,0
	goto	ELSE7_1
	call	BLOW
	pagesel	$
	goto	SysDoLoop_E1
	goto	ENDIF7
ELSE7_1
	bcf	LATA,5
ENDIF7
	goto	SysDoLoop_S1
SysDoLoop_E1
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

ADDDIRECTION
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	btfss	STATUS, Z
	goto	ENDIF11
	movf	OVERFLOWS,W
	movwf	LASTDIRTIME
	movf	OVERFLOWS_H,W
	movwf	LASTDIRTIME_H
ENDIF11
	movlw	low(DIRECTIONS)
	addwf	POINTEREND,W
	movwf	AFSR0
	clrf	SysTemp1
	movlw	high(DIRECTIONS)
	addwfc	SysTemp1,W
	movwf	AFSR0_H
	movf	DIRECTION,W
	movwf	INDF0
	movlw	low(DIRECTIONTIMES)
	addwf	POINTEREND,W
	movwf	AFSR0
	clrf	SysTemp1
	movlw	high(DIRECTIONTIMES)
	addwfc	SysTemp1,W
	movwf	AFSR0_H
	movf	TIME,W
	movwf	INDF0
	movf	POINTEREND,W
	movwf	SysBYTETempA
	movlw	5
	movwf	SysBYTETempB
	pagesel	SysDivSub
	call	SysDivSub
	pagesel	$
	incf	SysBYTETempX,W
	movwf	POINTEREND
	return

;********************************************************************************

BLOW
	bsf	LATA,5
	pagesel	CLS
	call	CLS
	pagesel	$
	clrf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movlw	low StringTable1
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable1) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movlw	1
	movwf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movf	FLAMEIN,W
	movwf	LCDVALUE
	movf	FLAMEIN_H,W
	movwf	LCDVALUE_H
	call	PRINT128
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movlw	3
	movwf	INDF0
	movf	FLAMEIN,W
	movwf	MAXFLAME
	movf	FLAMEIN_H,W
	movwf	MAXFLAME_H
SysDoLoop_S2
	movf	overflows,W
	movwf	SysWORDTempB
	movf	overflows_H,W
	movwf	SysWORDTempB_H
	movf	flamecd,W
	movwf	SysWORDTempA
	movf	flamecd_H,W
	movwf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysByteTempX,W
	movwf	SysTemp2
	movf	flamein,W
	movwf	SysWORDTempB
	movf	flamein_H,W
	movwf	SysWORDTempB_H
	movlw	32
	movwf	SysWORDTempA
	movlw	3
	movwf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysTemp2,W
	andwf	SysByteTempX,W
	movwf	SysTemp3
	btfsc	SysTemp3,0
	goto	SysDoLoop_E2
	movlw	2
	movwf	ADREADPORT
	call	FN_READAD1023
	movf	SYSREADAD10WORD,W
	movwf	FLAMEIN
	movf	SYSREADAD10WORD_H,W
	movwf	FLAMEIN_H
	pagesel	FN_FLAMECHECK
	call	FN_FLAMECHECK
	pagesel	$
	btfss	SYSBITVAR0,5
	goto	ELSE14_1
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movlw	3
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE16_1
	pagesel	TURN_RIGHT
	call	TURN_RIGHT
	pagesel	$
	goto	ENDIF16
ELSE16_1
	pagesel	TURN_LEFT
	call	TURN_LEFT
	pagesel	$
ENDIF16
	goto	ENDIF14
ELSE14_1
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movlw	3
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE17_1
	pagesel	TURN_LEFT
	call	TURN_LEFT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movlw	4
	movwf	INDF0
	goto	ENDIF17
ELSE17_1
	pagesel	TURN_RIGHT
	call	TURN_RIGHT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movlw	3
	movwf	INDF0
ENDIF17
	movf	FLAMEIN,W
	movwf	MAXFLAME
	movf	FLAMEIN_H,W
	movwf	MAXFLAME_H
ENDIF14
	pagesel	CLS
	call	CLS
	pagesel	$
	clrf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movlw	low StringTable1
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable1) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movlw	1
	movwf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movf	FLAMEIN,W
	movwf	LCDVALUE
	movf	FLAMEIN_H,W
	movwf	LCDVALUE_H
	call	PRINT128
	pagesel	$
	movf	FLAMEIN,W
	movwf	SysWORDTempB
	movf	FLAMEIN_H,W
	movwf	SysWORDTempB_H
	movlw	32
	movwf	SysWORDTempA
	movlw	3
	movwf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysByteTempX,W
	movwf	SysTemp2
	movf	FLAMECD,W
	movwf	SysWORDTempA
	movf	FLAMECD_H,W
	movwf	SysWORDTempA_H
	clrf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompEqual16
	call	SysCompEqual16
	pagesel	$
	movf	SysTemp2,W
	andwf	SysByteTempX,W
	movwf	SysTemp3
	btfss	SysTemp3,0
	goto	ENDIF15
	movlw	44
	addwf	OVERFLOWS,W
	movwf	FLAMECD
	movlw	1
	addwfc	OVERFLOWS_H,W
	movwf	FLAMECD_H
ENDIF15
	movlw	20
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	STOP
	call	STOP
	pagesel	$
	movlw	1
	movwf	SysWaitTempS
	pagesel	Delay_S
	call	Delay_S
	pagesel	$
	goto	SysDoLoop_S2
SysDoLoop_E2
	bcf	LATA,5
	pagesel	CLS
	call	CLS
	pagesel	$
	clrf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movlw	low StringTable2
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable2) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	TURN_RIGHT
	call	TURN_RIGHT
	pagesel	$
	movlw	244
	movwf	SysWaitTempMS
	movlw	1
	movwf	SysWaitTempMS_H
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
	pagesel	STOP
	goto	STOP

;********************************************************************************

INITLCD
	bcf	TRISB,0
	bcf	TRISB,2
	bcf	TRISB,1
	movlw	10
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
SysWaitLoop3
	pagesel	FN_LCDREADY
	call	FN_LCDREADY
	pagesel	$
	movf	LCDREADY,F
	btfsc	STATUS,Z
	goto	SysWaitLoop3
	bcf	LATB,0
	bcf	TRISB,4
	bcf	TRISB,5
	bcf	TRISB,6
	bcf	TRISB,7
	bcf	LATB,1
	movlw	15
	movwf	SysWaitTempMS
	clrf	SysWaitTempMS_H
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
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
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
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
	pagesel	Delay_MS
	call	Delay_MS
	pagesel	$
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
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
	movlw	6
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
	movlw	12
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	CLS
	call	CLS
	pagesel	$
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

MAKEREADINGS
	movlw	3
	movwf	ADREADPORT
	call	FN_READAD21
	movf	SYSREADADBYTE,W
	movwf	WALL1IN
	clrf	WALL1IN_H
	movlw	3
	subwf	WALL1IN,W
	movwf	SysTemp1
	movlw	0
	subwfb	WALL1IN_H,W
	movwf	SysTemp1_H
	movlw	131
	movwf	SysWORDTempA
	movlw	26
	movwf	SysWORDTempA_H
	movf	SysTemp1,W
	movwf	SysWORDTempB
	movf	SysTemp1_H,W
	movwf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	SysTemp2
	movf	SysWORDTempA_H,W
	movwf	SysTemp2_H
	movlw	4
	subwf	SysTemp2,W
	movwf	SysTemp1
	movlw	0
	subwfb	SysTemp2_H,W
	movwf	SysTemp1_H
	movf	SysTemp1,W
	movwf	SysWORDTempA
	movf	SysTemp1_H,W
	movwf	SysWORDTempA_H
	movlw	5
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	WALL1DIST
	movf	SysWORDTempA_H,W
	movwf	WALL1DIST_H
	movlw	4
	movwf	ADREADPORT
	call	FN_READAD21
	movf	SYSREADADBYTE,W
	movwf	WALL2IN
	clrf	WALL2IN_H
	movlw	3
	subwf	WALL2IN,W
	movwf	SysTemp1
	movlw	0
	subwfb	WALL2IN_H,W
	movwf	SysTemp1_H
	movlw	131
	movwf	SysWORDTempA
	movlw	26
	movwf	SysWORDTempA_H
	movf	SysTemp1,W
	movwf	SysWORDTempB
	movf	SysTemp1_H,W
	movwf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	SysTemp2
	movf	SysWORDTempA_H,W
	movwf	SysTemp2_H
	movlw	4
	subwf	SysTemp2,W
	movwf	SysTemp1
	movlw	0
	subwfb	SysTemp2_H,W
	movwf	SysTemp1_H
	movf	SysTemp1,W
	movwf	SysWORDTempA
	movf	SysTemp1_H,W
	movwf	SysWORDTempA_H
	movlw	5
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	WALL2DIST
	movf	SysWORDTempA_H,W
	movwf	WALL2DIST_H
	movlw	2
	movwf	ADREADPORT
	call	FN_READAD1023
	movf	SYSREADAD10WORD,W
	movwf	FLAMEIN
	movf	SYSREADAD10WORD_H,W
	movwf	FLAMEIN_H
	return

;********************************************************************************

MOVE
	movlw	low(DIRECTIONTIMES)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONTIMES)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movf	LASTDIRTIME,W
	addwf	INDF0,W
	movwf	SysTemp1
	clrf	SysTemp2
	movf	LASTDIRTIME_H,W
	addwfc	SysTemp2,W
	movwf	SysTemp1_H
	movf	SysTemp1,W
	movwf	SysWORDTempA
	movf	SysTemp1_H,W
	movwf	SysWORDTempA_H
	movf	OVERFLOWS,W
	movwf	SysWORDTempB
	movf	OVERFLOWS_H,W
	movwf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	btfss	SysByteTempX,0
	goto	ELSE12_1
	movf	POINTERSTART,W
	movwf	SysBYTETempA
	movlw	5
	movwf	SysBYTETempB
	pagesel	SysDivSub
	call	SysDivSub
	pagesel	$
	incf	SysBYTETempX,W
	movwf	POINTERSTART
	movf	OVERFLOWS,W
	movwf	LASTDIRTIME
	movf	OVERFLOWS_H,W
	movwf	LASTDIRTIME_H
	goto	ENDIF12
ELSE12_1
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	movf	INDF0,F
	btfss	STATUS, Z
	goto	ELSE13_1
	pagesel	STOP
	call	STOP
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_1
	decf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_2
	pagesel	FW
	call	FW
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_2
	decf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_3
	pagesel	BW
	call	BW
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_3
	movlw	3
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_4
	pagesel	TURN_RIGHT
	call	TURN_RIGHT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_4
	movlw	4
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_5
	pagesel	TURN_LEFT
	call	TURN_LEFT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_5
	movlw	5
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_6
	pagesel	SLIGHT_RIGHT
	call	SLIGHT_RIGHT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_6
	movlw	6
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ELSE13_7
	pagesel	SLIGHT_LEFT
	call	SLIGHT_LEFT
	pagesel	$
	movlw	low(DIRECTIONS)
	addwf	POINTERSTART,W
	movwf	AFSR0
	clrf	SysTemp2
	movlw	high(DIRECTIONS)
	addwfc	SysTemp2,W
	movwf	AFSR0_H
	goto	ENDIF13
ELSE13_7
	movlw	7
	subwf	INDF0,W
	btfss	STATUS, Z
	goto	ENDIF13
	pagesel	HARD_STOP
	call	HARD_STOP
	pagesel	$
ENDIF13
ENDIF12
	return

;********************************************************************************

;Overloaded signature: WORD:
PRINT128
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
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF36
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	16
	movwf	SysWORDTempB
	movlw	39
	movwf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
	goto	LCDPRINTWORD1000
ENDIF36
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF37
LCDPRINTWORD1000
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	232
	movwf	SysWORDTempB
	movlw	3
	movwf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
	goto	LCDPRINTWORD100
ENDIF37
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF38
LCDPRINTWORD100
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	100
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
	goto	LCDPRINTWORD10
ENDIF38
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ENDIF39
LCDPRINTWORD10
	movf	LCDVALUE,W
	movwf	SysWORDTempA
	movf	LCDVALUE_H,W
	movwf	SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysDivSub16
	call	SysDivSub16
	pagesel	$
	movf	SysWORDTempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movf	SYSCALCTEMPX_H,W
	movwf	LCDVALUE_H
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	call	LCDNORMALWRITEBYTE
	pagesel	$
ENDIF39
	movlw	48
	addwf	LCDVALUE,W
	movwf	LCDBYTE
	pagesel	LCDNORMALWRITEBYTE
	goto	LCDNORMALWRITEBYTE

;********************************************************************************

PRINTDEBUG
	pagesel	CLS
	call	CLS
	pagesel	$
	clrf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	btfsc	STATUS, C
	goto	ELSE23_1
	clrf	I
	movf	POINTERSTART,W
	subwf	POINTEREND,W
	movwf	SysTemp3
	movlw	1
	movwf	SysBYTETempB
	movf	SysTemp3,W
	movwf	SysBYTETempA
	pagesel	SysCompLessThan
	call	SysCompLessThan
	pagesel	$
	btfsc	SysByteTempX,0
	goto	SysForLoopEnd2
SysForLoop2
	incf	I,F
	movf	I,W
	addwf	POINTERSTART,W
	movwf	SysTemp3
	movlw	2
	subwf	SysTemp3,W
	movwf	SysTemp1
	movwf	SysBYTETempA
	movlw	5
	movwf	SysBYTETempB
	pagesel	SysDivSub
	call	SysDivSub
	pagesel	$
	movf	SysBYTETempX,W
	movwf	SysTemp3
	incf	SysTemp3,W
	movwf	SysTemp1
	movlw	low(DIRECTIONS)
	addwf	SysTemp1,W
	movwf	AFSR0
	clrf	SysTemp3
	movlw	high(DIRECTIONS)
	addwfc	SysTemp3,W
	movwf	AFSR0_H
	movf	INDF0,W
	movwf	LCDVALUE
	pagesel	PRINT127
	call	PRINT127
	pagesel	$
	movlw	low StringTable3
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable3) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movf	POINTERSTART,W
	subwf	POINTEREND,W
	movwf	SysTemp3
	movf	I,W
	movwf	SysBYTETempA
	movf	SysTemp3,W
	movwf	SysBYTETempB
	pagesel	SysCompLessThan
	call	SysCompLessThan
	pagesel	$
	btfsc	SysByteTempX,0
	goto	SysForLoop2
SysForLoopEnd2
	goto	ENDIF23
ELSE23_1
	movf	POINTERSTART,W
	subwf	POINTEREND,W
	btfsc	STATUS, C
	goto	ENDIF23
	clrf	I
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	movwf	SysTemp3
	sublw	5
	movwf	SysTemp1
	movlw	1
	movwf	SysBYTETempB
	movf	SysTemp1,W
	movwf	SysBYTETempA
	pagesel	SysCompLessThan
	call	SysCompLessThan
	pagesel	$
	btfsc	SysByteTempX,0
	goto	SysForLoopEnd3
SysForLoop3
	incf	I,F
	movf	I,W
	addwf	POINTERSTART,W
	movwf	SysTemp3
	movlw	2
	subwf	SysTemp3,W
	movwf	SysTemp1
	movwf	SysBYTETempA
	movlw	5
	movwf	SysBYTETempB
	pagesel	SysDivSub
	call	SysDivSub
	pagesel	$
	movf	SysBYTETempX,W
	movwf	SysTemp3
	incf	SysTemp3,W
	movwf	SysTemp1
	movlw	low(DIRECTIONS)
	addwf	SysTemp1,W
	movwf	AFSR0
	clrf	SysTemp3
	movlw	high(DIRECTIONS)
	addwfc	SysTemp3,W
	movwf	AFSR0_H
	movf	INDF0,W
	movwf	LCDVALUE
	pagesel	PRINT127
	call	PRINT127
	pagesel	$
	movlw	low StringTable3
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable3) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movf	POINTEREND,W
	subwf	POINTERSTART,W
	movwf	SysTemp3
	sublw	5
	movwf	SysTemp1
	movf	I,W
	movwf	SysBYTETempA
	movf	SysTemp1,W
	movwf	SysBYTETempB
	pagesel	SysCompLessThan
	call	SysCompLessThan
	pagesel	$
	btfsc	SysByteTempX,0
	goto	SysForLoop3
SysForLoopEnd3
ENDIF23
	movlw	1
	movwf	LCDLINE
	clrf	LCDCOLUMN
	pagesel	LOCATE
	call	LOCATE
	pagesel	$
	movlw	low StringTable3
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable3) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movf	WALL1IN,W
	movwf	LCDVALUE
	movf	WALL1IN_H,W
	movwf	LCDVALUE_H
	call	PRINT128
	pagesel	$
	movlw	low StringTable3
	movwf	SysPRINTDATAHandler
	movlw	(high StringTable3) | 128
	movwf	SysPRINTDATAHandler_H
	pagesel	PRINT126
	call	PRINT126
	pagesel	$
	movf	WALL2IN,W
	movwf	LCDVALUE
	movf	WALL2IN_H,W
	movwf	LCDVALUE_H
	goto	PRINT128

;********************************************************************************

;Overloaded signature: BYTE:
FN_READAD21
	banksel	ADCON0
	bcf	ADCON0,ADFRM0
	banksel	ADREADPORT
	movf	ADREADPORT,W
	banksel	ADPCH
	movwf	ADPCH
SysSelect1Case1
	banksel	ADREADPORT
	movf	ADREADPORT,F
	btfss	STATUS, Z
	goto	SysSelect1Case2
	banksel	ANSELA
	bsf	ANSELA,0
	goto	SysSelectEnd1
SysSelect1Case2
	decf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case3
	banksel	ANSELA
	bsf	ANSELA,1
	goto	SysSelectEnd1
SysSelect1Case3
	movlw	2
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case4
	banksel	ANSELA
	bsf	ANSELA,2
	goto	SysSelectEnd1
SysSelect1Case4
	movlw	3
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case5
	banksel	ANSELA
	bsf	ANSELA,3
	goto	SysSelectEnd1
SysSelect1Case5
	movlw	4
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case6
	banksel	ANSELA
	bsf	ANSELA,4
	goto	SysSelectEnd1
SysSelect1Case6
	movlw	5
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case7
	banksel	ANSELA
	bsf	ANSELA,5
	goto	SysSelectEnd1
SysSelect1Case7
	movlw	6
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case8
	banksel	ANSELA
	bsf	ANSELA,6
	goto	SysSelectEnd1
SysSelect1Case8
	movlw	7
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case9
	banksel	ANSELA
	bsf	ANSELA,7
	goto	SysSelectEnd1
SysSelect1Case9
	movlw	8
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case10
	banksel	ANSELB
	bsf	ANSELB,0
	goto	SysSelectEnd1
SysSelect1Case10
	movlw	9
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case11
	banksel	ANSELB
	bsf	ANSELB,1
	goto	SysSelectEnd1
SysSelect1Case11
	movlw	10
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case12
	banksel	ANSELB
	bsf	ANSELB,2
	goto	SysSelectEnd1
SysSelect1Case12
	movlw	11
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case13
	banksel	ANSELB
	bsf	ANSELB,3
	goto	SysSelectEnd1
SysSelect1Case13
	movlw	12
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case14
	banksel	ANSELB
	bsf	ANSELB,4
	goto	SysSelectEnd1
SysSelect1Case14
	movlw	13
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case15
	banksel	ANSELB
	bsf	ANSELB,5
	goto	SysSelectEnd1
SysSelect1Case15
	movlw	14
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case16
	banksel	ANSELB
	bsf	ANSELB,6
	goto	SysSelectEnd1
SysSelect1Case16
	movlw	15
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case17
	banksel	ANSELB
	bsf	ANSELB,7
	goto	SysSelectEnd1
SysSelect1Case17
	movlw	16
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case18
	banksel	ANSELC
	bsf	ANSELC,0
	goto	SysSelectEnd1
SysSelect1Case18
	movlw	17
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case19
	banksel	ANSELC
	bsf	ANSELC,1
	goto	SysSelectEnd1
SysSelect1Case19
	movlw	18
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case20
	banksel	ANSELC
	bsf	ANSELC,2
	goto	SysSelectEnd1
SysSelect1Case20
	movlw	19
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case21
	banksel	ANSELC
	bsf	ANSELC,3
	goto	SysSelectEnd1
SysSelect1Case21
	movlw	20
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case22
	banksel	ANSELC
	bsf	ANSELC,4
	goto	SysSelectEnd1
SysSelect1Case22
	movlw	21
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case23
	banksel	ANSELC
	bsf	ANSELC,5
	goto	SysSelectEnd1
SysSelect1Case23
	movlw	22
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case24
	banksel	ANSELC
	bsf	ANSELC,6
	goto	SysSelectEnd1
SysSelect1Case24
	movlw	23
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case25
	banksel	ANSELC
	bsf	ANSELC,7
	goto	SysSelectEnd1
SysSelect1Case25
	movlw	24
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case26
	banksel	ANSELD
	bsf	ANSELD,0
	goto	SysSelectEnd1
SysSelect1Case26
	movlw	25
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case27
	banksel	ANSELD
	bsf	ANSELD,1
	goto	SysSelectEnd1
SysSelect1Case27
	movlw	26
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case28
	banksel	ANSELD
	bsf	ANSELD,2
	goto	SysSelectEnd1
SysSelect1Case28
	movlw	27
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case29
	banksel	ANSELD
	bsf	ANSELD,3
	goto	SysSelectEnd1
SysSelect1Case29
	movlw	28
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case30
	banksel	ANSELD
	bsf	ANSELD,4
	goto	SysSelectEnd1
SysSelect1Case30
	movlw	29
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case31
	banksel	ANSELD
	bsf	ANSELD,5
	goto	SysSelectEnd1
SysSelect1Case31
	movlw	30
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case32
	banksel	ANSELD
	bsf	ANSELD,6
	goto	SysSelectEnd1
SysSelect1Case32
	movlw	31
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case33
	banksel	ANSELD
	bsf	ANSELD,7
	goto	SysSelectEnd1
SysSelect1Case33
	movlw	32
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case34
	banksel	ANSELE
	bsf	ANSELE,0
	goto	SysSelectEnd1
SysSelect1Case34
	movlw	33
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect1Case35
	banksel	ANSELE
	bsf	ANSELE,1
	goto	SysSelectEnd1
SysSelect1Case35
	movlw	34
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelectEnd1
	banksel	ANSELE
	bsf	ANSELE,2
SysSelectEnd1
	banksel	ADCON0
	bcf	ADCON0,ADCS
	movlw	1
	movwf	ADCLK
	bcf	ADCON0,ADCS
	movlw	15
	movwf	ADCLK
	bcf	ADCON0,ADFRM0
	bcf	ADCON0,ADFM0
	banksel	ADREADPORT
	movf	ADREADPORT,W
	banksel	ADPCH
	movwf	ADPCH
	bsf	ADCON0,ADON
	movlw	2
	movwf	SysWaitTemp10US
	banksel	STATUS
	pagesel	Delay_10US
	call	Delay_10US
	pagesel	$
	banksel	ADCON0
	bsf	ADCON0,GO_NOT_DONE
	nop
SysWaitLoop1
	btfsc	ADCON0,GO_NOT_DONE
	goto	SysWaitLoop1
	bcf	ADCON0,ADON
	banksel	ANSELA
	clrf	ANSELA
	clrf	ANSELB
	clrf	ANSELC
	clrf	ANSELD
	clrf	ANSELE
	banksel	ADRESH
	movf	ADRESH,W
	banksel	READAD
	movwf	READAD
	banksel	ADCON0
	bcf	ADCON0,ADFRM0
	banksel	STATUS
	return

;********************************************************************************

;Overloaded signature: BYTE:
FN_READAD1023
	banksel	ADCON0
	bsf	ADCON0,ADFRM0
	banksel	ADREADPORT
	movf	ADREADPORT,W
	banksel	ADPCH
	movwf	ADPCH
SysSelect2Case1
	banksel	ADREADPORT
	movf	ADREADPORT,F
	btfss	STATUS, Z
	goto	SysSelect2Case2
	banksel	ANSELA
	bsf	ANSELA,0
	goto	SysSelectEnd2
SysSelect2Case2
	decf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case3
	banksel	ANSELA
	bsf	ANSELA,1
	goto	SysSelectEnd2
SysSelect2Case3
	movlw	2
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case4
	banksel	ANSELA
	bsf	ANSELA,2
	goto	SysSelectEnd2
SysSelect2Case4
	movlw	3
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case5
	banksel	ANSELA
	bsf	ANSELA,3
	goto	SysSelectEnd2
SysSelect2Case5
	movlw	4
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case6
	banksel	ANSELA
	bsf	ANSELA,4
	goto	SysSelectEnd2
SysSelect2Case6
	movlw	5
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case7
	banksel	ANSELA
	bsf	ANSELA,5
	goto	SysSelectEnd2
SysSelect2Case7
	movlw	6
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case8
	banksel	ANSELA
	bsf	ANSELA,6
	goto	SysSelectEnd2
SysSelect2Case8
	movlw	7
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case9
	banksel	ANSELA
	bsf	ANSELA,7
	goto	SysSelectEnd2
SysSelect2Case9
	movlw	8
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case10
	banksel	ANSELB
	bsf	ANSELB,0
	goto	SysSelectEnd2
SysSelect2Case10
	movlw	9
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case11
	banksel	ANSELB
	bsf	ANSELB,1
	goto	SysSelectEnd2
SysSelect2Case11
	movlw	10
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case12
	banksel	ANSELB
	bsf	ANSELB,2
	goto	SysSelectEnd2
SysSelect2Case12
	movlw	11
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case13
	banksel	ANSELB
	bsf	ANSELB,3
	goto	SysSelectEnd2
SysSelect2Case13
	movlw	12
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case14
	banksel	ANSELB
	bsf	ANSELB,4
	goto	SysSelectEnd2
SysSelect2Case14
	movlw	13
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case15
	banksel	ANSELB
	bsf	ANSELB,5
	goto	SysSelectEnd2
SysSelect2Case15
	movlw	14
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case16
	banksel	ANSELB
	bsf	ANSELB,6
	goto	SysSelectEnd2
SysSelect2Case16
	movlw	15
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case17
	banksel	ANSELB
	bsf	ANSELB,7
	goto	SysSelectEnd2
SysSelect2Case17
	movlw	16
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case18
	banksel	ANSELC
	bsf	ANSELC,0
	goto	SysSelectEnd2
SysSelect2Case18
	movlw	17
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case19
	banksel	ANSELC
	bsf	ANSELC,1
	goto	SysSelectEnd2
SysSelect2Case19
	movlw	18
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case20
	banksel	ANSELC
	bsf	ANSELC,2
	goto	SysSelectEnd2
SysSelect2Case20
	movlw	19
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case21
	banksel	ANSELC
	bsf	ANSELC,3
	goto	SysSelectEnd2
SysSelect2Case21
	movlw	20
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case22
	banksel	ANSELC
	bsf	ANSELC,4
	goto	SysSelectEnd2
SysSelect2Case22
	movlw	21
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case23
	banksel	ANSELC
	bsf	ANSELC,5
	goto	SysSelectEnd2
SysSelect2Case23
	movlw	22
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case24
	banksel	ANSELC
	bsf	ANSELC,6
	goto	SysSelectEnd2
SysSelect2Case24
	movlw	23
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case25
	banksel	ANSELC
	bsf	ANSELC,7
	goto	SysSelectEnd2
SysSelect2Case25
	movlw	24
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case26
	banksel	ANSELD
	bsf	ANSELD,0
	goto	SysSelectEnd2
SysSelect2Case26
	movlw	25
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case27
	banksel	ANSELD
	bsf	ANSELD,1
	goto	SysSelectEnd2
SysSelect2Case27
	movlw	26
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case28
	banksel	ANSELD
	bsf	ANSELD,2
	goto	SysSelectEnd2
SysSelect2Case28
	movlw	27
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case29
	banksel	ANSELD
	bsf	ANSELD,3
	goto	SysSelectEnd2
SysSelect2Case29
	movlw	28
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case30
	banksel	ANSELD
	bsf	ANSELD,4
	goto	SysSelectEnd2
SysSelect2Case30
	movlw	29
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case31
	banksel	ANSELD
	bsf	ANSELD,5
	goto	SysSelectEnd2
SysSelect2Case31
	movlw	30
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case32
	banksel	ANSELD
	bsf	ANSELD,6
	goto	SysSelectEnd2
SysSelect2Case32
	movlw	31
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case33
	banksel	ANSELD
	bsf	ANSELD,7
	goto	SysSelectEnd2
SysSelect2Case33
	movlw	32
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case34
	banksel	ANSELE
	bsf	ANSELE,0
	goto	SysSelectEnd2
SysSelect2Case34
	movlw	33
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelect2Case35
	banksel	ANSELE
	bsf	ANSELE,1
	goto	SysSelectEnd2
SysSelect2Case35
	movlw	34
	subwf	ADREADPORT,W
	btfss	STATUS, Z
	goto	SysSelectEnd2
	banksel	ANSELE
	bsf	ANSELE,2
SysSelectEnd2
	banksel	ADCON0
	bcf	ADCON0,ADCS
	movlw	1
	movwf	ADCLK
	bcf	ADCON0,ADCS
	movlw	15
	movwf	ADCLK
	bsf	ADCON0,ADFRM0
	bsf	ADCON0,ADFM0
	banksel	ADREADPORT
	movf	ADREADPORT,W
	banksel	ADPCH
	movwf	ADPCH
	bsf	ADCON0,ADON
	movlw	2
	movwf	SysWaitTemp10US
	banksel	STATUS
	pagesel	Delay_10US
	call	Delay_10US
	pagesel	$
	banksel	ADCON0
	bsf	ADCON0,GO_NOT_DONE
	nop
SysWaitLoop2
	btfsc	ADCON0,GO_NOT_DONE
	goto	SysWaitLoop2
	bcf	ADCON0,ADON
	banksel	ANSELA
	clrf	ANSELA
	clrf	ANSELB
	clrf	ANSELC
	clrf	ANSELD
	clrf	ANSELE
	banksel	ADRESL
	movf	ADRESL,W
	banksel	READAD10
	movwf	READAD10
	clrf	READAD10_H
	banksel	ADRESH
	movf	ADRESH,W
	banksel	READAD10_H
	movwf	READAD10_H
	banksel	ADCON0
	bcf	ADCON0,ADFRM0
	banksel	STATUS
	return

;********************************************************************************

WALLHUG
	movf	WALL1DIST,W
	movwf	SysWORDTempA
	movf	WALL1DIST_H,W
	movwf	SysWORDTempA_H
	movlw	9
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysByteTempX,W
	movwf	SysTemp3
	movf	IMMUNE,W
	movwf	SysBYTETempA
	movlw	2
	movwf	SysBYTETempB
	pagesel	SysCompEqual
	call	SysCompEqual
	pagesel	$
	comf	SysByteTempX,F
	movf	SysTemp3,W
	andwf	SysByteTempX,W
	movwf	SysTemp1
	btfss	SysTemp1,0
	goto	ELSE19_1
	pagesel	FN_WALLCHECK
	call	FN_WALLCHECK
	pagesel	$
	btfss	SYSBITVAR0,6
	goto	ELSE20_1
	movlw	5
	movwf	DIRECTION
	movlw	10
	movwf	TIME
	call	ADDDIRECTION
	goto	ENDIF20
ELSE20_1
	movlw	2
	movwf	IMMUNE
	clrf	MINWALL
	clrf	MINWALL_H
	movlw	1
	movwf	DIRECTION
	movlw	20
	movwf	TIME
	call	ADDDIRECTION
ENDIF20
	goto	ENDIF19
ELSE19_1
	movf	WALL1DIST,W
	movwf	SysWORDTempB
	movf	WALL1DIST_H,W
	movwf	SysWORDTempB_H
	movlw	15
	movwf	SysWORDTempA
	clrf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	movf	SysByteTempX,W
	movwf	SysTemp3
	movf	IMMUNE,W
	movwf	SysBYTETempA
	movlw	1
	movwf	SysBYTETempB
	pagesel	SysCompEqual
	call	SysCompEqual
	pagesel	$
	comf	SysByteTempX,F
	movf	SysTemp3,W
	andwf	SysByteTempX,W
	movwf	SysTemp1
	btfss	SysTemp1,0
	goto	ELSE19_2
	pagesel	FN_WALLCHECK
	call	FN_WALLCHECK
	pagesel	$
	btfss	SYSBITVAR0,6
	goto	ELSE21_1
	movlw	6
	movwf	DIRECTION
	movlw	10
	movwf	TIME
	call	ADDDIRECTION
	goto	ENDIF21
ELSE21_1
	movlw	1
	movwf	IMMUNE
	clrf	MINWALL
	clrf	MINWALL_H
	movlw	1
	movwf	DIRECTION
	movlw	20
	movwf	TIME
	call	ADDDIRECTION
ENDIF21
	goto	ENDIF19
ELSE19_2
	movf	WALL1DIST,W
	movwf	SysWORDTempB
	movf	WALL1DIST_H,W
	movwf	SysWORDTempB_H
	movlw	15
	movwf	SysWORDTempA
	clrf	SysWORDTempA_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	movf	SysByteTempX,W
	movwf	SysTemp3
	movf	WALL1DIST,W
	movwf	SysWORDTempA
	movf	WALL1DIST_H,W
	movwf	SysWORDTempA_H
	movlw	9
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	pagesel	SysCompLessThan16
	call	SysCompLessThan16
	pagesel	$
	comf	SysByteTempX,F
	movf	SysTemp3,W
	andwf	SysByteTempX,W
	movwf	SysTemp1
	btfsc	SysTemp1,0
	clrf	IMMUNE
	pagesel	FW
	call	FW
	pagesel	$
ENDIF19
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
BW
	bcf	LATD,3
	bsf	LATD,2
	bcf	LATD,0
	bsf	LATD,1
	return

;********************************************************************************

CLEARQUEUE
	movf	POINTERSTART,W
	movwf	POINTEREND
	return

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

FN_FLAMECHECK
	movf	FLAMEIN,W
	movwf	SysWORDTempA
	movf	FLAMEIN_H,W
	movwf	SysWORDTempA_H
	movf	MAXFLAME,W
	movwf	SysWORDTempB
	movf	MAXFLAME_H,W
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	btfss	SysByteTempX,0
	goto	ELSE18_1
	bsf	SYSBITVAR0,5
	movf	FLAMEIN,W
	movwf	MAXFLAME
	movf	FLAMEIN_H,W
	movwf	MAXFLAME_H
	goto	ENDIF18
ELSE18_1
	movf	FLAMEIN,W
	movwf	SysWORDTempA
	movf	FLAMEIN_H,W
	movwf	SysWORDTempA_H
	movlw	10
	movwf	SysWORDTempB
	clrf	SysWORDTempB_H
	call	SysDivSub16
	movf	SysWORDTempA,W
	movwf	SysTemp1
	movf	SysWORDTempA_H,W
	movwf	SysTemp1_H
	movf	SysTemp1,W
	addwf	FLAMEIN,W
	movwf	SysTemp2
	movf	SysTemp1_H,W
	addwfc	FLAMEIN_H,W
	movwf	SysTemp2_H
	movf	SysTemp2,W
	movwf	SysWORDTempB
	movf	SysTemp2_H,W
	movwf	SysWORDTempB_H
	movf	MAXFLAME,W
	movwf	SysWORDTempA
	movf	MAXFLAME_H,W
	movwf	SysWORDTempA_H
	call	SysCompLessThan16
	comf	SysByteTempX,F
	btfss	SysByteTempX,0
	goto	ELSE18_2
	bsf	SYSBITVAR0,5
	goto	ENDIF18
ELSE18_2
	bcf	SYSBITVAR0,5
ENDIF18
	return

;********************************************************************************

FW
	bsf	LATD,3
	bcf	LATD,2
	bsf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

HARD_STOP
	bsf	LATD,3
	bsf	LATD,2
	bsf	LATD,0
	bsf	LATD,1
	return

;********************************************************************************

;Overloaded signature: BYTE:BYTE:BYTE:
INITTIMER0171
	movlw	240
	andwf	T0CON1,W
	movwf	SysTemp3
	iorwf	TMRPRES,F
	decf	TMRSOURCE,W
	btfsc	STATUS, Z
	goto	ELSE61_1
	bsf	TMRPOST,5
	goto	ENDIF61
ELSE61_1
	bcf	TMRPOST,5
ENDIF61
	movf	TMRPRES,W
	movwf	T0CON1
	movlw	224
	andwf	T0CON0,W
	movwf	SysTemp3
	iorwf	TMRPOST,F
	bcf	TMRPOST,4
	movf	TMRPOST,W
	movwf	T0CON0
	return

;********************************************************************************

LCDNORMALWRITEBYTE
SysWaitLoop4
	call	FN_LCDREADY
	movf	LCDREADY,F
	btfsc	STATUS,Z
	goto	SysWaitLoop4
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
	goto	ENDIF51
	movlw	16
	subwf	LCDBYTE,W
	btfsc	STATUS, C
	goto	ENDIF52
	movf	LCDBYTE,W
	sublw	7
	btfsc	STATUS, C
	goto	ENDIF53
	movf	LCDBYTE,W
	movwf	LCD_STATE
ENDIF53
ENDIF52
ENDIF51
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
	goto	ENDIF40
	movlw	255
	movwf	LCDREADY
ENDIF40
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
	goto	ENDIF30
	movlw	2
	subwf	LCDLINE,F
	movlw	16
	addwf	LCDCOLUMN,F
ENDIF30
	movf	LCDLINE,W
	movwf	SysBYTETempA
	movlw	64
	movwf	SysBYTETempB
	call	SysMultSub
	movf	LCDCOLUMN,W
	addwf	SysBYTETempX,W
	movwf	SysTemp3
	movlw	128
	iorwf	SysTemp3,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
	movlw	5
	movwf	SysWaitTemp10US
	goto	Delay_10US

;********************************************************************************

;Overloaded signature: STRING:
PRINT126
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
	goto	SysForLoopEnd4
SysForLoop4
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
	goto	SysForLoop4
SysForLoopEnd4
	return

;********************************************************************************

;Overloaded signature: BYTE:
PRINT127
	clrf	LCDVALUETEMP
	bsf	LATB,0
	movlw	100
	subwf	LCDVALUE,W
	btfss	STATUS, C
	goto	ENDIF34
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	100
	movwf	SysBYTETempB
	call	SysDivSub
	movf	SysBYTETempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
ENDIF34
	movf	LCDVALUETEMP,W
	movwf	SysBYTETempB
	clrf	SysBYTETempA
	call	SysCompLessThan
	movf	SysByteTempX,W
	movwf	SysTemp3
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	10
	movwf	SysBYTETempB
	call	SysCompLessThan
	comf	SysByteTempX,F
	movf	SysTemp3,W
	iorwf	SysByteTempX,W
	movwf	SysTemp1
	btfss	SysTemp1,0
	goto	ENDIF35
	movf	LCDVALUE,W
	movwf	SysBYTETempA
	movlw	10
	movwf	SysBYTETempB
	call	SysDivSub
	movf	SysBYTETempA,W
	movwf	LCDVALUETEMP
	movf	SYSCALCTEMPX,W
	movwf	LCDVALUE
	movlw	48
	addwf	LCDVALUETEMP,W
	movwf	LCDBYTE
	call	LCDNORMALWRITEBYTE
ENDIF35
	movlw	48
	addwf	LCDVALUE,W
	movwf	LCDBYTE
	goto	LCDNORMALWRITEBYTE

;********************************************************************************

SLIGHT_LEFT
	bsf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

SLIGHT_RIGHT
	bcf	LATD,3
	bcf	LATD,2
	bsf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

STARTTIMER
	movf	TMRNUMBER,F
	btfsc	STATUS, Z
	bsf	T0CON0,T0EN
	decf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF55
	banksel	T1CON
	bsf	T1CON,TMR1ON
ENDIF55
	movlw	2
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF56
	banksel	T2CON
	bsf	T2CON,TMR2ON
ENDIF56
	movlw	3
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF57
	banksel	T3CON
	bsf	T3CON,TMR3ON
ENDIF57
	movlw	4
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF58
	banksel	T4CON
	bsf	T4CON,TMR4ON
ENDIF58
	movlw	5
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF59
	banksel	T5CON
	bsf	T5CON,TMR5ON
ENDIF59
	movlw	6
	banksel	TMRNUMBER
	subwf	TMRNUMBER,W
	btfss	STATUS, Z
	goto	ENDIF60
	banksel	T6CON
	bsf	T6CON,TMR6ON
ENDIF60
	banksel	STATUS
	return

;********************************************************************************

STOP
	bcf	LATD,3
	bcf	LATD,2
	bcf	LATD,0
	bcf	LATD,1
	return

;********************************************************************************

SYSCOMPEQUAL
	clrf	SYSBYTETEMPX
	movf	SYSBYTETEMPA, W
	subwf	SYSBYTETEMPB, W
	btfsc	STATUS, Z
	comf	SYSBYTETEMPX,F
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

SYSCOMPLESSTHAN
	clrf	SYSBYTETEMPX
	bsf	STATUS, C
	movf	SYSBYTETEMPB, W
	subwf	SYSBYTETEMPA, W
	btfss	STATUS, C
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

SYSDIVSUB
	movf	SYSBYTETEMPB, F
	btfsc	STATUS, Z
	return
	clrf	SYSBYTETEMPX
	movlw	8
	movwf	SYSDIVLOOP
SYSDIV8START
	bcf	STATUS, C
	rlf	SYSBYTETEMPA, F
	rlf	SYSBYTETEMPX, F
	movf	SYSBYTETEMPB, W
	subwf	SYSBYTETEMPX, F
	bsf	SYSBYTETEMPA, 0
	btfsc	STATUS, C
	goto	DIV8NOTNEG
	bcf	SYSBYTETEMPA, 0
	movf	SYSBYTETEMPB, W
	addwf	SYSBYTETEMPX, F
DIV8NOTNEG
	decfsz	SYSDIVLOOP, F
	goto	SYSDIV8START
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
	goto	ENDIF62
	clrf	SYSWORDTEMPA
	clrf	SYSWORDTEMPA_H
	return
ENDIF62
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
	goto	ENDIF63
	bcf	SYSDIVMULTA,0
	movf	SYSDIVMULTB,W
	addwf	SYSDIVMULTX,F
	movf	SYSDIVMULTB_H,W
	addwfc	SYSDIVMULTX_H,F
ENDIF63
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
	retlw	13
	retlw	69	;E
	retlw	88	;X
	retlw	84	;T
	retlw	73	;I
	retlw	78	;N
	retlw	71	;G
	retlw	85	;U
	retlw	73	;I
	retlw	83	;S
	retlw	72	;H
	retlw	73	;I
	retlw	78	;N
	retlw	71	;G


StringTable2
	retlw	17
	retlw	35	;#
	retlw	49	;1
	retlw	32	; 
	retlw	86	;V
	retlw	73	;I
	retlw	67	;C
	retlw	84	;T
	retlw	79	;O
	retlw	82	;R
	retlw	89	;Y
	retlw	32	; 
	retlw	82	;R
	retlw	79	;O
	retlw	89	;Y
	retlw	65	;A
	retlw	76	;L
	retlw	69	;E


StringTable3
	retlw	1
	retlw	32	; 


;********************************************************************************

TIMEROVERFLOW
	incf	OVERFLOWS,F
	btfsc	STATUS,Z
	incf	OVERFLOWS_H,F
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

FN_WALLCHECK
	movf	WALL1IN,W
	movwf	SysWORDTempA
	movf	WALL1IN_H,W
	movwf	SysWORDTempA_H
	movf	MINWALL,W
	movwf	SysWORDTempB
	movf	MINWALL_H,W
	movwf	SysWORDTempB_H
	call	SysCompLessThan16
	btfss	SysByteTempX,0
	goto	ELSE64_1
	bsf	SYSBITVAR0,6
	movf	WALL1IN,W
	movwf	MINWALL
	movf	WALL1IN_H,W
	movwf	MINWALL_H
	goto	ENDIF64
ELSE64_1
	bcf	SYSBITVAR0,6
ENDIF64
	return

;********************************************************************************

;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
