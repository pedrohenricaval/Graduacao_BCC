jmp main

; Constantes
starterMenuWelcome : string "Bem-vindo(a)"
starterMenuInstruction : string "Pressione Enter para jogar"
starterMenuName : string "Criado por Pedro Henrique Cavalcante "
map: string 
"
   +   +
   +   +
   +   +
++++++++++
   +   +
   +   +
++++++++++
   +   +
   +   +
   +   +
"

space : var #1 ;
static space, #32 ; 

lastPixel : var #1 ;
static lastPixel, #1199 ;

; Funcoes
; Funcoes de texto
printScreen:
	saveData:
		push r0			
		push r1			
		push r2			
		push r3			
		push r4
		push r5
		
	printScreenLoop:
		;r1 - string, r2 - endereco da tela, r3 - cor
		loadn r0, #'\0'		
		loadi r4, r1
		cmp r4, r0
		jeq loadData
		add r4, r3, r4
		outchar r4, r2
		
		loadn r5, #1 ;incremento
		add r2 ,r2, r5
		add r1,r1, r5
		jmp printScreenLoop
		
	loadData:
		pop r0			
		pop r1			
		pop r2			
		pop r3			
		pop r4	
		pop r5
		rts

eraseScreen: 
	saveData:
		push r0
		push r1
		push r2			
		push r3	
		
		loadn r0, #0
		load r1, lastPixel
		load r2, space
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

; Main e jogo
main:
	;r1 - string, r2 - endereco da tela, r3 - cor
	loadn r1, #starterMenuWelcome
	loadn r2, #41
	loadn r3, #0
	call printScreen
	
	loadn r1, #starterMenuInstruction
	loadn r2, #201
	loadn r3, #0
	call printScreen
	
	loadn r1, #starterMenuName
	loadn r2, #1161
	loadn r3, #0
	call printScreen
	
	loadn r2, #32 	
	inchar r1 		
	cmp r1, r2
	jeq jogo
	jmp main
	
jogo:
	call eraseScreen
	
	loadn r1, #map
	loadn r2, #562
	loadn r3, #0
	call printMap