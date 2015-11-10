.data
up: .asciiz "u\n"
down: .asciiz "d\n"
forward: .asciiz "w\n" 
backward: .asciiz "d\n"
left: .asciiz "a\n"
right: .asciiz "s\n"
prompt: .asciiz "->> "
quit: .asciiz "quit\n"
nline: .asciiz "\n"

.text

prompt:
    la $a0, prompt # Gather String
    li $v0, 4
    syscall
    la $a0, $sp # STACK TIME SON
    li $v0, # num for read string
    jal analyze
    b prompt

return:
    j $ra

# Runs the show
analyze:
