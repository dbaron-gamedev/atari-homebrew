;===============================================================================
; Program Information
;===============================================================================

    ; Game:      	Phazer
    ; Program by:   David Baron
    ; Last Update:  June 25, 2014
    ;
    ; Super simple game in which you must avoid getting scan by a force field.
    ; developing Atari 2600 homebrew games.
    ;
    ; See readme.txt for compile instructions

;===============================================================================
; Change Log
;===============================================================================
 
    ; 2013.06.24 - generate a stable display
    ; 2013.06.25 - add timers 

;===============================================================================
; Initialize dasm
;===============================================================================

    ; Dasm supports a number of processors, this line tells dasm the code
    ; is for the 6502 CPU.  The Atari has a 6507, which is 6502 that's been
    ; put into a "reduced package".  This package limits the 6507 to an 8K
    ; address space and also removes support for external interrupts.
	processor 6502
	
	; vcs.h contains the standard definitions for TIA and RIOT registers 
	include vcs.h

;===============================================================================
; Define RAM Usage
;===============================================================================

    ; RAM starts at $80
    org $F000         

;===============================================================================
; Define RAM Usage
;=============================================================================

YPosFromBot = $80;
VisiblePlayerLine = $81;
PlayerBuffer = $82 ; Setup an extra variable

Hits = $83			; Hit counter			
isGameOver = $84	; Will be used a game state boolean

;===============================================================================
; Initialize Atari
;===============================================================================
Start
	SEI	
	CLD  	
	LDX #$FF	
	TXS	
	LDA #0		
ClearMem 
	STA 0,X		
	DEX		
	BNE ClearMem	
	
	LDA #$00   ; Start with a black background
	STA COLUBK	
	LDA #$0E   ; White player sprite
	STA COLUP0
	
; Setting some variables...
	LDA #80
	STA YPosFromBot	; Initial Y Position

;; Let's set up the sweeping line. as Missile 1
	LDA #2
	STA ENAM1  ; Enable it
	LDA #00
	STA COLUP1 ; Color it

	LDA #$10	
	STA NUSIZ1	; Make it quadwidth (not so thin, that)
	
	LDA #$F0	; -1 in the left nibble (I can change direction of the phase here)
	STA HMM1	; of HMM1 sets it to moving

;VSYNC time
MainLoop
	LDA #2
	STA VSYNC	
	STA WSYNC	
	STA WSYNC 	
	STA WSYNC	
	LDA #43	
	STA TIM64T	
	LDA #0
	STA VSYNC 	

; Input manager entry point
	LDA #%00010000	;Down?
	BIT SWCHA 
	BNE SkipMoveDown
	INC YPosFromBot

SkipMoveDown
	LDA #%00100000	;Up?
	BIT SWCHA 
	BNE SkipMoveUp
	DEC YPosFromBot

SkipMoveUp
; for left and right, we're gonna 
; set the horizontal speed, and then do
; a single HMOVE.  We'll use X to hold the
; horizontal speed, then store it in the 
; appropriate register

;assum horiz speed will be zero
	LDX #0	
	LDA #%01000000	;Left?
	BIT SWCHA 
	BNE SkipMoveLeft
	LDX #$10		;a 1 in the left nibble means go left
	LDA #%00001000  ;a 1 in D3 of REFP0 says make it mirror
	STA REFP0

SkipMoveLeft
	LDA #%10000000	;Right?
	BIT SWCHA 
	BNE SkipMoveRight
	LDX #$F0	;a -1 in the left nibble means go right...
	LDA #%00000000
	STA REFP0    ;unmirror it

SkipMoveRight
	STX HMP0	;set the move for player 0, not the missile like last time...
	; see if player and missile collide, and change the background color if so
	LDA #%10000000
	BIT CXM1P		
	BEQ NoCollision	;skip if not hitting...
	LDA YPosFromBot	;must be a hit! load in the YPos...
	STA COLUBK	;and store as the bgcolor
	
; Detecting Collission Hit Counts
	INC Hits;
	LDX #20
	CPX Hits
	BNE PlayerNotDead
	LDA YPosFromBot
	STA COLUP0
	
	;TODO - I need to convert this 
	LDX #30	
	STX isGameOver

PlayerNotDead

NoCollision
	STA CXCLR			;reset the collision detection for next time
	LDA #0		 		;zero out the buffer
	STA PlayerBuffer 	;just in case

WaitForVblankEnd
	LDA INTIM	
	BNE WaitForVblankEnd	
	LDY #191 	
	STA WSYNC	
	STA HMOVE 	
	STA VBLANK  	

; main scanline loop...

	LDX isGameOver
	CPX #30
	BEQ EndGame

ScanLoop 
	STA WSYNC 	
	LDA PlayerBuffer ;buffer was set during last scanline
	STA GRP0         ;put it as graphics now

CheckActivatePlayer
	CPY YPosFromBot
	BNE SkipActivatePlayer
	LDA #8
	STA VisiblePlayerLine 

SkipActivatePlayer
	;set player buffer to all zeros for this line, and then see if 
	;we need to load it with graphic data
	LDA #0		
	STA PlayerBuffer   ;set buffer, not GRP0
	
	;
	;if the VisiblePlayerLine is non zero,
	;we're drawing it next line
	;
	LDX VisiblePlayerLine	;check the visible player line...
	BEQ FinishPlayer	;skip the drawing if its zero...

IsPlayerOn
	LDA BigHeadGraphic-1,X	;otherwise, load the correct line from BigHeadGraphic
				;section below... it's off by 1 though, since at zero
				;we stop drawing
	STA PlayerBuffer	;put that line as player graphic for the next line
	DEC VisiblePlayerLine 	;and decrement the line count

FinishPlayer
	DEY		
	BNE ScanLoop	

	LDA #2		
	STA WSYNC  	
	STA VBLANK 	
	LDX #30	
	JMP OverScanWait

EndGame				
	STA WSYNC 	; TODO - Implement a end sceen
	LDA #2		
	STA WSYNC  	
	STA VBLANK 	
	LDX #30	
	JMP OverScanWait

OverScanWait
	STA WSYNC
	DEX
	BNE OverScanWait
	JMP  MainLoop      

BigHeadGraphic
	.byte #%11111100
	.byte #%00111110
	.byte #%00011111
	.byte #%00001111
	.byte #%00001111
	.byte #%00011111
	.byte #%00111110
	.byte #%11111100

	org $FFFC
	.word Start
	.word Start