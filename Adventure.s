.data
array: .space 2048 # 8 * 8 * 8 3-Dimensional Array (* 4 Bytes)
backward: .asciiz "s"
buffer: .space 6 # 4 input chars, a \n and the null terminator
dimx: .word 8
dimy: .word 8
dimz: .word 8
down: .asciiz "f"
eat: .asciiz "e"
forward: .asciiz "w"
invalid: .asciiz "Wat?\n"
left: .asciiz "a"
nline: .asciiz "\n"
prompt: .asciiz "->> "
right: .asciiz "d"
setup_1: .asciiz "Hello! Welcome to AssemblyAdventure!\nType h for [h]elp. The interpreter process four character commands at a time.\nAnymore than that will be ignored or worse, crunked up.\nFind the diamond and goodluck!"
total: .word 0 # Total Moves
up: .asciiz "r"
quit: .asciiz "q"
x: .word 0
y: .word 0
z: .word 0

.text

init:
    # Print Setup Text
    la $a0, setup_1
    li $v0, 4
    syscall

    # Setup Game Array

prompt:
    la $a0, prompt # Gather String
    li $v0, 4
    syscall
    la $a0, buffer
    li $a1, 5
    li $v0, 8 # num for read string
    add $s0, $a0, $zero # Move address
    jal analyze
    li $a1, 0
    
    # Reset buffer space
    la $s0, buffer
    sw $zero, $s0
    sb $zero, $s0(4)
    sb $zero, $s0(5) 
    b prompt

exit:
    li $v0, 10
    syscall

return:
    j $ra

# Runs the show
analyze:
    lbu $t0, $s0 # Starts reading the string
    
    la $t1, quit
    lbu $t1, $t1
    beq $t0, $t1, exit
    
    la $t1, backward
    lbu $t1, $t1
    beq $t1, $t0, back
    
    la $t1, down
    lbu $t1, $t1
    beq $t1, $t0, dwn
    
    la $t1, forward
    lbu $t1, $t1
    beq $t1, $t0, fwd
    
    la $t1, left
    lbu $t1, $t1
    beq $t1, $t0, lft

    la $t1, right
    lbu $t1, $t1
    beq $t1, $t0, rght

    la $t1, up
    lbu $t1, $t1
    beq $t1, $t0, rise

    la $t1, eat
    lbu $t1, $t1
    beq $t1, $t0, eet

    la $t1, nline
    lbu $t1, $t1
    beq $t1, $t0, return
    beq $zero, $t0, return

    b invalid

invalid:
    la $a0, invalid
    li v0, 4
    syscall
    j return

exit:
    li $v0, 10
    syscall

# Proces Movements
back:
    # Check Array Dimensions
    # Branch
    # Or Move
    # Decrement HP
    # Store $ra
    # JAL to Win Check
    # JAL to death check
    # Jump prompt
dwn:
fwd:
lft:
rght:
rise:
eet:
    # Check Sammich Byte
    # Decrement Sammich Byte
    # Increment Hp

win:
death: