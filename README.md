# CalculatorFinalCS155
## Project Description: 
This program is a simple calculator that can add, subtract, multiply, and divide up to two-digit integers. My original plan was to implement a trigonometric function calculator that could take an angle in degrees and find the sine, cosine, or tangent of the angle. This proved too difficult to complete in the time I had, so I reverted to a basic arithmetic calculator. I attempted to implement floating-point division, but I was unable to finish, so the division feature performs simple integer division. To perform an arithmetic operation, enter 2 two-digit values separated by an operator ('+', '-', '*', or '/'). The program reads the two values and calls the appropriate subroutine based on the operator. Since the result can be up to 4 digits long, it also calls a subroutine to convert the result to a string for display. 
\
## Operations: 
### Addition:
Takes the two 2-digit values and adds them directly.
#### Example:
##### Input: 23+02
##### Output: 25
\
### Subtraction:
Flips the second 2-digit value to a negative, then adds this value to the first 2-digit value. Can handle negative results.
#### Example:
##### Input: 57-68
##### Output: -11
\
### Multiplication:
Iterates through a loop in which it adds the first value repeatedly to a running total. The loop uses the second value as a counter.
#### Example:
##### Input: 23*20
##### Output: 460
#### Example:
##### Input: 23*00
##### Output: 0
\
### Division: 
Flips the second value to a negative, then iterates through a loop in which it adds this negative value to the first value repeatedly until the result is negative. It also maintains a loop counter that is incremented with every iteration. After the loop finishes, it subtracts 1 from the loop counter to account for the extra iteration of the loop. Finally, it returns the loop counter as the quotient. 
#### Example:
##### Input: 45/04
##### Output: 11
#### Example:
##### Input: 02/08
##### Output: 0
#### Example:
##### Input: 43/00
##### Output: Cannot divide by 0!  
\
\
## Link to LC-3 Simulator Download (version 2.0.2): 
[LC3Tools](https://github.com/chiragsakhuja/lc3tools/releases)
