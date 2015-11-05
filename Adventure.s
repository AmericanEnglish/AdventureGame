.data
up: .asciiz "u\n"
down: .asciiz "d\n"
forward: .asciiz "w\n" 
backward: .asciiz "d\n"
left: .asciiz "a\n"
right: .asciiz "s\n"
prompt: .asciiz "->> "
nline: .asciizz "\n"

.text

prompt:
la $a0, prompt
li $v0, 4
syscall
jal analyze
b prompt

analyze: