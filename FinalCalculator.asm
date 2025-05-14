;****************************************************************
; Name: Joseph Moran
; Date: 4/28/2025
; Description: Basic calculator that performs addition, subtraction,
;              multiplication, and integer division on two-digit
;              values (00 - 99). 
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
        
;starting strings        
;****************************************************************        
WELCOME         .STRINGZ "\nWelcome to the LC-3 Calculator!"
INPUT_PROMPT    .STRINGZ "\nEnter two numbers between 00 and 99 separated by an operator ('+', '-', '*', or '/') or press \"enter\" to exit: "
;****************************************************************
        
        ;initialize stack pointer
        LD R6,STACK
        
        ;welcome message
        LEA R0,WELCOME
        PUTS
START
        LEA R0,INPUT_PROMPT
        PUTS
GET_INPUT
        JSR getOperand
        ADD R0,R1,#2
        BRz EXIT
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
        ADD R1,R1,#0
        BRzp CONVERT
        BRn DIVIDE_0
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
        BR START
        
DIVIDE_0
        LEA R0,DIV_0_ERROR
        PUTS
        BR START
        
EXIT    LEA R0, EXIT_STR
        PUTS
        HALT
;****************************************************************
STACK           .FILL xEFFF
ERROR           .STRINGZ "\nInvalid input! Please enter two numbers between 00 and 99 separated by an operator ('+', '-', '*', or '/') or press \"enter\" to exit: "
RESULT_STR      .STRINGZ "\nResult of calculation: "
DIV_0_ERROR     .STRINGZ "\nCannot divide by 0!"
EXIT_STR        .STRINGZ "\nExiting calculator... "



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
            
            ;check for newline character
            ADD R2,R0,#-10
            BRz ENTER
            
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
            BR DONE
            
ENTER       AND R1,R1,#0
            ADD R1,R1,#-2 ;return -2
            
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
            ADD R2,R1,#2
            BRz ENTER_EXIT
            AND R2,R2,#0 ;clear R2
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
            
ENTER_EXIT  AND R1,R1,#0
            ADD R1,R1,#-2 ;return -2
            
            ;load registers
DONE3       LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1

            RET
;****************************************************************



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
            ;check if either value is zero
            ADD R2,R2,#0 
            BRz ZERO
            ADD R3,R3,#0
            BRz ZERO
            
            ;multiply
MULT_LOOP
            ADD R1,R1,R2
            ADD R3,R3,#-1
            BRp MULT_LOOP
            
ZERO        ;load registers
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
            
            ADD R3,R3,#0 ;check for divide by 0 error
            BRp CONTINUE
            AND R1,R1,#0
            ADD R1,R1,#-1
            ;LEA R1,DIV_0_ERROR
            BR RETURN
            
CONTINUE    NOT R4,R3
            ADD R4,R4,#1 ;flip R3 and store in R4
            AND R5,R5,#0 ;loop counter
DIV_LOOP    ADD R5,R5,#1
            ADD R2,R2,R4
            BRzp DIV_LOOP
            
            ADD R1,R5,#-1 ;return quotient in R1
            
            ;load registers
RETURN      LDR R5,R6,#0
            ADD R6,R6,#1
            LDR R4,R6,#0
            ADD R6,R6,#1
            LDR R2,R6,#0
            ADD R6,R6,#1
            LDR R7,R6,#0
            ADD R6,R6,#1
            
            RET
;****************************************************************



.END