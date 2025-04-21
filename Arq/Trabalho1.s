# Foram feitas as seguintes suposicoes:
# 1. Ao fazer "Undo" ate o resultado inicial, o valor armazenado continua sendo 0, em vez de encerrar o programa
# 2. As instruções são escritas em uma unica string, em vez de separadamente
# 3. Undo deve antes voltar ate o primeiro int fornecido e so depois ser completamente resetado
# 4. Os valores inseridos serão de 0-9. Seria possível aceitar outros valores de inteiro, mas eles teriam de ser lidos como int, em vez de char
# Isso faria com que fosse necessario apertar "enter" entre entradas. Como nao sei a preferencia da banca, deixei dessa forma

	.data		# inicia o segmento de dados
	.align 0	# determina o alinhamento dos bytes (2^0)

#Strings
strInic:
	.asciz "Digite a primeira operacao: "
strOpe:
    .asciz "\nDigite a proxima operacao: "
strRes:
	.asciz "\nResultado: "
strEnd:
    .asciz "\nFim."
strError:
    .asciz "\nERROR!!!"

# Buffer
strBuffer:
    .space 4

	.text		# inicia o segmento de texto
	.align 2	# determina alinhamento de 2^2, ou seja, 4 bytes
	.globl main	# determina que o identificador main eh global

main:
    # Salvos usados: s1(inicial/resultado), s2(char), s3(int), s4(head), s5(S), s6(M), s7(D), s8(V), s9(U), s10(F), s11(qtd de operacoes)
    # Inicializar chars de entrada
    li s5, '+'
    li s6, '-'
    li s7, '/'
    li s8, '*'
    li s9, 'u'
    li s10, 'f'

    # Inicializar  lista
    add s11, zero, zero

    # Imprimir string de entrada
    li a7, 4
    la a0, strInic
    ecall

    # Loop de execução
    executionLoop:
        # s1 (int), s2 (char), s3(int)
        jal functReadInput

        # Branches de Soma, Sub, Divisao, Multi, Undo e End
        beq s2, s5, functAdd
        beq s2, s6, functSub
        beq s2, s7, functDivi
        beq s2, s8, functMulti
        j functError

functReadInput:
    # Branch p/ primeiro input
    beq s11, zero, firstInput

    # Imprimir strOpe
    li a7, 4
    la a0, strOpe
    ecall

    # Eh possivel ler apenas 1 vez e com menos repeticao de codigo, mas "undo" e "fim" teria de se apertar "Enter". Nao sabia qual metodo era preferido
    # Ler char
    la a0, strBuffer
    li a7, 8
    li a1, 2
    ecall

    # Salvar char
    la a0, strBuffer
    lb s2, 0(a0)

    # Verificar "Fim" e "Undo"
    beq s2, s9, functUndo
    beq s2, s10, functEnd
    
    # Ler int (como char)
    la a0, strBuffer
    li a7, 8
    li a1, 2
    ecall

    # Salvar int
    la a0, strBuffer
    lb s3, 0(a0)
    addi s3, s3, -48    # Correcao do ASCII

    # Verificacao de dado
    blt s3, zero, functError
    addi t0, zero, 9
    blt t0, s3, functError

    ret

    firstInput:
        # Ler int (como char)
        la a0, strBuffer
        li a7, 8
        li a1, 2
        ecall

        # Salvar int
        la a0, strBuffer
        lb s1, 0(a0)
        addi s1, s1, -48    # Correcao do ASCII

        # Ler char
        la a0, strBuffer
        li a7, 8
        li a1, 2
        ecall

        # Salvar char
        la a0, strBuffer
        lb s2, 0(a0)

        # Verificar "Fim" e "Undo"
        beq s2, s9, functUndo
        beq s2, s10, functEnd
        
        # Ler int (como char)
        la a0, strBuffer
        li a7, 8
        li a1, 2
        ecall

        # Salvar int
        la a0, strBuffer
        lb s3, 0(a0)
        addi s3, s3, -48    # Correcao do ASCII

        # Verificacao de dado
        blt s3, zero, functError
        addi t0, zero, 9
        blt t0, s3, functError

        # Encadear primeiro inteiro 
        addi sp, sp, -4   
        sw ra, 0(sp)      # Preservar "ra" atual
        jal functSaveResult
        lw ra, 0(sp)      # Restaurar "ra"
        addi sp, sp, 4    
        ret

functAdd:
    add s1, s1, s3
    jal functSaveResult
    jal functPrintResult
    j executionLoop

functSub:
    sub s1, s1, s3
    jal functSaveResult
    jal functPrintResult
    j executionLoop

functDivi:
    div s1, s1, s3
    jal functSaveResult
    jal functPrintResult
    j executionLoop

functMulti:
    mul s1, s1, s3
    jal functSaveResult
    jal functPrintResult
    j executionLoop

functUndo:
    # Buffers usados: t1(no), t2(no->prox), t3(no->prox->prox)
    
    # Procurar ultimo no
    add t1, s4, zero
    searchLastNode:
        lw t2, 4(t1)
        beq t2, zero, lastNodeIsFirstNode
        lw t3, 4(t2)
        beq t3, zero, foundLastNode
        add t1, t2, zero
        j searchLastNode

    # Remover item 
    foundLastNode:
        sw zero, 0(t2) # Remove valor do ultimo no
        sw zero, 4(t1) # Remove o endereco do ultimo no
        lw s1, 0(t1)   # Atribui o valor anterior
        j functUndoEnd

    lastNodeIsFirstNode:
        sw zero, 0(t1)      # Remove o valor do ultimo no
        add s1, zero, zero  # Remove o valor do resultado salvo

    # Fim da funcao
    functUndoEnd:
        jal functPrintResult
        j executionLoop

functSaveResult:
    # Buffers usados: t0 (endereco recebido), t1(no), t2(no->prox)
    # Alocar memoria
    li a0, 8      # valor(4) + endereco(4)
    li a7, 9
    ecall

    # Receber endereco
    add t0, a0, zero

    # Preencher struct
    sw s1, 0(t0)
    sw zero, 4(t0)

    # Primeira insercao
    beq s11, zero, firstInsertion

    # Inserir item
    add t1, s4, zero
    searchInsertionLoop:
        lw t2, 4(t1)
        beq t2, zero, foundInsertion
        add t1, t2, zero
        j searchInsertionLoop
    j functEnd
    foundInsertion:
        sw t0, 4(t1)
        addi s11, s11, 1
        ret

    firstInsertion:
        add s4, t0, zero
        addi s11, s11, 1
        ret

functEnd:
    jal functPrintResult
    addi a7, zero, 10
    ecall

functPrintResult:
    # Imprimir string resultado
    li a7, 4
    la a0, strRes
    ecall

    #Imprimir resultado
    addi a7, zero, 1
    add a0, zero, s1 
    ecall
    ret

functError:
    # Imprimir strError
    li a7, 4
    la a0, strError
    ecall
    j executionLoop