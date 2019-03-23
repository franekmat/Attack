section .data
  ;defining syscall numbers
  SYS_EXIT    equ 60
  SYS_READ    equ 0
  SYS_OPEN    equ 2
  SYS_CLOSE   equ 3
  EXIT_CODE   equ 1
  ARG_NUM     equ 2
  O_RDONLY    equ 0
  BUF_SIZE    equ 4
  BUF2_SIZE   equ 1024

section .bss
  buffer      resd BUF_SIZE
  fd          resd 1
  buffer2     resd BUF2_SIZE

section .text
  global _start

_start:
  ;checking if number of arguments is correct
  pop   rbx
  cmp   rbx, ARG_NUM
  jne   _exit_error

  ;saving numbers 6, 8, 0, 2, 0 for neat verification of third condition
  mov   [buffer2], dword 6
  mov   [buffer2 + 4], dword 8
  mov   [buffer2 + 8], dword 0
  mov   [buffer2 + 12], dword 2
  mov   [buffer2 + 16], dword 0

  ;opening file, which has been passed as an argument
  pop   rax   ;we dont want first argument: "./attack"
  pop   rdi   ;thats the name of file
  mov   rax, SYS_OPEN
  xor   rsi, rsi
  mov   rdx, 0
  syscall

  ;check if any error occurred during opening file
  cmp   rax, 0
  jl    _exit_error

  ;store file descriptor
  mov   [fd], eax

;r12d - current state for third condition, 1 means that we have 1 number
;       from sequence, 2 means that we have already 2 numbers etc.
;r13d - sum of all numbers from input modulo 2^32
;r14d - current number
;r15d - 1 if exist number greather than 68020 and less than 2^31
;       0 otherwise

_read_input:

  ;read from file into buffer
  mov   rdi, [fd] ;file descriptor
  xor   rax, rax
  mov   rsi, buffer
  mov   rdx, BUF_SIZE
  syscall

  ;check if i have read correct number of bytes
  cmp   rax, 4
  je    _check

  cmp   rax, 0
  je    _exit
  jne   _exit_error

;checking current number
_check:
  mov   r14d, dword [esi]
  bswap r14d
  add   r13d, r14d

  ;first and second condition from the task
  cmp   r14d, 68020
  je    _exit_error
  jg    _1st_condition

  ;do we look for first number from sequence 6,8,0,2,0?
  cmp   r12d, 0
  je    _1st_state

  ;do we look for 2nd, 3rd, 4th or 5th number from sequence 6,8,0,2,0?
  cmp   r12d, 5
  jl    _next_state

  ;read next number
  jmp   _read_input

;checking second and third condition from the task
_1st_condition:
  cmp   r14d, dword 2147483647
  jle   _2nd_condition

  cmp   r12d, 0
  je    _1st_state

  cmp   r12d, 5
  jl    _next_state

  jmp   _read_input

_2nd_condition:
  mov   r15d, 1 ;second condition fulfilled

  cmp   r12d, 0
  je    _1st_state

  cmp   r12d, 5
  jl    _next_state

  jmp   _read_input

;we have found another number from the sequence
_cond_ok:
  inc   r12d ;go to the next state
  jmp   _read_input

_1st_state:
  cmp   r14d, dword [buffer2 + r12d * 4] ;thats some number from the sequence
  je    _cond_ok

  xor   r12d, r12d ;we dont have any number from the sequence yet
  jmp   _read_input

_next_state:
  cmp   r14d, dword [buffer2 + r12d * 4]
  je    _cond_ok

  xor   r12d, r12d ;sequence broken
  jmp   _1st_state

_exit:
  cmp   r13d, 68020 ;sum of all integers modulo 2^32 = 68020?
  jne   _exit_error

  cmp   r12d, 5 ;have we had the sequence?
  jnge  _exit_error

  cmp   r15d, 1 ;second condition fulfilled?
  jnge  _exit_error

  jmp   _exit_success


_exit_success:
  mov   rax, SYS_EXIT
  mov   rdi, 0
  syscall

_exit_error:
  mov   rax, SYS_EXIT
  mov   rdi, 1
  syscall
