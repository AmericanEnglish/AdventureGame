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
must: .space 1 # Mustard Byte
nline: .asciiz "\n"
prompt: .asciiz "->> "
right: .asciiz "d"
sam: .space 1 # Sammich byte
setup_1: .asciiz "Hello! Welcome to AssemblyAdventure!\nType h for [h]elp. The interpreter process four character commands at a time.\nAnymore than that will be ignored or worse, crunked up.\nFind the diamond and goodluck!"
total: .word 0 # Total Moves
up: .asciiz "r"
quit: .asciiz "q"
x: .word 0
y: .word 0
z: .word 0
# Creature:  3
# Diamond:  11
# Empty:     1
# Mustard:   7
# Sammich:   5

.text

init:
    # Print Setup Text
    la $a0, setup_1
    li $v0, 4
    syscall

    # Setup Game Array
    # Populate "Empty" Array
    la $s0, array
    li $t1, 0   # Starting index
    li $a0, 511 # Array max
    li $a1, 1   # init value
    jal array_init
    
    # Generate Pieces
    # 1% Of all squares are enemies
    la $s0, array
    li $a3, 3   # Object Number
    li $a1, 512 # Array Max
    li $t0, 0   # Current Creatures
    li $t1, 51  # Max Creature Count
    jal creature_gen
    # Place Sammiches
    li $s1, 0  # Sammich Layers Handled
    li $a1, 64 # Grid size in the layer
    li $a2, 8  # Layers
    li $a3, 6  # Sammiches to Be Placed
    li $s2, 5  # Object Number
    jal sammich_controller
    # Place Diamond
    li $v0, 42
    li $a1, 512
    syscall
    li $a1, 4 
    mult $a0, $a1
    mflo $a0
    li $a2, 11
    sw $a2, $a0($s0)

    # Log Start time
    li $v0, 30
    syscall
    addi $s4, $a1, $zero  # Move the lower 32 bits of time
    j prompt

array_init: # Generates an array of 1's
    sw $a1, $s0
    addi $t0, $t0, 1
    addi $s0, $s0, 4
    bgt $t0, $a0, return
    b array_init

creature_gen:
    # Generate Index Number
    li $v0, 42
    syscall

    # For byte adjustment
    li $v0, 4
    mult $v0, $a0
    mflo $a0
    
    # Store The Creature
    sw $a3, $a0($s0)
    addi $t0, $t0, 1
    
    beq $t0, $t1, return
    b creature_gen

sammich_controller: # Adjusts Layer
    # Generate per layer
    li $t0, 0 # Completed Sammiches
    # Needed for more JAL
    addi $sp, $sp, -4
    sw $ra, ($sp)
    # 6 Sammiches per layer, this will even out sammich distribution a little more
    jal sammich_gen
    addi $s1, $s1, 1
    lw $ra, ($sp)
    addi $sp, $sp 4
    
    beq $s1, $a2, return
    b sammich_controller

sammich_gen:
    li $v0, 42
    syscall
    # 64 * Layer + Location
    mult $a1,  $s1
    mflo $t9
    addi $a0, $a0, $t9
    li $v0, 4
    mult $a0, $v0 # Convert Index -> Bytes
    mflo $a0 # Index After Padding
    lw $t9, $a0($s0) # Extract Number
    mult $t9, $s2 # Add A Sammich
    mflo $t9 # Some composite number that indicates Sammich added
    sw $t9, $a0($s0)
    addi $t0, $t0, 1
    beq $a3, $t0, return
    b sammich_gen



# Game Starts
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
    li $v0, 4
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
    # Move Creature
dwn:
fwd:
lft:
rght:
rise:
eet:
    # Check Sammich Byte
    # Check Mustard Byte
    # Decrement Sammich Byte
    # Increment Hp
    # Move creature
win:
death:

## Math out the index
#div $a0,  $t2 # x
#mfhi $t4 # Store x
#mflo $a0
#div $a0, $t2 # y
#mfhi $t5 # Store y
#mflo $a0
#div $a0, $t2 # z
#mfhi $t6 # Store z