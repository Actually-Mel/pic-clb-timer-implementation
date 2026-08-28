
; PIC16F13115 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FEXTOSC = OFF         ; External Oscillator Selection bits (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_1MHz; Reset Oscillator Selection bits (HFINTOSC (1MHz))
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable bit (CLKOUT function is disabled; i/o or oscillator function on OSC2)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  VDDAR = HI            ; VDD Range Analog Calibration Selection bit (Internal analog systems are calibrated for operation between VDD = 2.3 - 5.5V)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)

; CONFIG2
  CONFIG  MCLRE = EXTMCLR       ; Master Clear Enable bit (If LVP = 0, MCLR pin is MCLR; If LVP = 1, RA3 pin function is MCLR)
  CONFIG  PWRTS = PWRT_OFF      ; Power-up Timer Selection bits (PWRT is disabled)
  CONFIG  LPBOREN = OFF         ; Low-Power BOR Enable bit (ULPBOR disabled)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable bits (Brown-out Reset enabled, SBOREN bit is ignored)
  CONFIG  DACAUTOEN = OFF       ; DAC Buffer Automatic Range Select Enable bit (DAC Buffer reference range is determined by the REFRNG bit)
  CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection bit (Brown-out Reset Voltage (VBOR) set to 1.9V)
  CONFIG  PPS1WAY = OFF         ; PPSLOCKED One-Way Set Enable bit (The PPSLOCKED bit can be set and cleared as needed (unlocking sequence is required))
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable bit (Stack Overflow or Underflow will cause a reset)
  CONFIG  DEBUG = OFF           ; Background Debugger (Background Debugger disabled)

; CONFIG3
  CONFIG  WDTCPS = WDTCPS_31    ; WDT Period Select bits (Divider ratio 1:65536; software control of WDTPS)
  CONFIG  WDTE = OFF            ; WDT Operating Mode bits (WDT Disabled, SEN is ignored)
  CONFIG  WDTCWS = WDTCWS_7     ; WDT Window Select bits (window always open (100%); software control; keyed access not required)
  CONFIG  WDTCCS = SC           ; WDT Input Clock Select bits (Software Control)

; CONFIG4
  CONFIG  BBSIZE = BB512        ; Boot Block Size Selection bits (512 words boot block size)
  CONFIG  BBEN = OFF            ; Boot Block Enable bit (Boot Block disabled)
  CONFIG  SAFEN = OFF           ; Storage Area Flash (SAF) Enable bit (SAF disabled)
  CONFIG  WRTAPP = OFF          ; Application Block Write Protection bit (Application Block is NOT write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block is NOT write-protected)
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration Register is NOT write-protected)
  CONFIG  WRTSAF = OFF          ; Storage Area Flash (SAF) Write Protection bit (SAF is NOT write-protected)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low Voltage programming enabled. MCLR/Vpp pin function is MCLR. MCLRE Configuration bit is ignored)

; CONFIG5
  CONFIG  CP = OFF              ; Program Flash Memory Code Protection bit (Program Flash Memory code protection is disabled)

// config statements should precede project file includes.
#include <xc.inc>
  
//-Wl,-presetVec=0x0000 -Wl,-pintVecLo=0x0004 -Wl,-pcode=0x0010
  
PSECT resetVec class=CODE, delta=2
resetVec:
    GOTO init
    GOTO init	; no, seriously
    GOTO init	; GO TO INIT

PSECT intVecLo class=CODE, delta=2
intVecLo:
    RETFIE

PSECT code class=CODE, delta=2
init:
    BANKSEL ANSELA
    BCF ANSELA, 2   ; Disable analog on pin RA2
    
    BANKSEL LATA
    BCF LATA, 2	    ; Drive pin RA2 low by default
    BCF TRISA, 2    ; Make RA2 a digital output pin
    
    BANKSEL RA2PPS
    MOVLW 0x24
    MOVWF RA2PPS    ; CLB_OUT0 mapped to pin RA2
    
clb_clock_init:
    BANKSEL CLBCLK
    MOVLW 0b1001
    MOVWF CLBCLK    ; MFINTOSC (32 kHz) selected as the CLB clock
    
    CLRF CLBCON	    ; Disable CLB
    
scanner_init:
    BANKSEL SCANDPS
    BSF SCANDPS, 0  ; Selects CLB as the memory scanner user
    
    MOVLW 0b01
    MOVWF SCANCON0  ; Burst mode selected. The scanner will stall the CPU
		    ; until its done loading the bitstream into the CLB
	
    ; Loading bitstream start address
    MOVLW HIGH(clb_start_bitstream)
    MOVWF SCANLADRH
    MOVLW LOW(clb_start_bitstream)
    MOVWF SCANLADRL
    
    ; Loading bitstream end address
    MOVLW HIGH(clb_end_bitstream)
    MOVWF SCANHADRH
    MOVLW LOW(clb_end_bitstream)
    MOVWF SCANHADRL
    
    BSF SCANCON0, 7	; Enable memory scanner
    BSF SCANCON0, 6	; Kickstart memory scanner
    
    ; The memory scanner will stall the CPU until it's done
    
    BCF SCANCON0, 6	; Stop memory scanner
    BCF SCANCON0, 7	; Disable memory scanner
    
clb_init:
    BANKSEL CLBCON
    BSF CLBCON, 7   ; Enable the CLB
    
    MOVLW 10
    MOVWF CLBSWINM  ; Configuring the period of the CLB timer implementation
    
; CLBSWIN is a 32-bit register.
; Writing CLBSWINL latches all four software-input bytes.
    
    MOVWF CLBSWINL
    
main:
    SLEEP
    NOP
    NOP
    GOTO main
    
clb_start_bitstream:
    dw  0x0830;
    dw  0x3801;
    dw  0x0031;
    dw  0x084C;
    dw  0x10A8;
    dw  0x039F;
    dw  0x3079;
    dw  0x3D9F;
    dw  0x03FF;
    dw  0x3C06;
    dw  0x1FFC;
    dw  0x3F80;
    dw  0x33EC;
    dw  0x3F9F;
    dw  0x3267;
    dw  0x3C60;
    dw  0x0080;
    dw  0x0401;
    dw  0x1015;
    dw  0x10A2;
    dw  0x07E1;
    dw  0x041F;
    dw  0x3000;
    dw  0x0E61;
    dw  0x00F5;
    dw  0x3C00;
    dw  0x35FA;
    dw  0x015F;
    dw  0x2BEA;
    dw  0x3E06;
    dw  0x1860;
    dw  0x0EDF;
    dw  0x0001;
    dw  0x3D5F;
    dw  0x1429;
    dw  0x0410;
    dw  0x0049;
    dw  0x0A1F;
    dw  0x03E1;
    dw  0x3E1F;
    dw  0x00C0;
    dw  0x0D1F;
    dw  0x105C;
    dw  0x0981;
    dw  0x3026;
    dw  0x0207;
    dw  0x2810;
    dw  0x0641;
    dw  0x33F9;
    dw  0x059F;
    dw  0x19FA;
    dw  0x0F5F;
    dw  0x2BEA;
    dw  0x3F9F;
    dw  0x3099;
    dw  0x3F9F;
    dw  0x33F8;
    dw  0x359F;
    dw  0x19FC;
    dw  0x3E64;
    dw  0x30D3;
    dw  0x3F07;
    dw  0x08F0;
    dw  0x1E5F;
    dw  0x00F0;
    dw  0x1D47;
    dw  0x240A;
    dw  0x0F5F;
    dw  0x03F0;
    dw  0x0285;
    dw  0x00A0;
    dw  0x1C87;
    dw  0x33F8;
    dw  0x3C7F;
    dw  0x0660;
    dw  0x3E1F;
    dw  0x03F0;
    dw  0x3E06;
    dw  0x2060;
    dw  0x0EE5;
    dw  0x33F8;
    dw  0x059F;
    dw  0x19FC;
    dw  0x3F92;
    dw  0x33EC;
    dw  0x3F16;
    dw  0x23F1;
    dw  0x3D1F;
    dw  0x23F1;
    dw  0x3D1F;
    dw  0x11F8;
    dw  0x3F1F;
    dw  0x23E8;
    dw  0x3F1F;
    dw  0x23F1;
    dw  0x3D1F;
    dw  0x0060;
    dw  0x0000;
    dw  0x0000;
    dw  0x0000;
    dw  0x3800;
clb_end_bitstream: dw  0x0006;
