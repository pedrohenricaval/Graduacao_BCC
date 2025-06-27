jmp main


;Verificar necessidade dos saveData
; Arrumar as coordenadas
; juntar em 1 funcao

; Constantes
debug : string "HELPPPppppppppppppppppppp"

starterMenuWelcome : string "Bem-vindo(a)"
starterMenuInstruction : string "Pressione Espaco para jogar"

xSymbol : string " X "
oSymbol : string " O "
xTurn : string "X Joga"
oTurn : string "O Joga"

map: string 
"                                      
               +         +             
               +         +             
               +         +             
          1    +    2    +    3        
               +         +             
               +         +             
      +++++++++++++++++++++++++++++    
               +         +             
               +         +             
               +         +             
          4    +    5    +    6        
               +         +             
               +         +             
               +         +             
      +++++++++++++++++++++++++++++    
               +         +             
               +         +             
          7    +    8    +    9        
               +         +             
               +         +             
               +         + 
"

SPACE : var #1 
static SPACE + #0, #32 
 
LAST_PIXEL : var #1 
static LAST_PIXEL + #0, #1199 

POSITION_ARRAY: var #9
static POSITION_ARRAY+ #0, #328
static POSITION_ARRAY+ #1, #339
static POSITION_ARRAY+ #2, #350
static POSITION_ARRAY+ #3, #608
static POSITION_ARRAY+ #4, #619
static POSITION_ARRAY+ #5, #630
static POSITION_ARRAY+ #6, #888
static POSITION_ARRAY+ #7, #899
static POSITION_ARRAY+ #8, #910

; Variaveis globais
counter : var #1 
static counter + #0, #0 

valueArray : var #9
static valueArray + #0, #0
static valueArray + #1, #0
static valueArray + #2, #0
static valueArray + #3, #0
static valueArray + #4, #0
static valueArray + #5, #0
static valueArray + #6, #0
static valueArray + #7, #0
static valueArray + #8, #0

; Funcoes
; Funcoes de texto
printScreen:
	; r1 - string, r2 - endereco da tela, r3 - char
	saveData:
		push r0			
		push r1			
		push r2			
		push r3
		push r4
		
	printScreenLoop:
		loadn r0, #'\0'		
		loadi r3, r1
		cmp r3, r0 ; char sendo impresso
		jeq loadData
		outchar r3, r2
		
		loadn r4, #1 ;incremento
		add r2, r2, r4
		add r1, r1, r4
		jmp printScreenLoop
		
	loadData:
		pop r0			
		pop r1			
		pop r2		
		pop r3	
		pop r4
		rts

eraseScreen: 
	saveData:
		push r0
		push r1
		push r2			
		push r3	
		
		loadn r0, #0
		load r1, LAST_PIXEL
		load r2, SPACE
		loadn r3, #1 ;incremento
		
	eraseScreenLoop:
		outchar r2, r0
		add r0, r0, r3
		
		cmp r1, r0
		jne eraseScreenLoop
		
	loadData:
		pop r0			
		pop r1			
		pop r2			
		pop r3
		rts	
		
; Funcoes de logica do jogo
InitiateGame:
	call eraseScreen
	
	loadn r1, #map
	loadn r2, #120
	call printScreen
	
	jmp initiateTurn

initiateTurn:	
	vez_X:
	loadn r0, #50
	loadn r1, #X_SYMBOL	
	loadn r2, #256			
	
	call printScreen
	
	rts

; coloca o x no tabuleiro
jogada_X:
	
	loadn r2, #9
	loadn r4, #counter
	loadi r5, r4
	cmp r5, r2
	jeq jogada_X
	
	; somando a quantidade de jogadas (max 9)
	loadn r0, #1
	loadi r2, r4
	add r2, r2, r0
	storei r4, r2
	
	call vez_X
		
	leitura_X:
		loadn r6, #255						; condicao de loop (aguardando a entrada do usuario)
		loadn r3, #49 						; o ASCII 1 do 1 é #49 (precisamos subtrair esse valor da entrada para pegar a posicao correta do vetor de coordenadas)
				
		inchar r7							; leitura do teclado
		cmp r7, r6							; se o usuario digitou alguma coisa saimos do loop
		jeq leitura_X
	
	loadn r4, #POSITION_ARRAY	; carrega o vetor de coordenadas (BASE)
	
	sub r1, r7, r3						; r1 é o OFFSET do vetor de coordenadas				
	mov r6, r1							; precisamos salvar o OFFSET para depois avaliar se podemos escrever nessa posicao
	add r4, r4, r1						; indo para a posicao correta do vetor (BASE + OFFSET)
	
	; imprime string precisa de: POSICAO DA TELA, STRING, COR
	loadi  r2, r4						; carregando da memoria ( MEM [BASE + OFFSET] ) -> POSICAO DA TELA
	loadn r1, #X_SYMBOL						; carregando da memoria a string "X" -> STRING
		
	; VERIFICANDO SE A POSICAO E VALIDA (AINDA NAO TEM "O" NEM "X")
	loadn r3, #valueArray 	; vetor para verificacao se a posicao digitada pelo usuario ja possui alguma coisa
	add r3, r3, r6					; indo para a posicao correta do vetor (BASE + OFFSET)
	mov r6, r3						; precisamos salvar o OFFSET para depois atualizar essa posicao com o "X" (codigo 1)
	loadi  r3, r3
						
	loadn r5, #0
	cmp r3, r5						; se o vetor nessa posicao esta guardando zero, ou seja, nao tem nem "O" nem "X", jump para a "posicao_valida_o"
	
	jeq posicao_valida_x 
						
	jmp leitura_X					; caso contrario voltamos para ler uma nova posicao
	
posicao_valida_x:					
	call printScreen 
	
	; salvando no conteudo da posicao digitada pelo usuario o codigo do "X" (codigo 1, ou seja, estamos salvando em memoria que aquela posicao ja esta ocupada por "X")
	loadn r7, #1
	storei r6, r7
	
	 halt
		
	oTurn: 
		load r0, counter
		
		; Verifica empate
		loadn r1, #9
		cmp r0, r1
		jeq eraseScreen
		
		; Incrementa counter
		loadn r1, #1
		add r0, r0, r1
		store counter, r0
		
		; Declara vez de O
		loadn r1, #oTurn
		loadn r2, #1161
		call printScreen
		
		; Leitura da entrada
		readLoop:
			; Devido a inchar nao ser bloqueante, o loop se torna necessario 
			loadn r1, #255	; inchar retorna #255 se nao ler nada
			inchar r0
			
			cmp r1, r0
			jeq readLoop
			
		; Verificacao de entrada	
		loadn r1, #57 ; 9 (ASCII)
		cmp r1, r0 ; Input > 9
		jle readLoop 
		
		loadn r1, #49 ; 1 (ASCII)
		cmp r1, r0 ; Input < 1
		jle readLoop
		
		; Verifica se a posicao esta desocupada
		loadn r1, #49 ; Conversao para int (48) + Correcao de indice de vetor (1)
		loadn r2, #valueArray
		
		sub r0, r0, r1 ; Offset
		add r2, r2, r0 ; Index especificado pelo usuário
		loadi r3, r2 ; Obtencao do valor no index
		
		loadn r4, #0	
		cmp r3, r4 ; Verifica se a posicao esta desocupada
		jne readLoop
		
		; Armazena O no array
		loadn r3, #oSymbol
		storei r2, r3
		
		; Atualiza mapa
		loadn r3, #POSITION_ARRAY
		add r3, r3, r0 ; Index da posicao do numero
		loadi r4, r3 ; Obtencao do valor no index
		
		loadn r1, #oSymbol
		mov r2, r4
		call printScreen
		
		jmp xTurn		

; Main
main:
	; Mensagens de aprensentacao
	loadn r1, #starterMenuWelcome
	loadn r2, #41
	call printScreen
	
	loadn r1, #starterMenuInstruction
	loadn r2, #201
	call printScreen
	
	; Leitura de entrada
	load r2, SPACE 	
	inchar r1 		
	cmp r1, r2
	jeq InitiateGame
	jmp main