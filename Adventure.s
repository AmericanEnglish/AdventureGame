.data
up: .asciiz "u"
down: .asciiz "d"
forward: .asciiz "w" 
backward: .asciiz "d"
left: .asciiz "a"
right: .asciiz "s"
prompt: .asciiz "->> "
nline: .asciizz "\n"

.text

prompt:
    la $a0, prompt # Gather String
    li $v0, 4
    syscall
    la $a1, $sp # STACK TIME SON
    li $v0, # num for read string
    jal analyze
    b prompt

analyze:


return:
    j $ra