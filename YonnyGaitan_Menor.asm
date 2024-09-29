.data
    prompt_num:       .asciiz "¿Cuántos números deseas comparar (3-5)?: "
    prompt_input:     .asciiz "Ingresa un número: "
    result_msg:       .asciiz "El número menor es: "
    error_msg:        .asciiz "Error: Debes ingresar entre 3 y 5 números.\n"
    newline:          .asciiz "\n"

    numbers:          .align 2  # Alinear a 4 bytes (múltiplo de 4)

.text
.globl main

main:
    # Solicitar al usuario cuántos números desea comparar
    li $v0, 4                 # syscall para imprimir string
    la $a0, prompt_num         # cargar mensaje en $a0
    syscall
    
    li $v0, 5                 # syscall para leer número entero
    syscall
    move $t0, $v0             # $t0 tiene el número de entradas (debe ser 3-5)

    # Validar si el número ingresado está entre 3 y 5
    li $t1, 3                 # comparar con 3
    blt $t0, $t1, error       # si es menor a 3, error
    li $t1, 5                 # comparar con 5
    bgt $t0, $t1, error       # si es mayor a 5, error

    # Pedir al usuario que ingrese los números
    li $t2, 0                 # contador de números
    la $t3, numbers           # dirección base del array de números

input_loop:
    li $v0, 4                 # syscall para imprimir string
    la $a0, prompt_input       # cargar mensaje en $a0
    syscall

    li $v0, 5                 # syscall para leer número entero
    syscall
    sw $v0, 0($t3)            # guardar el número en el array
    addi $t3, $t3, 4          # avanzar al siguiente espacio en el array
    addi $t2, $t2, 1          # incrementar el contador

    bne $t2, $t0, input_loop  # repetir hasta que se ingresen todos los números

    # Encontrar el número menor
    la $t3, numbers           # restablecer la dirección base del array
    lw $t4, 0($t3)            # cargar el primer número en $t4 (menor actual)
    
    addi $t2, $t3, 4          # apuntar al siguiente número después del primero
    li $t5, 1                 # contador para comparación
    
find_min:
    lw $t6, 0($t2)            # cargar el siguiente número en $t6
    blt $t6, $t4, update_min  # si es menor, actualizar $t4 (menor actual)
    
next_num:
    addi $t2, $t2, 4          # mover al siguiente número
    addi $t5, $t5, 1          # incrementar contador de comparación
    blt $t5, $t0, find_min    # repetir hasta comparar todos los números
    j print_result

update_min:
    move $t4, $t6             # actualizar el menor número
    j next_num

print_result:
    # Mostrar el número menor
    li $v0, 4                 # syscall para imprimir string
    la $a0, result_msg         # cargar mensaje en $a0
    syscall

    li $v0, 1                 # syscall para imprimir entero
    move $a0, $t4             # cargar el menor número en $a0
    syscall

    # Salto de línea
    li $v0, 4                 # syscall para imprimir string
    la $a0, newline            # cargar salto de línea
    syscall

    # Terminar el programa
    li $v0, 10                # syscall para salir
    syscall

# Rutina de error
error:
    li $v0, 4                 # syscall para imprimir string
    la $a0, error_msg          # cargar mensaje de error en $a0
    syscall
    j main                    # reiniciar el programa
