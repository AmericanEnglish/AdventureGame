.data
array: .space 2048 # 8 * 8 * 8 3-Dimensional Array (* 4 Bytes)
buffer: .space 6 # 4 input chars, a \n and the null terminator
dimx: .word 7
dimy: .word 7
dimz: .word 7
health: .word 10
must: .word 0 # Mustard Byte
sam: .word 0 # Sammich byte
total: .word 0 # Total Moves
x: .word 0
y: .word 0
z: .word 0
.space 50
answer_y: .asciiz "y"
backward: .asciiz "s"
ded: .asciiz "You are dead. 100% so. \n"
down: .asciiz "f"
eat: .asciiz "e"
empty_sammich: .asciiz "Alas, your hands, do not qualify as a sammich. \n First find a sammich if youre hungry. \n Theyre everywhere. \n "
forward: .asciiz "w"
inval: .asciiz "Wat? \n "
leave: .asciiz "Goodbye. \n "
left: .asciiz "a"
move1: .asciiz "FOWARD   ! \n "
move2: .asciiz "BACKWARD ! \n "
move3: .asciiz "LEFTWARD ! \n "
move4: .asciiz "RIGHTWARD! \n "
move5: .asciiz "UPWARD   ! \n "
move6: .asciiz "DOWNWARD ! \n "
mustard_success: .asciiz "Youve acquired mustard! \n Enjoy the . . . tasty? . . . flavor on your sammichs \n for triple the sammich goodness."
mustard_failed: .asciiz "Youve discovered mustard! \n Although you still have some left. Waste less, and leave it till \n you finish this one."
nline: .asciiz " \n"
prompt: .asciiz "->> "
right: .asciiz "d"
consume: .asciiz "Youve eaten the sammich and feel much less hungry. HP +2. \n "
consume_must: .asciiz "Slathering the mustard on you animal. HP +4. \n "
sammich_success: .asciiz "Youve acquired a sammich! \n Restores 2 HP upon consumption \n "
sammich_failed: .asciiz "Youve discovered a sammich! \n You are holding four already! \n No more 4 you! \n "
setup_1: .asciiz "Hello! Welcome to AssemblyAdventure! \n Type h for [h]elp. The interpreter process four character commands at a time. \n Anymore than that will be ignored or worse, crunked up.\nFind the diamond and goodluck!\n"
up: .asciiz "r"
use: .asciiz "Use mustard? (y/n): "
quit: .asciiz "q"
vic: .asciiz "Thats a . . . diamond?! You win! I guess . . . whooooo . . .\n"
totalm: .asciiz "Total Moves: "
break: .asciiz "b"
break_success: .asciiz "Youve slept a little. HP +1.\n"
break_failure: .asciiz "You've slept on a porcupine! IDIOT! HP -3.\n"
help: .asciiz "h"
help_stuff: .asciiz " h-> help \n w->FORWARD \n a->LEFT \n s->RIGHT \n d->RIGHT\n r->UP \n f->DOWN \n e->EAT \n b->NAPBREAK\n i->INVENTORY \n These commands are case senstive\n"
u_have: .asciiz "You have: "
siches: .asciiz " sammiches \n"
mstered: .asciiz " mustard uses left \n"
i: .asciiz "i"
# Creature:  3
# Diamond:  11
# Empty:     1
# Mustard:   7
# Sammich:   5


.MACRO store_counter
    addi $sp, $sp, -4
    sw $ra, ($sp)  
.END_MACRO


.MACRO recover_counter
    lw $ra, ($sp)
    addi $sp, $sp, 4
.END_MACRO

.MACRO print (%str)
    la $a0, %str
    li $v0, 4
    syscall
.END_MACRO

.MACRO reset_buffer
    # Reset buffer space
    la $s7, buffer
    sw $zero, ($s7)
    sb $zero, 4($s7)
.END_MACRO

.MACRO check_for (%obj) # Moves remainder into $t0
    la $t9, z # Prep Z
    lw $t0, ($t9) 
    li $t3, 64
    mult $t0, $t3
    mflo $t0
    la $t9, y # Prep Y
    lw $t1, ($t9)
    li $t3, 8
    mult $t1, $t3
    mflo $t0
    la $t9, x # No Prep for X
    lw $t2, ($t9) 
    add $t0, $t0, $t1 # Combine Indexes
    add $t0, $t0, $t2
    li $t3, 4 # Byte Padding
    mult $t0, $t3
    mflo $t3
    la $s0, array # Read Array
    add $s0, $s0, $t3
    lw $t8, ($s0) # Load in index data
    li $v0, %obj # Object Number
    div $t8, $v0 # If %obj is a factor remainder is 0
    mfhi $t0
.END_MACRO

# Only callable after a check_for
.MACRO remove (%obj) # Removes and object from memory
    lw $t9,  ($s0)
    div $t9, %obj
    mflo $t9
    sw $t9, ($s0)
.END_MACRO

.MACRO check_all
    store_counter
    jal win
    recover_counter
    
    store_counter
    jal sammich_check
    recover_counter

    store_counter
    jal mustard_check
    recover_counter
    
    # Decrement HP
    store_counter
    jal decrement
    recover_counter

    la $s5, total
    lw $t6, ($s5)
    addi $t6, $t6, 1
    sw $t6, ($s5)
.END_MACRO

.text 
init:
    # Print Setup Text
    print (setup_1)

    # Setup Game Array
    # Populate "Empty" Array
    la $s0, array
    li $t1, 0   # Starting index
    li $a0, 511 # Array max
    li $a1, 1   # init value
    jal array_init
    
    # Generate Pieces
    # 1% Of all squares are enemies
    li $a3, 3   # Object Number
    li $a1, 512 # Array Max
    li $t0, 0   # Current Creatures
    li $t1, 51  # Max Creature Count
    jal creature_gen
    # Place Sammiches
    li $t1, 50 # Grid size in the layer
    li $a2, 7  # Layers
    li $s2, 5  # Object Number
    jal sammich_controller
    # Place Mustards
    la $s0, array
    li $a1, 512 # Array Max
    li $a2, 7   # Object Number
    li $t0, 2   # Mustards To Place
    jal mustard_place
    # Place Diamond
    li $v0, 42
    li $a1, 512
    syscall
    li $a1, 4 
    mult $a0, $a1
    mflo $a0
    li $a2, 11
    add $s0, $s0, $a0
    sw $a2, ($s0)
    # Log Start time
    li $v0, 30
    syscall
    add $s4, $a1, $zero  # Move the lower 32 bits of time
    j prompt_loop

return:
    jr $ra

array_init: # Generates an array of 1s
    sw $a1, ($s0)
    addi $t0, $t0, 1
    addi $s0, $s0, 4
    bgt $t0, $a0, return
    b array_init

creature_gen:
    la $s0, array
    # Generate Index Number
    li $v0, 42
    syscall

    # For byte adjustment
    li $v0, 4
    mult $v0, $a0
    mflo $a0
    
    # Store The Creature
    add $s0, $s0, $a0
    sw $a3, ($s0)
    addi $t0, $t0, 1
    
    beq $t0, $t1, return
    b creature_gen

sammich_controller: # Adjusts Layer
    li $t4, 4
    blez $t1, return
    li $v0, 42
    li $a1, 512
    syscall
    la $s0, array
    mult $t4, $a0
    mflo $t4
    add $s0, $s0, $t4
    sw $s2, ($s0)
    addi $t1, $t1, -1
    b sammich_controller


mustard_place:
    li $v0, 42
    syscall
    li $t2, 4 # Byte Padding
    mult $a0, $t2
    mflo $t2
    add $t2, $t2, $s0 # Extract Value
    lw $a0, ($t2)
    mult $a0, $a2 # Some composite
    mflo $a0
    sw $a0, ($s0)
    addi $t0, $t0, -1
    blez $t0, return
    b mustard_place

# Game Starts
prompt_loop:
    print (prompt)
    la $a0, buffer
    li $a1, 5
    li $v0, 8 # num for read string
    syscall
    add $s7, $a0, $zero # Move address
    jal analyze
    li $a1, 0
    reset_buffer
    print (nline)
    b prompt_loop

# Runs the show
analyze:
    li $s2, 511 # For the creature counter
    lbu $t0, ($s7) # Starts reading the string
    
    la $t1, quit
    lbu $t1, ($t1)
    beq $t0, $t1, exit
    
    la $t1, backward
    lbu $t1, ($t1)
    beq $t1, $t0, back
    
    la $t1, down
    lbu $t1, ($t1)
    beq $t1, $t0, dwn
    
    la $t1, forward
    lbu $t1, ($t1)
    beq $t1, $t0, fwd
    
    la $t1, left
    lbu $t1, ($t1)
    beq $t1, $t0, lft

    la $t1, right
    lbu $t1, ($t1)
    beq $t1, $t0, rght

    la $t1, up
    lbu $t1, ($t1)
    beq $t1, $t0, rise

    la $t1, eat
    lbu $t1, ($t1)
    beq $t1, $t0, eet

    la $t1, break
    lbu $t1, ($t1)
    beq $t1, $t0, nap_time

    la $t1, help
    lbu $t1, ($t1)
    beq $t1, $t0, halp

    la $t1, i
    lbu $t1, ($t1)
    beq $t1, $t0, inven

    la $t1, nline
    lbu $t1, ($t1)
    beq $t1, $t0, return
    beq $zero, $t0, invalid

    jr $ra

invalid:
    la $a0, inval
    li $v0, 4
    syscall
    jr $ra

exit:
    # Log Death time
    li $v0, 30
    syscall
    add $s3, $a1, $zero  # Move the lower 32 bits of time
    sub $a0, $s4, $s3
    li $v0, 1
    syscall
    print (nline)
    print (leave)
    print (totalm)
    li $v0, 1
    lw $a0, total
    syscall
    print (nline)
    # Exit
    li $v0, 10
    syscall

upper_check:
    bgt $t1, $t0, adjust_upper_bounds
    jr $ra

adjust_upper_bounds:
    li $a0, 0
    sw $a0, ($a1)
    jr $ra

adjust_lower_bounds:
    li $a0, 7
    sw $a0, ($a1)
    jr $ra

# Proces Movements
back:
    # Check Array Dimensions
    lw $t1, y
    la $a1, y
    # Move
    addi $t1, $t1, -1
    sw $t1, ($a1)
    print (move2)

    # Boundary Check
    store_counter
    bltzal $t1, adjust_lower_bounds
    recover_counter
    
    # Easy Check
    check_all

    # Move Creatures
    j move_creatures

dwn:
    # Check Array Dimensions
    lw $t1, z
    la $a1, z
    # Move
    addi $t1, $t1, -1
    sw $t1, ($a1)
    print (move6)
    
    # Boundary Check
    store_counter
    bltzal $t1, adjust_lower_bounds
    recover_counter
    
    # Easy Check
    check_all

    # Move Creatures
    j move_creatures

lft:
    # Check Array Dimensions
    lw $t1, x
    la $a1, x
    # Move
    addi $t1, $t1, -1
    sw $t1, ($a1)
    print (move3)
    # Boundary Check
    store_counter
    bltzal $t1, adjust_lower_bounds
    recover_counter
    
    # Easy Check
    check_all

    # Move Creatures
    j move_creatures

fwd:
    # Check Array Dimensions
    lw $t0, dimy
    lw $t1, y
    la $a1, y
    # Move
    addi $t1, $t1, 1
    sw $t1, ($a1)
    print (move1)
    # Boundary Check
    store_counter
    jal upper_check
    recover_counter

    
    # Easy Check
    check_all

    # Move Creatures
    j move_creatures

rght:
    # Check Array Dimensions
    lw $t0, dimx
    lw $t1, x
    la $a1, x
    # Move
    addi $t1, $t1, 1
    sw $t1, ($a1)
    print (move4)
    # Boundary Check
    store_counter
    jal upper_check
    recover_counter
    
    # Easy Check
    check_all

    # Move Creatures
    j move_creatures

rise:
    # Check Array Dimensions
    lw $t0, dimz
    lw $t1, z
    la $a1, z
    # Move
    addi $t1, $t1, 1
    sw $t1, ($a1)
    print (move5)
    # Boundary Check
    store_counter
    jal upper_check
    recover_counter
    
    # Easy Check
    check_all
    
    # Move Creatures
    j move_creatures

eet:
    # Check Sammich Byte
    lw $t0, sam
    blez $t0, eet_failed
    
    # Check Mustard Byte
    lw $t1, must
    store_counter
    jal eet_question
    recover_counter

    # Decrement Sammich Byte
    addi $t0, $t0, -1
    la $t7, sam
    sw $t0, ($t7)
    # Increment Hp
    lw $t0, health
    la $t1, health
    addi $t0, $t0, 2
    sw $t0, ($t1)

    print (consume)
    # Move creature
    j move_creatures

eet_question:
    bgtz $t1, eet_must_q
    jr $ra

eet_failed:
    print (empty_sammich)
    jr $ra

eet_must_q:
    print (use)
    reset_buffer
    la $a0, buffer
    li $a1, 2
    li $v0, 8 # num for read string
    syscall
    print (nline)
    la $t3, answer_y
    lbu $t3, ($t3)
    la $a3, buffer
    lbu $a3, ($a3)
    bne $t3, $a3, return
    recover_counter # No need to return to original eat

    # Store Adjusted values
    addi $t0, $t0, -1
    sw $t0, sam
    addi $t1, $t1, -1
    sw $t1, must
    
    # Adjust HP
    lw $t0, health
    la $t1, health
    addi $t0, $t0, 6
    sw $t0, ($t1)

    print (consume)
    print (consume_must)
    j move_creatures


win:
    check_for (11)
    beq $t0, $zero, victory
    jr $ra

sammich_check:
    check_for (5)
    beq $t0, $zero, sammich_found1
    jr $ra

sammich_found1: # Attempt to pickup
    lw $t0, sam
    li $t1, 3
    bgt $t0, $t1, sammich_found3
    b sammich_found2

sammich_found2: # Attempt Successful
    print (sammich_success)
    addi $t0, $t0, 1
    la $t3, sam
    sw $t0, ($t3)
    li $t2, 5
    remove ($t2) # Picked up the sammich
    jr $ra

sammich_found3: # Attempt Failed
    print (sammich_failed)
    jr $ra

mustard_check:
    check_for (7)
    beq $t0, $zero, mustard_found1
    jr $ra

mustard_found1: # Attempt to pickup
    lw $t0, must
    bgtz $t0, mustard_found3
    b mustard_found2

mustard_found2: # Attemp Successful
    print (mustard_success)
    addi $t0, $t0, 4
    la $t3, must
    sw $t0, ($t3)
    li $t2, 7
    remove ($t2)
    print (nline)
    jr $ra

mustard_found3: # Attemp Failed
    print (mustard_failed)
    print (nline)
    jr $ra

death:
    print (ded)
    la $t4, total
    lw $t3, total
    addi $t3, $t3, 1
    sw $t3, ($t4)
    j exit
    
victory:
    print (vic)
    j exit

decrement:
    la $a0, health
    lw $a1, ($a0)
    addi $a1, $a1, -1
    blez $a1, death
    sw $a1, ($a0)
    jr $ra

move_creatures:
    la $a3, array
    store_counter
    jal creature_loop
    recover_counter
    addi $s7, $s7, 1
    b analyze

creature_loop:
    lw $t1, ($a3)
    li $t2, 3
    div $t1, $t2
    mfhi $t5
    store_counter
    jal creature_check
    recover_counter
    addi $a3, $a3, 4
    addi $s2, $s2, -1
    blez $s2, return
    b creature_loop

creature_check:
    blez $t5, creature_check_success
    jr $ra

creature_check_success:
    mflo $t5
    sw $t5, ($a3)
    li $a1, 512
    li $v0, 42
    syscall
    # Just Teleport them, WAAAY FUNNIER
    li $t5, 4 # Byte Padding
    mult $a0, $t5
    mflo $a0
    la $t3, array
    add $t5, $t5, $t3 # New index
    lw $t3, ($t5)
    div $t3, $t2
    mfhi $t3
    blez $t3, creature_new_success
    mult $t3, $t2
    mflo $t2
    sw $t2, ($t5)
    jr $ra

creature_new_success:
    mflo $t3
    mult $t3, $t2
    mflo $t2
    sw $t2, ($t5)
    jr $ra

nap_time:
    check_for(3)
    blez $t0, nap_time_failure # You were pricked!
    print (break_success)
    lw $t0, health
    la $t1, health
    addi $t0, $t0, 1
    sw $t0, ($t1)
    j move_creatures

nap_time_failure:
    li $t1, 3
    remove ($t1)
    la $t1, health
    lw $t0, health
    addi $t0, $t0, -2
    sw $t0, ($t1)
    print (break_failure)
    check_all
    j move_creatures

halp:
    print (help_stuff)
    j move_creatures

inven:
    la $a0, u_have
    li $v0, 4
    syscall
    li $v0, 1
    lw $a0, sam
    syscall
    la $a0, siches
    li $v0, 4
    syscall
    la $a0, u_have
    li $v0, 4
    syscall
    li $v0, 1
    lw $a0, must
    syscall
    la $a0, mstered
    li $v0, 4
    syscall
    j move_creatures

## Math out the index
#div $a0,  $t2 # x
#mfhi $t4 # Store x
#mflo $a0
#div $a0, $t2 # y
#mfhi $t5 # Store y
#mflo $a0
#div $a0, $t2 # z
#mfhi $t6 # Store z