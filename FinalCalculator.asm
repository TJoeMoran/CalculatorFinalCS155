;****************************************************************
; Name: Joseph Moran
; Date: 4/28/2025
; Description: 
;
; Register Usage:
;   R0 - reserved for TRAP output
;   R1 - reserved for function return values
;   R2 - holds first number for calculation
;   R3 - holds second number for calculation
;   R4 - holds operand choice
;   R5 - used for choosing calculation
;   R6 - stack pointer
;   R7 - reserved for RET
;****************************************************************
        .ORIG x3000
        
        ;initialize stack pointer
        LD R6,Stack
        
        ;get first two digits
        ;get operator
        ;get 2nd two digits
        LEA R0,INPUT_PROMPT
        PUTS
GET_INPUT
        JSR getOperand
        ADD R2,R1,#0
        BRn REDO
        JSR getOperator
        ADD R4,R1,#0
        BRn REDO
        JSR getOperand
        ADD R3,R1,#0
        BRzp NEXT
        
REDO    LEA R0,ERROR
        PUTS
        BR GET_INPUT
        
NEXT    ADD R4,R4,#-1
        BRz ADDITION
        ADD R4,R4,#-1
        BRz SUBTRACTION
        ADD R4,R4,#-1
        BRz MULTIPLICATION
        
        JSR DIVIDE
        BR CONVERT
ADDITION
        JSR SUM
        BR CONVERT
SUBTRACTION
        JSR SUBTRACT
        BR CONVERT
MULTIPLICATION
        JSR MULT

CONVERT
        ADD R2,R1,#0
        JSR toString
DISPLAY_RESULT        
        LEA R0,RESULT_STR
        PUTS
        ADD R0,R1,#0
        PUTS

        
        
EXIT    HALT
;****************************************************************
Stack           .FILL xEFFF
Error           .STRINGZ "\nInvalid input! Please enter two numbers between 00 and 99 separated by an operator ('+', '-', '*', or '/'): "
INPUT_PROMPT    .STRINGZ "\nWelcome to the LC-3 Calculator! \nEnter two numbers between 00 and 99 separated by an operator ('+', '-', '*', or '/'): "
RESULT_STR      .STRINGZ "\nResult of calculation: "



;********************getDigit************************************
; Description: gets a single ASCII digit and returns it as a 
;              decimal
;
; Register Usage:
;   R0 - used for input
;   R1 - return value (-1 if invalid)
;   R2 - used for bounds check/conversion
;   R6 - stack pointer
;   R7 - reserved for RET
;****************************************************************
getDigit
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R0,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
    
            ;get and echo character
            GETC
            OUT
            
            ;check range
            LD R2,UPPER_RANGE
            ADD R2,R0,R2
            BRp OUT_OF_RANGE
            LD R2,AS_TO_DEC
            ADD R1,R0,R2
            BRzp DONE
            
OUT_OF_RANGE
            AND R1,R1,#0
            ADD R1,R1,#-1 ;return -1
            
            ;load registers
DONE        LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R0,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************
AS_TO_DEC   .FILL #-48
UPPER_RANGE .FILL #-57



;********************getOperator*********************************
; Description: gets a character ('+', '-', '*', or '/') and returns
;              a value between 1 and 4 (0 if invalid)
;
; Register Usage:
;   R0 - used for input
;   R1 - return value
;   R2 - used for bounds check/conversion
;   R6 - stack pointer
;   R7 - reserved for RET
;****************************************************************
getOperator
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R0,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
    
            AND R1,R1,#0
            ;get and echo character
            GETC
            OUT
            
            ;check range
            LD R2,PLUS
            ADD R2,R0,R2
            BRz LOAD_1
            LD R2,MINUS
            ADD R2,R0,R2
            BRz LOAD_2
            LD R2,TIMES
            ADD R2,R0,R2
            BRz LOAD_3
            LD R2,DIVISION
            ADD R2,R0,R2
            BRnp OUT_OF_RANGE2

            ;return value
LOAD_4      ADD R1,R1,#4
            BR DONE2
LOAD_1      ADD R1,R1,#1
            BR DONE2
LOAD_2      ADD R1,R1,#2
            BR DONE2
LOAD_3      ADD R1,R1,#3
            BR DONE2
            
            
OUT_OF_RANGE2
            ADD R1,R1,#-1 ;return -1
            
            ;load registers
DONE2       LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R0,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************
PLUS        .FILL #-43
MINUS       .FILL #-45
TIMES       .FILL #-42
DIVISION    .FILL #-47



;*********************getOperand*********************************
; Description: gets a number between 00 and 99 and returns
;              the decimal value in R1
;
; Register Usage:
;   R1 - return value
;   R2 - used for bounds check/conversion
;   R4 - loop counter
;   R7 - reserved for RET
;****************************************************************
getOperand
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            
            AND R2,R2,#0 ;clear R2
            
            AND R4,R4,#0
            ADD R4,R4,#10 ;set loop counter

            ;get tens value
            JSR getDigit
            ADD R1,R1,#0
            BRn OUT_OF_RANGE3
TENS        ADD R2,R1,R2    ;multiply by 10    
            ADD R4,R4,#-1
            BRp TENS
            
            JSR getDigit ;get ones value
            ADD R1,R1,#0
            BRn OUT_OF_RANGE3
            ADD R1,R2,R1 ;get final angle value
            BRnzp DONE3
            
OUT_OF_RANGE3
            AND R1,R1,#0
            ADD R1,R1,#-1 ;return -1            
            
            ;load registers
DONE3       LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1

            RET
;****************************************************************



;*********************decToFloat*********************************
; Description: takes a decimal value and converts it to fixed-
;              point (Q8.8) number format
;
; Register Usage:
;   R1 - return value
;   R2 - input value/used for calculation
;   R4 - loop counter
;   R7 - reserved for RET
;****************************************************************
decToFloat
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            
            LD R4,DEC_TO_FLOAT
LOOP        ADD R2,R2,R2
            ADD R4,R4,#-1
            BRp LOOP
            ADD R1,R2,#0
            
            ;load registers
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************
DEC_TO_FLOAT .FILL #8



;*********************floatToDec*********************************
; Description: takes a Q8.8 fixed point value and converts it
;              to standard decimal
;
; Register Usage:
;   R1 - returns starting address of string/used to store decimal portion
;   R2 - input value/used for calculation
;   R3 - used for calculation/memory location in string storage
;   R4 - integer portion
;   R7 - reserved for RET
;****************************************************************
floatToDec
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R0,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            ADD R6,R6,#-1
            STR R5,R6,#0
            
            ;get integer portion (divide by 256 to shift R2 >> 8)
            LD R3,DIV_256
            JSR divideFloat ;now R1 holds integer portion
            ADD R4,R1,#0    ;move to R4
            
            ;get decimal portion
            LD R3,FRACTION_MASK
            AND R2,R2,R3    ;now R2 holds fractional portion in Q8.8
            LD R3,HUNDRED
            ;JSR multiplyFloat ;now R1 holds (fractional Q8.8) * 100
            ADD R2,R1,#0
            LD R3,DIV_256
            JSR divideFloat   ;now R1 holds decimal number representing fractional portion (0-99)
            
            ;store integer digit in string
NEXT_STEP3  ADD R2,R4,#0
            JSR divide10 ;R2 holds quotient, R3 holds remainder
            ADD R6,R6,#-1
            STR R3,R6,#0
            ADD R4,R4,#1
            ADD R0,R2,#-10
            BRzp NEXT_STEP3
            
            LD R1,DEC_TO_ASCII
            ADD R2,R2,#0
            BRz STR_LOOP
            ADD R2,R1,R2 ;convert to ASCII
            STR R2,R5,#0 ;store first digit in string
            ADD R5,R5,#1
            
STR_LOOP3   
            LDR R2,R6,#0
            ADD R6,R6,#1
            ADD R2,R1,R2 ;convert to ASCII
            STR R2,R5,#0 ;store next digit in string
            ADD R5,R5,#1
            ADD R4,R4,#-1
            BRp STR_LOOP3
            LEA R3,OUTPUT_STRING
            LD R2,DEC_TO_AS
            ADD R4,R2,R4
            STR R4,R3,#0 ;store integer digit
            ADD R3,R3,#1
            
            ;store '.' character
            LD R2,DOT
            STR R2,R3,#0
            ADD R3,R3,#1
            
            ;store tenths place digit
            AND R2,R2,#0
            ADD R2,R2,#-10 ;divisor
            AND R4,R4,#0   ;loop counter
TENTHS      ADD R4,R4,#1
            ADD R1,R1,R2
            BRzp TENTHS
            ADD R1,R1,#10  ;undo extra subtraction - R1 now contains hundredths digit
            ADD R4,R4,#-1  ;R4 now contains tenths digit
            STR R4,R3,#0
            ADD R3,R3,#1
            
            ;store hundredths place digit and null terminator
            STR R1,R3,#0
            AND R2,R2,#0
            STR R2,R3,#1
            
            ;return starting address of output string
            LEA R1,OUTPUT_STRING
            
            ;load registers
            LDR R5,R6,#0
            ADD R6,R6,#1
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R0,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************
DIV_256         .FILL #256
FRACTION_MASK   .FILL x00FF
HUNDRED         .FILL #100  ;gives precision to hundredths place
OUTPUT_STRING   .BLKW #6    ;holds output string
DEC_TO_AS       .FILL #48
DOT             .FILL #46   ;ASCII code for dot



;*********************MULT***************************************
; Description: multiplies two integers
;
; Register Usage:
;   R1 - return value
;   R2 - 1st value
;   R3 - 2nd value
;   R7 - reserved for RET
;****************************************************************
MULT
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            
            AND R1,R1,#0
            ;multiply

MULT_LOOP
            ADD R1,R1,R2
            ADD R3,R3,#-1
            BRp MULT_LOOP
            
            ;load registers
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



;*********************SUM****************************************
; Description: adds two integers
;
; Register Usage:
;   R1 - return value
;   R2 - 1st value
;   R3 - 2nd value
;   R4 - used for loop counter
;   R7 - reserved for RET
;****************************************************************
SUM
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            
            ADD R1,R2,R3 ;add and return result
            
            ;load registers
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



;*********************SUBTRACT***********************************
; Description: finds difference of two integers
;
; Register Usage:
;   R1 - return value
;   R2 - 1st value
;   R3 - 2nd value
;   R7 - reserved for RET
;****************************************************************
SUBTRACT
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            
            NOT R3,R3
            ADD R3,R3,#1
            ADD R1,R2,R3  ;subtract and return result
            
            ;load registers
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



;*********************toString***********************************
; Description: converts an integer value to a string of ASCII
;
; Register Usage:
;   R1 - return value (pointer to string)
;   R2 - input value
;   R3 - holds remainder from division
;   R4 - loop counter
;   R5 - holds addresses for string memory locations
;   R7 - reserved for RET
;****************************************************************
toString
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            
            LEA R5,RESULT_STRING
            AND R4,R4,#0 ;loop counter

            ;check for negative
            ADD R2,R2,#0
            BRzp NEXT_STEP
            LD R3,DASH
            STR R3,R5,#0  ;store dash in string
            ADD R5,R5,#1
            NOT R2,R2
            ADD R2,R2,#1  ;flip R2 to positive
            
NEXT_STEP   JSR divide10 ;R2 holds quotient, R3 holds remainder
            ADD R6,R6,#-1
            STR R3,R6,#0
            ADD R4,R4,#1
            ADD R1,R2,#-10
            BRzp NEXT_STEP
            
            LD R1,DEC_TO_ASCII
            ADD R2,R2,#0
            BRz STR_LOOP
            ADD R2,R1,R2 ;convert to ASCII
            STR R2,R5,#0 ;store first digit in string
            ADD R5,R5,#1
            
STR_LOOP    
            LDR R2,R6,#0
            ADD R6,R6,#1
            ADD R2,R1,R2 ;convert to ASCII
            STR R2,R5,#0 ;store next digit in string
            ADD R5,R5,#1
            ADD R4,R4,#-1
            BRp STR_LOOP
            
            ;store null terminator
            AND R2,R2,#0
            STR R2,R5,#0
            
            LEA R1,RESULT_STRING ;return pointer to string
            
            ;load registers
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1

            RET
;****************************************************************
RESULT_STRING      .BLKW #5
DASH               .FILL #45
DEC_TO_ASCII       .FILL #48



;*********************divide10***********************************
; Description: divides an integer by 10 and returns the quotient
;              and remainder
;
; Register Usage:
;   R2 - input/return quotient
;   R3 - return remainder
;   R4 - used for calculation
;   R7 - reserved for RET
;****************************************************************
divide10
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            
            ADD R3,R2,#0 ;move input to R3
            AND R4,R4,#0
            ADD R4,R4,#-10
            AND R2,R2,#0 ;loop counter
DIV_10      ADD R2,R2,#1
            ADD R3,R3,R4
            BRz FINISH   ;divided with no remainder
            BRp DIV_10   ;subtract again
            ADD R2,R2,#-1 ;now contains quotient
            ADD R3,R3,#10 ;now contains remainder
            
            ;load registers
FINISH      LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



;*********************divideFloat********************************
; Description: returns the quotient of two Q8.8 values
;
; Register Usage:
;   R1 - return value
;   R2 - numerator (Q8.8)
;   R3 - denominator (Q8.8)
;   R4 - used for subtraction in loop
;   R7 - reserved for RET
;****************************************************************
divideFloat
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R3,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            
            JSR decToFloat ;multiplies numerator*256 - now numerator is in R1
            NOT R4,R3
            ADD R4,R4,#1   ;make denominator negative
            AND R2,R2,#0   ;use R2 as counter
DIV256      ADD R2,R2,#1
            ADD R1,R1,R4
            BRzp DIV256
            ADD R1,R2,#-1  ;remove extra increment and store in R1
            
            ;load registers
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R3,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



;*********************DIVIDE*************************************
; Description: divides two integers and returns a string with
;              the answer as a decimal
;
; Register Usage:
;   R1 - return value
;   R2 - input value (numerator)
;   R3 - input value (denominator)
;   R4 - loop counter
;   R7 - reserved for RET
;****************************************************************
DIVIDE
            ;save registers
            ADD R6,R6,#-1
            STR R7,R6,#0
            ADD R6,R6,#-1
            STR R2,R6,#0
            ADD R6,R6,#-1
            STR R4,R6,#0
            ADD R6,R6,#-1
            STR R5,R6,#0
            
            NOT R4,R3
            ADD R4,R4,#1 ;flip R3 and store in R4
            ADD R0,R4,#0 ;store copy
            AND R5,R5,#0 ;loop counter
DIV_LOOP    ADD R5,R5,#1
            ADD R2,R2,R4
            BRz STORE_INTEGER
            BRp DIV_LOOP
            
            ADD R1,R5,#-1 ;return quotient in R1
            
            
            
            ;ADD R3,R2,#0  ;R3 holds remainder
            
STORE_INTEGER
            ;AND R4,R4,#0
            ;ADD R2,R5,#0
NEXT_STEP2  ;JSR divide10 ;R2 holds quotient, R3 holds remainder
            ;ADD R6,R6,#-1
            ;STR R3,R6,#0
            ;ADD R4,R4,#1
            ;ADD R1,R2,#-10
            ;BRzp NEXT_STEP2
            
            
            ;LEA R5,DIVIDE_STR
            ;ADD R2,R2,#0
            ;BRz STR_LOOP2
            ;LD R1,DEC_TO_ASCII
            ;ADD R2,R1,R2 ;convert to ASCII
            ;STR R2,R5,#0 ;store first digit in string
            ;ADD R5,R5,#1
            
STR_LOOP2   ;LD R1,DEC_TO_ASCII
            ;LDR R2,R6,#0
            ;ADD R6,R6,#1
            ;ADD R2,R1,R2 ;convert to ASCII
            ;STR R2,R5,#0 ;store next digit in string
            ;ADD R5,R5,#1
            ;ADD R4,R4,#-1
            ;BRp STR_LOOP2
            
            ;ADD R2,R3,#0
            ;JSR decToFloat
            ;ADD R3,R1,#0 ;R3 holds remainder as Q8.8 (R0 holds flipped denominator)
            ;ADD R2,R5,#0
            ;JSR decToFloat ;R1 holds quotient as Q8.8
            ;ADD R2,R1,R3
            ;JSR floatToDec
            
            
            
            
            ;AND R3,R3,#0 ;loop counter
DIV_LOOP2   ;ADD R3,R3,#1
            ;ADD R2,R2,R0
            ;BRzp DIV_LOOP2
            
            ;ADD R2,R3,#-1   ;R2 now holds fractional portion in Q8.8
            ;JSR floatToDec  ;R1 holds pointer to fractional portion string
            ;ADD R3,R1,#0
            ;ADD R2,R5,#0
            ;JSR decToFloat
            ;ADD R2,R1,#0
            ;JSR 
            
            
            ;LEA R1,DIVIDE_STR ;return pointer to string
            
            ;load registers
            LDR R5,R6,#0
            ADD R6,R6,#1
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************
PI_APPROX   .FILL #804 ;pi converted to Q8.8
NUM#180     .FILL #180
NUM#256     .FILL #256
DIVIDE_STR  .BLKW #6



.END