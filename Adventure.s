.data
backward: .asciiz "s"
down: .asciiz "f"
forward: .asciiz "w"
invalid: .asciiz "Wat?\n"
left: .asciiz "a"
nline: .asciiz "\n"
prompt: .asciiz "->> "
right: .asciiz "d"
up: .asciiz "r"
quit: .asciiz "q"

.text

prompt:
    la $a0, prompt # Gather String
    li $v0, 4
    syscall
    la $a0, $sp # STACK TIME SON
    li $v0, # num for read string
    la $s0, $sp
    jal analyze
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
    beq $t1, $t0,lft

    la $t1, right
    lbu $t1, $t1
    beq $t1, $t0, rght

    la $t1, up
    lbu $t1, $t1
    beq $t1, $t0, u

    beq $zero, $t0
    b invalid

invalid:
    la $a0, invalid
    li v0, 4
    syscall