				PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
__Vectors
				DCD  0x20001000     ; stack pointer value when stack is empty
				DCD  Reset_Handler  ; reset vector

				AREA	myCode, CODE, READONLY
;--------------------------------------------------------------------
RCC_AHB1ENR		EQU		0x40023830
GPIOA_MODER		EQU		0x40020000
GPIOA_OSPEEDR	EQU		0x40020008
GPIOA_PUPDR		EQU		0x4002000C
	
GPIOB_MODER		EQU		0x40020400
GPIOB_OTYPER	EQU		0x40020404
GPIOB_OSPEEDR	EQU		0x40020408
GPIOB_PUPDR		EQU		0x4002000C
	
GPIOB_ODR		EQU		0x40020414	
GPIOA_IDR		EQU		0x40020010
;--------------------------------------------------------------------
				
				ENTRY
Reset_Handler

;--------------------------------------------------------------------
;Enabling The GPIOA and PA0 and PB1 settings
			MOV32  	r1, #RCC_AHB1ENR
			LDR		r2, [r1]
			ORR  	r2,r2, #0x00000003		;I/O Port A and B clock enabled
			STR		r2,[r1]

			MOV32  	r1, #GPIOA_MODER
			LDR		r2, [r1]
			AND  	r2,r2, #0xFFFFFFFC		;PA0 as input
			STR		r2,[r1]
	
			MOV32  	r1, #GPIOA_OSPEEDR
			LDR		r2, [r1]
			ORR  	r2,r2, #0xFFFFFFFC		;PA0 as 2MHZ
			STR		r2,[r1]
			
			MOV32  	r1, #GPIOA_PUPDR
			LDR		r2, [r1]
			ORR  	r2,r2, #0xFFFFFFFC		;PA0 no pull-up/ no pull-down
			STR		r2,[r1]
	
			MOV32  	r1, #GPIOB_MODER
			LDR		r2, [r1]
			AND  	r2,r2, #0xFFFFFFF3
			ORR  	r2,r2, #0xFFFFFFF4		;PB1 as Output
			STR		r2,[r1]
	
			MOV32  	r1, #GPIOB_OTYPER
			LDR		r2, [r1]
			ORR  	r2,r2, #0xFFFFFFFD		;PB1 as Output push-pull
			STR		r2,[r1]
			
			MOV32  	r1, #GPIOB_OSPEEDR
			LDR		r2, [r1]
			ORR  	r2,r2, #0xFFFFFFF3		;PB1 as 2MHZ
			STR		r2,[r1]
			
			MOV32  	r1, #GPIOB_PUPDR
			LDR		r2, [r1]
			ORR  	r2,r2, #0xFFFFFFF3		;PB1 no pull-up/ no pull-down
			STR		r2,[r1]
;--------------------------------------------------------------------	
;CheckingGPIOA0
			MOV32  	r1, #GPIOA_IDR  
CHECK		LDR	 	r2,[r1]
			CMP		r2,#1
			BEQ     Gauss  
			B       CHECK
			
; Loading Noise Data in mem
Gauss
			LDR		r0, adr1
			MOV		r1, #0x00000000
			MOV		r3, #0x00000121
			ADR		r4, NOISE
			SUB		r4, r4, #1
			
loopG		LDRB	r2, [r4, #1]!
			STRB    r2, [r0]  
			ADD		r0, r0, #1
			ADD		r1, r1, #1
			CMP		r1, r3
			BNE loopG
;-----------------------------------------
			LDR		r0, adr1
			LDR		r10, adr2
			ADD		r0, r0, #0x00000012	;Element Num.1 after padding
			MOV		r1, #0x00000000	;Column Counter
			MOV		r2, #0x00000000	;Row Counter	
			MOV		r6, #0x00000000	;Register Offset for store				
				
kernelG_col	LDR		r3, =0x00000000 ;Clear Acumulator
			
kernelG_row	LDRB	r4, [r0, #-17]	;x2 elements of the kernel
			ADD		r3, r3, r4
			LDRB	r4, [r0, #17]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #1]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #-1]
			ADD		r3, r3, r4
			MOV		r3, r3, LSL #1
			
			LDRB	r4, [r0, #-18]	;x1 elements of the kernel
			ADD		r3, r3, r4
			LDRB	r4, [r0, #18]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #16]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #-16]
			ADD		r3, r3, r4
			
			LDRB	r5, [r0]		;x4 elements of the kernel
			MOV		r5, r5, LSL #2	
			ADD		r3, r3, r5
			
			MOV		r3, r3, ASR #4	;devide by 16
			
			STRB     r3, [r10, +r6]	;storing the result
			ADD		r1, r1, #1
			ADD		r6, r6, #1
			ADD		r0, r0, #1
			LDR		r3, =0x00000000 ;Clear Acumulator
			CMP 	r1, #0x0000000F
			BNE		kernelG_row
			
			ADD		r0, r0, #2	;jumping to the next row
			ADD		r2, r2, #1
			LDR		r1, =0x00000000 ;Clear Column Counter
			CMP 	r2, #0x0000000F	
			BNE		kernelG_col		
;-----------------------------------------			
						
			; Loading PHTOTO Data in mem
			LDR		r0, adr3
			MOV		r1, #0x00000000
			MOV		r3, #0x00000121
			ADR		r9, PHOTO
			SUB		r9, r9, #1
			
loopE		LDRB	r2, [r9, #1]!
			STRB    r2, [r0]  
			ADD		r0, r0, #1
			ADD		r1, r1, #1
			CMP		r1, r3
			BNE loopE
;-----------------------------------------
			LDR		r0, adr3
			LDR		r10, adr4
			ADD		r0, r0, #0x00000012
			MOV		r1, #0x00000000	;Column Counter
			MOV		r2, #0x00000000	;Row Counter
			MOV		r6, #0x00000000	;Register Offset for store				
			
kernelE_col	LDR		r3, =0x00000000
			
kernelE_row	LDRB	r4, [r0, #-17]	;x1 elements of the kernel
			ADD		r3, r3, r4
			LDRB	r4, [r0, #17]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #1]
			ADD		r3, r3, r4
			LDRB	r4, [r0, #-1]
			ADD		r3, r3, r4
			
			LDRB	r5, [r0]		;x4 elements of the kernel
			MOV		r5, r5, LSL #2	
			SUB		r3, r3, r5
			
			MOV		r3, r3, ASR #2	;devide by 4
			ADD		r3, r3, #64		;Adding 64
			CMP 	r3, #100
			MOVMI	r3, #0
			MOVPL	r3, #255
			
			STRB    r3, [r10, +r6]	;storing the result
			ADD		r1, r1, #1
			ADD		r0, r0, #1
			ADD		r6, r6, #1
			LDR		r3, =0x00000000 ;Clear Acumulator
			CMP 	r1, #0x0000000F
			BNE		kernelE_row
			
			ADD		r0, r0, #2	;jumping to the next row
			ADD		r2, r2, #1
			LDR		r1, =0x00000000 ;Clear Column Counter
			CMP 	r2, #0x0000000F	
			BNE		kernelE_col
;Algorithm ends
			MOV32  	r1, #GPIOB_ODR
			LDR		r2, =0x00000002
			STR	 	r2,[r1]
;Infinite loop for debug	
loop
            B       loop
;END of code
;--------------------------------------
;Addresses

adr1	DCD 0x40010000
adr2	DCD 0x40010150
adr3	DCD 0x40010300
adr4	DCD 0x40010450

NOISE	DCB	129 ;start of noisy
		DCB	129
		DCB	109
		DCB	153
		DCB	143
		DCB	118
		DCB	158
		DCB	144
		DCB	42
		DCB	102
		DCB	175
		DCB	157
		DCB 133
		DCB	114
		DCB	177
		DCB	72
		DCB	72
		
		DCB	129
		DCB	129
		DCB	109
		DCB	153
		DCB	143
		DCB	118
		DCB	158
		DCB	144
		DCB	42
		DCB	102
		DCB	175
		DCB	157
		DCB 133	
		DCB	114
		DCB	177
		DCB	72
		DCB	72
		
		DCB	102
		DCB	102
		DCB	110
		DCB	157
		DCB	109
		DCB	97
		DCB	111
		DCB	114
		DCB	6
		DCB	102
		DCB	99
		DCB	86
		DCB	122
		DCB	122
		DCB	183
		DCB	151
		DCB	151
			
		DCB	83
		DCB	83
		DCB	107
		DCB	103
		DCB	133
		DCB	137
		DCB	39
		DCB	130
		DCB	2
		DCB	103
		DCB	110
		DCB	75
		DCB 93 
		DCB 94	
		DCB 135	
		DCB	121
		DCB 121
		DCB 105
		DCB 105 
		DCB 99
		DCB 144 
		DCB 81 
		DCB 116
		DCB 80 
		DCB 125 
		DCB 48
		DCB 102
		DCB 107 
		DCB 108
		DCB 77
		DCB 95 
		DCB 100
		DCB 108
		DCB 108	
		
		DCB 95
		DCB 95
		DCB 100
		DCB 66
		DCB 85
		DCB 108
		DCB 66
		DCB 126
		DCB 22
		DCB 71
		DCB 53
		DCB 98
		DCB 88
		DCB 147
		DCB 137
		DCB 100
		DCB 100

		DCB 192
		DCB 192
		DCB 73
		DCB 79
		DCB 119
		DCB 119
		DCB 136
		DCB 113
		DCB 7
		DCB 112
		DCB 85
		DCB 80
		DCB 141
		DCB 132
		DCB 36
		DCB 87
		DCB 87

		DCB 144
		DCB 144
		DCB 144
		DCB 135
		DCB 122
		DCB 172
		DCB 122
		DCB 118
		DCB 0
		DCB 137
		DCB 101
		DCB 140
		DCB 85
		DCB 102
		DCB 127
		DCB 118
		DCB 118
		
		DCB 32
		DCB 32
		DCB 28
		DCB 27
		DCB 0
		DCB 25
		DCB 0
		DCB 29
		DCB 42
		DCB 38
		DCB 14
		DCB 0
		DCB 34
		DCB 0
		DCB 0
		DCB 59
		DCB 59

		DCB 114
		DCB 114
		DCB 130
		DCB 100
		DCB 184
		DCB 113
		DCB 124
		DCB 97
		DCB 8
		DCB 104
		DCB 151
		DCB 58
		DCB 62
		DCB 65
		DCB 120
		DCB 140
		DCB 140

		DCB 122
		DCB 122
		DCB 44
		DCB 116
		DCB 78
		DCB 82
		DCB 141
		DCB 93
		DCB 0
		DCB 111
		DCB 57
		DCB 63
		DCB 99
		DCB 61
		DCB 110
		DCB 139
		DCB 139
			
		DCB 116
		DCB 116
		DCB 107
		DCB 169
		DCB 45
		DCB 159
		DCB 106
		DCB 123
		DCB 0
		DCB 112
		DCB 121
		DCB 97
		DCB 116
		DCB 133
		DCB 101
		DCB 102
		DCB 102
			
		DCB 68
		DCB 68
		DCB 40
		DCB 158
		DCB 88
		DCB 100
		DCB 143
		DCB 115
		DCB 57
		DCB 141
		DCB 153
		DCB 114
		DCB 48
		DCB 62
		DCB 117
		DCB 81
		DCB 81

		DCB 137
		DCB 137
		DCB 69
		DCB 78
		DCB 117
		DCB 106
		DCB 85
		DCB 126
		DCB 19
		DCB 91
		DCB 87
		DCB 82
		DCB 100
		DCB 82
		DCB 83
		DCB 112
		DCB 112

		DCB 145
		DCB 145
		DCB 144
		DCB 132
		DCB 95
		DCB 121
		DCB 148
		DCB 85
		DCB 67
		DCB 72
		DCB 166
		DCB 153
		DCB 87
		DCB 80
		DCB 77
		DCB 127
		DCB 127
			
		DCB 131
		DCB 131
		DCB 141
		DCB 166
		DCB 134
		DCB 171
		DCB 129
		DCB 128
		DCB 9
		DCB 112
		DCB 116
		DCB 74
		DCB 113
		DCB 73
		DCB 64
		DCB 122
		DCB 122

		DCB 131
		DCB 131
		DCB 141
		DCB 166
		DCB 134
		DCB 171
		DCB 129
		DCB 128
		DCB 9
		DCB 112
		DCB 116
		DCB 74
		DCB 113
		DCB 73
		DCB 64
		DCB 122
		DCB 122
		;End of noisy

PHOTO	DCB	129 ;start of photo
		DCB	129
		DCB	124
		DCB	130
		DCB	126
		DCB	127
		DCB	122
		DCB	129
		DCB	14
		DCB	128
		DCB	118
		DCB	125
		DCB 128
		DCB	130
		DCB	138
		DCB	125
		DCB	125
		
		DCB	129 
		DCB	129
		DCB	124
		DCB	130
		DCB	126
		DCB	127
		DCB	122
		DCB	129
		DCB	14
		DCB	128
		DCB	118
		DCB	125
		DCB 128
		DCB	130
		DCB	138
		DCB	125
		DCB	125
		
		DCB	112
		DCB	112
		DCB	99
		DCB	145
		DCB	131
		DCB	99
		DCB	117
		DCB	128
		DCB	29
		DCB	118
		DCB 93
		DCB	111
		DCB	119
		DCB	133
		DCB	158
		DCB	145
		DCB	145
			
		DCB	105
		DCB	105
		DCB	97
		DCB	104
		DCB	111
		DCB	134
		DCB	96
		DCB	127
		DCB 11
		DCB	125
		DCB	114
		DCB	98
		DCB 109 
		DCB 129
		DCB 114	
		DCB	129
		DCB 129
		
		DCB 107
		DCB 107 
		DCB 109
		DCB 117 
		DCB 92
		DCB 81
		DCB 105 
		DCB 129 
		DCB 6
		DCB 126
		DCB 111 
		DCB 93
		DCB 78
		DCB 121 
		DCB 105
		DCB 118
		DCB 118	
		
		DCB 101
		DCB 101
		DCB 99
		DCB 75
		DCB 101
		DCB 100
		DCB 108
		DCB 122
		DCB 0
		DCB 125
		DCB 76
		DCB 79
		DCB 90
		DCB 94
		DCB 122
		DCB 118
		DCB 118

		DCB 120
		DCB 120
		DCB 71
		DCB 68
		DCB 112
		DCB 116
		DCB 125
		DCB 114
		DCB 1
		DCB 125
		DCB 90
		DCB 75
		DCB 115
		DCB 103
		DCB 79
		DCB 99
		DCB 99

		DCB 129
		DCB 129
		DCB 126
		DCB 127
		DCB 126
		DCB 130
		DCB 128
		DCB 118
		DCB 2
		DCB 115
		DCB 115
		DCB 111
		DCB 119
		DCB 129
		DCB 127
		DCB 128
		DCB 128
		
		DCB 16
		DCB 16
		DCB 25
		DCB 15
		DCB 18
		DCB 4
		DCB 1
		DCB 4
		DCB 35
		DCB 6
		DCB 7
		DCB 7
		DCB 18
		DCB 20
		DCB 14
		DCB 21
		DCB 21
		
		DCB 128
		DCB 128
		DCB 126
		DCB 128
		DCB 128
		DCB 127
		DCB 115
		DCB 118
		DCB 8
		DCB 125
		DCB 120
		DCB 87
		DCB 90
		DCB 108
		DCB 96
		DCB 122
		DCB 122

		DCB 129
		DCB 129
		DCB 93
		DCB 91
		DCB 104
		DCB 76
		DCB 97
		DCB 129
		DCB 6
		DCB 121
		DCB 96
		DCB 80
		DCB 89
		DCB 109
		DCB 116
		DCB 113
		DCB 113

		DCB 129
		DCB 129
		DCB 117
		DCB 102
		DCB 91
		DCB 108
		DCB 90
		DCB 128
		DCB 14
		DCB 115
		DCB 108
		DCB 111
		DCB 105
		DCB 90
		DCB 109
		DCB 100
		DCB 100

		DCB 125
		DCB 125
		DCB 94
		DCB 117
		DCB 78
		DCB 124
		DCB 124
		DCB 124
		DCB 29
		DCB 113
		DCB 117
		DCB 115
		DCB 106
		DCB 80
		DCB 100
		DCB 100
		DCB 100
		
		DCB 120
		DCB 120
		DCB 95
		DCB 81
		DCB 119
		DCB 87
		DCB 103
		DCB 127
		DCB 31
		DCB 109
		DCB 111
		DCB 111
		DCB 87
		DCB 86
		DCB 86
		DCB 114
		DCB 114
		
		DCB 120
		DCB 120
		DCB 103
		DCB 113
		DCB 125
		DCB 109
		DCB 124
		DCB 121
		DCB 9
		DCB 101
		DCB 86
		DCB 118
		DCB 104
		DCB 100
		DCB 78
		DCB 117
		DCB 117
		
		DCB 128
		DCB 128
		DCB 128
		DCB 130
		DCB 145
		DCB 127
		DCB 123
		DCB 123
		DCB 0
		DCB 114
		DCB 95
		DCB 93
		DCB 112
		DCB 84
		DCB 105
		DCB 122
		DCB 122
			
		DCB 128
		DCB 128
		DCB 128
		DCB 130
		DCB 145
		DCB 127
		DCB 123
		DCB 123
		DCB 0
		DCB 114
		DCB 95
		DCB 93
		DCB 112
		DCB 84
		DCB 105
		DCB 122
		DCB 122	
		;End of photo

;**********************************************************************************
			END