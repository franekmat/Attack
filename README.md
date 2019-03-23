This is a task for Operating Systems course.

## Input

Binary file containing sequence of 32-bit numbers, which have reversed byte order.

## Output

**0** - if following conditions are fulfilled at the same time:

- the file doesn't cointain number 68020
- the file contains a number greater than 68020 and less than 2^31
- in the file there are five consecutive numbers with values: 6, 8, 0, 2, 0
- the sum od all numbers in the file modulo 2^32 is equal to 68020

**1** - otherwise and also if an error has occured (such as wrong number of arguments, incorrect argument, file doesn't exist, error in read operation etc.)
