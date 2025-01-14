;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------
; Demostra��o da navega��o do cursor do Ecran 
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'



        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
        FichString      db      'players.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	7	; a linha pode ir de [1 .. 25]
		POSx			db	4	; POSx pode ir [1..80]	
		POSya			db	4	; posicao anterior de y
		POSxa			db	4	; posicao anterior de x

		POSyE			db	7	; posicao escrita de y
		POSxE			db	4	; posicao escrita de x
		SimbE			db	1	; simbolo escrito

		JogadorAtual    db 	1
		auxJogadorAtual db 	1 

		auxSalta		db	1
		auxSimbolo		db	1
		bool1Simbolo 	db 	0

		array 			db 	81 dup('T','A','C','2','3')
		arrayFinal		db	9  dup('T','A','C','2','3')

		boardWinner1	db	0
		boardWinner2	db	0
		boardWinner3	db	0
		boardWinner4	db	0
		boardWinner5	db	0
		boardWinner6	db	0
		boardWinner7	db	0
		boardWinner8	db	0
		boardWinner9	db	0
		FinalWinner		db	0

        countPlayer1    db  0
        countPlayer2    db  0

        color             db  75

        ;strings
        msgInicio db 0ah, "ULTIMATE-TIC-TAC-TOE$"
        msg1 db 0ah, "Jogador 1: $"
        msg2 db 0ah, "Jogador 2: $"
        msgFinal db 0ah, "Pressione qualquer tecla para continuar$"
        msgVencedor db 0ah, " Fim :D$"
        msgVencedor2 db 0ah, " Vencedor:$"
        msgEmpate db 0ah, " Empate!$"
        player1 db 100 dup ('$')
        player2 db 100 dup ('$')

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
		
endm


;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		

;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
			
CICLO:		
		goto_xy	POSx,POSy		; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh,0			; numero da p�gina
		int		10h		
		mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
		goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
		mov		ah, 02h			; IMPRIME caracter da posi��o no canto
		mov		dl, Car	
		int		21H		

		cmp		al, 177
		je		PAREDE

		cmp		al, 186
		je		SALTA_X

		cmp		al, 205
		je		SALTA_Y
		
		goto_xy	10, 4
		cmp	bool1Simbolo, 0
		jne	ALTERA_SIMBOLO ; Pula para a alteração de símbolo se bool1Simbolo for diferente de 0

	EXIBIR_JOGADOR_ATUAL:
		mov	dl, jogadorAtual
		jmp	MOSTRA_XO

	ALTERA_SIMBOLO:
		mov	ah, 02h
		mov	dl, jogadorAtual
		cmp	dl, 'X'
		je	ALTERA_PARA_O
		mov	dl, 'X'
		jmp	MOSTRA_XO

	ALTERA_PARA_O:
		mov	dl, 'O'

	MOSTRA_XO:
		int	21h ; Exibir caractere

	;MOSTRA O ARRAY PARA VER SE ESTÁ A GUARDAR BEM
    ;mov si, offset array
    ;mov cx, 81
	;goto_xy	1,19

    ;mostrar_array:
	
    ;    mov dl, [si]
    ;    inc si

        ; Exibir o caractere no Ecrã
    ;    mov ah, 02h
    ;    int 21h

    ;    dec cx
    ;    jnz mostrar_array

	;MOSTRA O ARRAY PARA VER SE ESTÁ A GUARDAR BEM

	;MOSTRA O ARRAY FINAL PARA VER SE ESTÁ A GUARDAR BEM
    ;mov si, offset arrayFinal
    ;mov cx, 9
	;goto_xy	1,22

    ;mostrar_arrayFinal:
	
    ;    mov dl, [si]
    ;    inc si

        ; Exibir o caractere no Ecrã
    ;    mov ah, 02h
    ;    int 21h

    ;    dec cx
    ;    jnz mostrar_arrayFinal

	;MOSTRA O ARRAY FINAL PARA VER SE ESTÁ A GUARDAR BEM

		goto_xy	POSx,POSy	; Vai para posi��o do cursor		

LER_SETA:
		
		; Guarda a posicao antes de mudar de posicao
		mov 	al, POSx
		mov 	POSxa, al
		mov 	al, POSy
		mov 	POSya, al
		
		goto_xy POSx, POSy

		call 	LE_TECLA
		cmp 	ah, 1
		je 		ESTEND
		cmp 	al, 1Bh    ; ESCAPE (27 em hexadecimal)
		je 		FIM
		cmp 	al, 0Dh    ; ESPAÇO (32 em hexadecimal)
		je 		PODE_ESCREVER
		cmp 	al, 58h    ; X
		je 		PODE_ESCREVER
		cmp 	al, 4Fh    ; O 
		je 		PODE_ESCREVER
		cmp 	al, 0    ; Verifica as setas
		je 		VERIFICAR_SETA
		jmp 	LER_SETA

PODE_ESCREVER:

    ;call DESATIVA

    goto_xy POSx, POSy  ; verifica se pode escrever o caractere no ecrã
    mov CL, Car
    cmp CL, 20h    ; Só escreve se for espaço em branco
    jne LER_SETA

	;guardar as posicoes de escrita
	mov al, POSx
	mov POSxE, al

	mov al, POSy   
	mov POSyE, al

    ; Verifica se a variável já foi exibida
    cmp bool1Simbolo, 0
    je PRIMEIRA_EXIBICAO

    ; Alternar entre 'X' e 'O'
    cmp JogadorAtual, 'X'
    je ESCREVER_O
    mov dl, 'X'
    jmp ESCREVER

ESCREVER_O:
    mov dl, 'O'

ESCREVER:
    mov ah, 02h    ; coloca o caractere lido no ecrã
    mov al, dl     ; caractere a ser exibido
    int 21H

    ; Atualizar flag de exibição
    mov bool1Simbolo, 1

    ; Alternar jogadorAtual
    cmp JogadorAtual, 'X'
    je ATUALIZAR_JOGADOR_O
    mov JogadorAtual, 'X'
    ;jmp CICLO
	jmp ATUALIZA_ARRAY

ATUALIZAR_JOGADOR_O:
    mov JogadorAtual, 'O'
	;jmp CICLO
	jmp ATUALIZA_ARRAY

PRIMEIRA_EXIBICAO:
    ; Exibe o caractere inicial no ecrã
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

    ; Atualizar flag de exibição
    mov bool1Simbolo, 1

    ;jmp CICLO
	jmp ATUALIZA_ARRAY

ATUALIZA_ARRAY:
    call COORDS	

VERIFICAR_SETA:
		cmp 	ah, 0    ; Verifica o segundo byte de ah para distinguir as setas
		je 		SETAS
		jmp 	LER_SETA

SETAS:
		cmp 	al, 4Bh    ; Setas: esquerda
		je 		PODE_ESCREVER
		cmp 	al, 4Dh    ; Setas: direita
		je 		PODE_ESCREVER
		cmp 	al, 48h    ; Setas: cima
		je 		PODE_ESCREVER
		cmp 	al, 50h    ; Setas: baixo
		je 		PODE_ESCREVER
		jmp 	LER_SETA
		
ESTEND:
		cmp 	al,48h
		jne		BAIXO
		dec		POSy		;cima
		mov 	auxSalta, al
		jmp		CICLO

BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 	POSy		;Baixo
		mov 	auxSalta, al
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		sub		POSx, 2		;Esquerda
		mov 	auxSalta, al
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		add 	POSx, 2 	;Direita Mudei isto para andar 2 casas em vez de 1. troquei o inc por add
		mov 	auxSalta, al
		jmp		CICLO


;LIMITA O MOVIMENTO AO TABULEIRO ULTIMATE
PAREDE:
		; retorna o filho atrás, já que ele está a ir contra a parede
		mov		al, POSxa	   
		mov		POSx, al
		mov		al, POSya	 
		mov 	POSy, al
		jmp 	CICLO

SALTA_X:
        cmp     auxSalta,4Bh ;Esquerda
        jne     ADD_X
        sub     POSx, 2
        jmp     CICLO

ADD_X: ;Direita
        cmp     auxSalta,4Dh 
        add     POSx, 2
        jmp     CICLO

SALTA_Y:
		cmp     auxSalta,50h ;Baixo
        jne     SUB_Y
        inc     POSy
        jmp     CICLO

SUB_Y: ;Cima
        dec     POSy
        jmp     CICLO	

;########################################################################
;COORDS

COORDS:
    cmp POSxE, 4
    jne check_next
    cmp POSyE, 7
    jne check_next

    mov al, jogadorAtual
    mov si, offset array
    add si, 0   ; Acesso ao elemento 0 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 0 do array
    jmp end_coord

check_next:
    ; Código para a combinação (1, 0) aqui
    cmp POSxE, 6
    jne check_next2
    cmp POSyE, 7
    jne check_next2

    mov al, jogadorAtual
    mov si, offset array
    add si, 1   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next2:
    ; Código para a combinação (0, 1) aqui
    cmp POSxE, 8
    jne check_next3
    cmp POSyE, 7
    jne check_next3

    mov al, jogadorAtual
    mov si, offset array
    add si, 2   ; Acesso ao elemento 2 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 2 do array
    jmp end_coord

check_next3:
	; Código para a combinação (3, 0) aqui
    cmp POSxE, 4
    jne check_next4
    cmp POSyE, 8
    jne check_next4

    mov al, jogadorAtual
    mov si, offset array
    add si, 3   ; Acesso ao elemento 2 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 2 do array
    jmp end_coord

check_next4:
	; Código para a combinação (4, 0) aqui
    cmp POSxE, 6
    jne check_next5
    cmp POSyE, 8
    jne check_next5

    mov al, jogadorAtual
    mov si, offset array
    add si, 4   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next5:
	; Código para a combinação (5, 0) aqui
    cmp POSxE, 8
    jne check_next6
    cmp POSyE, 8
    jne check_next6

    mov al, jogadorAtual
    mov si, offset array
    add si, 5   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next6:
	; Código para a combinação (6, 0) aqui
    cmp POSxE, 4
    jne check_next7
    cmp POSyE, 9
    jne check_next7

    mov al, jogadorAtual
    mov si, offset array
    add si, 6   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next7:
	; Código para a combinação (7, 0) aqui
    cmp POSxE, 6
    jne check_next8
    cmp POSyE, 9
    jne check_next8

    mov al, jogadorAtual
    mov si, offset array
    add si, 7   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next8:
	; Código para a combinação (8, 0) aqui
    cmp POSxE, 8
    jne check_next9
    cmp POSyE, 9
    jne check_next9

    mov al, jogadorAtual
    mov si, offset array
    add si, 8   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
;FIM TABULEIRO 1

check_next9:
	; Código para a combinação (0, 1) aqui
    cmp POSxE, 12
    jne check_next10
    cmp POSyE, 7
    jne check_next10

    mov al, jogadorAtual
    mov si, offset array
    add si, 9   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next10:
	; Código para a combinação (1, 1) aqui
    cmp POSxE, 14
    jne check_next11
    cmp POSyE, 7
    jne check_next11

    mov al, jogadorAtual
    mov si, offset array
    add si, 10   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next11:
	; Código para a combinação (2, 1) aqui
    cmp POSxE, 16
    jne check_next12
    cmp POSyE, 7
    jne check_next12

    mov al, jogadorAtual
    mov si, offset array
    add si, 11   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord


check_next12:
	; Código para a combinação (3, 1) aqui
    cmp POSxE, 12
    jne check_next13
    cmp POSyE, 8
    jne check_next13

    mov al, jogadorAtual
    mov si, offset array
    add si, 12   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next13:
	; Código para a combinação (4, 1) aqui
    cmp POSxE, 14
    jne check_next14
    cmp POSyE, 8
    jne check_next14

    mov al, jogadorAtual
    mov si, offset array
    add si, 13   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next14:
	; Código para a combinação (5, 1) aqui
    cmp POSxE, 16
    jne check_next15
    cmp POSyE, 8
    jne check_next15

    mov al, jogadorAtual
    mov si, offset array
    add si, 14   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next15:
	; Código para a combinação (7, 1) aqui
    cmp POSxE, 12
    jne check_next16
    cmp POSyE, 9
    jne check_next16

    mov al, jogadorAtual
    mov si, offset array
    add si, 15   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next16:
	; Código para a combinação (8, 1) aqui
    cmp POSxE, 14
    jne check_next17
    cmp POSyE, 9
    jne check_next17

    mov al, jogadorAtual
    mov si, offset array
    add si, 16   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next17:
	; Código para a combinação (8, 1) aqui
    cmp POSxE, 16
    jne check_next18
    cmp POSyE, 9
    jne check_next18

    mov al, jogadorAtual
    mov si, offset array
    add si, 17   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 2

check_next18:
	; Código para a combinação (0, 2) aqui
    cmp POSxE, 20
    jne check_next19
    cmp POSyE, 7
    jne check_next19

    mov al, jogadorAtual
    mov si, offset array
    add si, 18   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next19:
	; Código para a combinação (1, 2) aqui
    cmp POSxE, 22
    jne check_next20
    cmp POSyE, 7
    jne check_next20

    mov al, jogadorAtual
    mov si, offset array
    add si, 19   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next20:
	; Código para a combinação (2, 2) aqui
    cmp POSxE, 24
    jne check_next21
    cmp POSyE, 7
    jne check_next21

    mov al, jogadorAtual
    mov si, offset array
    add si, 20   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next21:
	; Código para a combinação (3, 2) aqui
    cmp POSxE, 20
    jne check_next22
    cmp POSyE, 8
    jne check_next22

    mov al, jogadorAtual
    mov si, offset array
    add si, 21   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next22:
	; Código para a combinação (4, 2) aqui
    cmp POSxE, 22
    jne check_next23
    cmp POSyE, 8
    jne check_next23

    mov al, jogadorAtual
    mov si, offset array
    add si, 22   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next23:
	; Código para a combinação (5, 2) aqui
    cmp POSxE, 24
    jne check_next24
    cmp POSyE, 8
    jne check_next24

    mov al, jogadorAtual
    mov si, offset array
    add si, 23   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next24:
	; Código para a combinação (6, 2) aqui
    cmp POSxE, 20
    jne check_next25
    cmp POSyE, 9
    jne check_next25

    mov al, jogadorAtual
    mov si, offset array
    add si, 24   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next25:
	; Código para a combinação (7, 2) aqui
    cmp POSxE, 22
    jne check_next26
    cmp POSyE, 9
    jne check_next26

    mov al, jogadorAtual
    mov si, offset array
    add si, 25   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next26:
	; Código para a combinação (8, 2) aqui
    cmp POSxE, 24
    jne check_next27
    cmp POSyE, 9
    jne check_next27

    mov al, jogadorAtual
    mov si, offset array
    add si, 26   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 3

check_next27:
	; Código para a combinação (0, 3) aqui
    cmp POSxE, 4
    jne check_next28
    cmp POSyE, 11
    jne check_next28

    mov al, jogadorAtual
    mov si, offset array
    add si, 27   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next28:
	; Código para a combinação (1, 3) aqui
    cmp POSxE, 6
    jne check_next29
    cmp POSyE, 11
    jne check_next29

    mov al, jogadorAtual
    mov si, offset array
    add si, 28   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next29:
	; Código para a combinação (2, 3) aqui
    cmp POSxE, 8
    jne check_next30
    cmp POSyE, 11
    jne check_next30

    mov al, jogadorAtual
    mov si, offset array
    add si, 29   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next30:
	; Código para a combinação (3, 3) aqui
    cmp POSxE, 4
    jne check_next31
    cmp POSyE, 12
    jne check_next31

    mov al, jogadorAtual
    mov si, offset array
    add si, 30   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next31:
	; Código para a combinação (4, 3) aqui
    cmp POSxE, 6
    jne check_next32
    cmp POSyE, 12
    jne check_next32

    mov al, jogadorAtual
    mov si, offset array
    add si, 31   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next32:
	; Código para a combinação (5, 3) aqui
    cmp POSxE, 8
    jne check_next33
    cmp POSyE, 12
    jne check_next33

    mov al, jogadorAtual
    mov si, offset array
    add si, 32   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next33:
	; Código para a combinação (6, 3) aqui
    cmp POSxE, 4
    jne check_next34
    cmp POSyE, 13
    jne check_next34

    mov al, jogadorAtual
    mov si, offset array
    add si, 33   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next34:
	; Código para a combinação (7, 3) aqui
    cmp POSxE, 6
    jne check_next35
    cmp POSyE, 13
    jne check_next35

    mov al, jogadorAtual
    mov si, offset array
    add si, 34   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next35:
	; Código para a combinação (8, 3) aqui
    cmp POSxE, 8
    jne check_next36
    cmp POSyE, 13
    jne check_next36

    mov al, jogadorAtual
    mov si, offset array
    add si, 35   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 4

check_next36:
	; Código para a combinação (0, 4) aqui
    cmp POSxE, 12
    jne check_next37
    cmp POSyE, 11
    jne check_next37

    mov al, jogadorAtual
    mov si, offset array
    add si, 36   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next37:
	; Código para a combinação (1, 4) aqui
    cmp POSxE, 14
    jne check_next38
    cmp POSyE, 11
    jne check_next38

    mov al, jogadorAtual
    mov si, offset array
    add si, 37   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next38:
	; Código para a combinação (2, 4) aqui
    cmp POSxE, 16
    jne check_next39
    cmp POSyE, 11
    jne check_next39

    mov al, jogadorAtual
    mov si, offset array
    add si, 38   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next39:
	; Código para a combinação (3, 4) aqui
    cmp POSxE, 12
    jne check_next40
    cmp POSyE, 12
    jne check_next40

    mov al, jogadorAtual
    mov si, offset array
    add si, 39   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord


check_next40:
	; Código para a combinação (4, 4) aqui
    cmp POSxE, 14
    jne check_next41
    cmp POSyE, 12
    jne check_next41

    mov al, jogadorAtual
    mov si, offset array
    add si, 40   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next41:
	; Código para a combinação (5, 4) aqui
    cmp POSxE, 16
    jne check_next42
    cmp POSyE, 12
    jne check_next42

    mov al, jogadorAtual
    mov si, offset array
    add si, 41   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next42:
	; Código para a combinação (6, 4) aqui
    cmp POSxE, 12
    jne check_next43
    cmp POSyE, 13
    jne check_next43

    mov al, jogadorAtual
    mov si, offset array
    add si, 42   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next43:
	; Código para a combinação (7, 4) aqui
    cmp POSxE, 14
    jne check_next44
    cmp POSyE, 13
    jne check_next44

    mov al, jogadorAtual
    mov si, offset array
    add si, 43   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next44:
	; Código para a combinação (8, 4) aqui
    cmp POSxE, 16
    jne check_next45
    cmp POSyE, 13
    jne check_next45

    mov al, jogadorAtual
    mov si, offset array
    add si, 44   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 5

check_next45:
	; Código para a combinação (0, 5) aqui
    cmp POSxE, 20
    jne check_next46
    cmp POSyE, 11
    jne check_next46

    mov al, jogadorAtual
    mov si, offset array
    add si, 45   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next46:
	; Código para a combinação (1, 5) aqui
    cmp POSxE, 22
    jne check_next47
    cmp POSyE, 11
    jne check_next47

    mov al, jogadorAtual
    mov si, offset array
    add si, 46   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next47:
	; Código para a combinação (2, 5) aqui
    cmp POSxE, 24
    jne check_next48
    cmp POSyE, 11
    jne check_next48

    mov al, jogadorAtual
    mov si, offset array
    add si, 47   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next48:
	; Código para a combinação (3, 5) aqui
    cmp POSxE, 20
    jne check_next49
    cmp POSyE, 12
    jne check_next49

    mov al, jogadorAtual
    mov si, offset array
    add si, 48   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
check_next49:
	; Código para a combinação (4, 5) aqui
    cmp POSxE, 22
    jne check_next50
    cmp POSyE, 12
    jne check_next50

    mov al, jogadorAtual
    mov si, offset array
    add si, 49   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next50:
	; Código para a combinação (5, 5) aqui
    cmp POSxE, 24
    jne check_next51
    cmp POSyE, 12
    jne check_next51

    mov al, jogadorAtual
    mov si, offset array
    add si, 50   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next51:
	; Código para a combinação (6, 5) aqui
    cmp POSxE, 20
    jne check_next52
    cmp POSyE, 13
    jne check_next52

    mov al, jogadorAtual
    mov si, offset array
    add si, 51   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next52:
	; Código para a combinação (7, 5) aqui
    cmp POSxE, 22
    jne check_next53
    cmp POSyE, 13
    jne check_next53

    mov al, jogadorAtual
    mov si, offset array
    add si, 52   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next53:
	; Código para a combinação (8, 5) aqui
    cmp POSxE, 24
    jne check_next54
    cmp POSyE, 13
    jne check_next54

    mov al, jogadorAtual
    mov si, offset array
    add si, 53   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 6

check_next54:
	; Código para a combinação (0, 6) aqui
    cmp POSxE, 4
    jne check_next55
    cmp POSyE, 15
    jne check_next55

    mov al, jogadorAtual
    mov si, offset array
    add si, 54   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next55:
	; Código para a combinação (1, 6) aqui
    cmp POSxE, 6
    jne check_next56
    cmp POSyE, 15
    jne check_next56

    mov al, jogadorAtual
    mov si, offset array
    add si, 55   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next56:
	; Código para a combinação (2, 6) aqui
    cmp POSxE, 8
    jne check_next57
    cmp POSyE, 15
    jne check_next57

    mov al, jogadorAtual
    mov si, offset array
    add si, 56   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next57:   
	; Código para a combinação (3, 6) aqui
    cmp POSxE, 4
    jne check_next58
    cmp POSyE, 16
    jne check_next58

    mov al, jogadorAtual
    mov si, offset array
    add si, 57   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next58:
	; Código para a combinação (4, 6) aqui
    cmp POSxE, 6
    jne check_next59
    cmp POSyE, 16
    jne check_next59

    mov al, jogadorAtual
    mov si, offset array
    add si, 58   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next59:
	; Código para a combinação (5, 6) aqui
    cmp POSxE, 8
    jne check_next60
    cmp POSyE, 16
    jne check_next60

    mov al, jogadorAtual
    mov si, offset array
    add si, 59   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next60:
	; Código para a combinação (6, 6) aqui
    cmp POSxE, 4
    jne check_next61
    cmp POSyE, 17
    jne check_next61

    mov al, jogadorAtual
    mov si, offset array
    add si, 60   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next61:
	; Código para a combinação (7, 6) aqui
    cmp POSxE, 6
    jne check_next62
    cmp POSyE, 17
    jne check_next62

    mov al, jogadorAtual
    mov si, offset array
    add si, 61   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next62:
	; Código para a combinação (8, 6) aqui
    cmp POSxE, 8
    jne check_next63
    cmp POSyE, 17
    jne check_next63

    mov al, jogadorAtual
    mov si, offset array
    add si, 62   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
;;  FIM TABULEIRO 7

check_next63:
	; Código para a combinação (0, 7) aqui
    cmp POSxE, 12
    jne check_next64
    cmp POSyE, 15
    jne check_next64

    mov al, jogadorAtual
    mov si, offset array
    add si, 63   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next64:
	; Código para a combinação (1, 7) aqui
    cmp POSxE, 14
    jne check_next65
    cmp POSyE, 15
    jne check_next65

    mov al, jogadorAtual
    mov si, offset array
    add si, 64   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next65:
	; Código para a combinação (2, 7) aqui
    cmp POSxE, 16
    jne check_next66
    cmp POSyE, 15
    jne check_next66

    mov al, jogadorAtual
    mov si, offset array
    add si, 65   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next66:
	; Código para a combinação (3, 7) aqui
    cmp POSxE, 12
    jne check_next67
    cmp POSyE, 16
    jne check_next67

    mov al, jogadorAtual
    mov si, offset array
    add si, 66   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next67:
	; Código para a combinação (4, 7) aqui
    cmp POSxE, 14
    jne check_next68
    cmp POSyE, 16
    jne check_next68

    mov al, jogadorAtual
    mov si, offset array
    add si, 67   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next68:
	; Código para a combinação (5, 7) aqui
    cmp POSxE, 16
    jne check_next69
    cmp POSyE, 16
    jne check_next69

    mov al, jogadorAtual
    mov si, offset array
    add si, 68   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next69:
	; Código para a combinação (6, 7) aqui
    cmp POSxE, 12
    jne check_next70
    cmp POSyE, 17
    jne check_next70

    mov al, jogadorAtual
    mov si, offset array
    add si, 69   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next70:
	; Código para a combinação (7, 7) aqui
    cmp POSxE, 14
    jne check_next71
    cmp POSyE, 17
    jne check_next71

    mov al, jogadorAtual
    mov si, offset array
    add si, 70   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next71:
	; Código para a combinação (8, 7) aqui
    cmp POSxE, 16
    jne check_next72
    cmp POSyE, 17
    jne check_next72

    mov al, jogadorAtual
    mov si, offset array
    add si, 71   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 8

check_next72:
	; Código para a combinação (0, 8) aqui
    cmp POSxE, 20
    jne check_next73
    cmp POSyE, 15
    jne check_next73

    mov al, jogadorAtual
    mov si, offset array
    add si, 72   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next73:
	; Código para a combinação (1, 8) aqui
    cmp POSxE, 22
    jne check_next74
    cmp POSyE, 15
    jne check_next74

    mov al, jogadorAtual
    mov si, offset array
    add si, 73   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next74:
	; Código para a combinação (2, 8) aqui
    cmp POSxE, 24
    jne check_next75
    cmp POSyE, 15
    jne check_next75

    mov al, jogadorAtual
    mov si, offset array
    add si, 74   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next75:
	; Código para a combinação (3, 8) aqui
    cmp POSxE, 20
    jne check_next76
    cmp POSyE, 16
    jne check_next76

    mov al, jogadorAtual
    mov si, offset array
    add si, 75   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next76:
	; Código para a combinação (4, 8) aqui
    cmp POSxE, 22
    jne check_next77
    cmp POSyE, 16
    jne check_next77

    mov al, jogadorAtual
    mov si, offset array
    add si, 76   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next77:
	; Código para a combinação (5, 8) aqui
    cmp POSxE, 24
    jne check_next78
    cmp POSyE, 16
    jne check_next78

    mov al, jogadorAtual
    mov si, offset array
    add si, 77   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next78:
	; Código para a combinação (6, 8) aqui
    cmp POSxE, 20
    jne check_next79
    cmp POSyE, 17
    jne check_next79

    mov al, jogadorAtual
    mov si, offset array
    add si, 78   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next79:
	; Código para a combinação (7, 8) aqui
    cmp POSxE, 22
    jne check_next80
    cmp POSyE, 17
    jne check_next80

    mov al, jogadorAtual
    mov si, offset array
    add si, 79   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next80:
	; Código para a combinação (8, 8) aqui
    cmp POSxE, 24
    jne end_coord
    cmp POSyE, 17
    jne end_coord

    mov al, jogadorAtual
    mov si, offset array
    add si, 80   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

; FIM TABULEIRO 9

end_coord:
	jmp WINNER

;########################################################################
;VERIFICA WINNER

WINNER:
	mov si, offset array ; carrega o endereço do array em SI
	
	BOARD_1:
		mov al, byte ptr [boardWinner1]
		cmp al, '1'
		je	BOARD_2

		LINHAS_1:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+1] ; compara o primeiro caractere com o segundo
			jne LINHA_1_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+2] ; compara o primeiro caractere com o terceiro
			jne LINHA_1_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

			LINHA_1_2:
			mov al, [si+3] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne LINHA_1_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+5] ; compara o quarto caractere com o sexto
			jne LINHA_1_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

			LINHA_1_3:
			mov al, [si+6] ; carrega o sétimo caractere em AL
			cmp al, [si+7] ; compara o sétimo caractere com o oitavo
			jne COLUNAS_1 ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o sétimo caractere com o nono
			jne COLUNAS_1 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

		COLUNAS_1:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+3] ; compara o primeiro caractere com o segundo
			jne COLUNA_1_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+6] ; compara o primeiro caractere com o terceiro
			jne COLUNA_1_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

			COLUNA_1_2:
			mov al, [si+1] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne COLUNA_1_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+7] ; compara o quarto caractere com o sexto
			jne COLUNA_1_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

			COLUNA_1_3:
			mov al, [si+3] ; carrega o sétimo caractere em AL
			cmp al, [si+5] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_1 ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_1 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

		DIAGONAIS_1:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+4] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_1_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_1_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1

			DIAGONAL_1_2:
			mov al, [si+2] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne BOARD_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+6] ; compara o quarto caractere com o sexto
			jne BOARD_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard1
		
	BOARD_2:
		mov al, byte ptr [boardWinner2]
		cmp al, '1'
		je	BOARD_3

		LINHAS_2:
			mov al, [si+9] ; carrega o primeiro caractere em AL
			cmp al, [si+10] ; compara o primeiro caractere com o segundo
			jne LINHA_2_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+11] ; compara o primeiro caractere com o terceiro
			jne LINHA_2_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

			LINHA_2_2:
			mov al, [si+12] ; carrega o quarto caractere em AL
			cmp al, [si+13] ; compara o quarto caractere com o quinto
			jne LINHA_2_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+14] ; compara o quarto caractere com o sexto
			jne LINHA_2_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

			LINHA_2_3:
			mov al, [si+15] ; carrega o sétimo caractere em AL
			cmp al, [si+16] ; compara o sétimo caractere com o oitavo
			jne COLUNAS_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+17] ; compara o sétimo caractere com o nono
			jne COLUNAS_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

		COLUNAS_2:
			mov al, [si+9] ; carrega o primeiro caractere em AL
			cmp al, [si+12] ; compara o primeiro caractere com o segundo
			jne COLUNA_2_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+15] ; compara o primeiro caractere com o terceiro
			jne COLUNA_2_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

			COLUNA_2_2:
			mov al, [si+10] ; carrega o quarto caractere em AL
			cmp al, [si+13] ; compara o quarto caractere com o quinto
			jne COLUNA_2_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+16] ; compara o quarto caractere com o sexto
			jne COLUNA_2_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

			COLUNA_2_3:
			mov al, [si+11] ; carrega o sétimo caractere em AL
			cmp al, [si+14] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+17] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

		DIAGONAIS_2:
			mov al, [si+9] ; carrega o primeiro caractere em AL
			cmp al, [si+13] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_2_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+17] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_2_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

			DIAGONAL_2_2:
			mov al, [si+11] ; carrega o quarto caractere em AL
			cmp al, [si+13] ; compara o quarto caractere com o quinto
			jne BOARD_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+15] ; compara o quarto caractere com o sexto
			jne BOARD_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard2

	BOARD_3:
		mov al, byte ptr [boardWinner3]
		cmp al, '1'
		je	BOARD_4

		LINHAS_3:
			mov al, [si+18] ; carrega o primeiro caractere em AL
			cmp al, [si+19] ; compara o primeiro caractere com o segundo
			jne LINHA_3_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+20] ; compara o primeiro caractere com o terceiro
			jne LINHA_3_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

			LINHA_3_2:
			mov al, [si+21] ; carrega o quarto caractere em AL
			cmp al, [si+22] ; compara o quarto caractere com o quinto
			jne LINHA_3_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+23] ; compara o quarto caractere com o sexto
			jne LINHA_3_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

			LINHA_3_3:
			mov al, [si+24] ; carrega o sétimo caractere em AL
			cmp al, [si+25] ; compara o sétimo caractere com o oitavo
			jne COLUNAS_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+26] ; compara o sétimo caractere com o nono
			jne COLUNAS_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

		COLUNAS_3:
			mov al, [si+18] ; carrega o primeiro caractere em AL
			cmp al, [si+21] ; compara o primeiro caractere com o segundo
			jne COLUNA_3_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+24] ; compara o primeiro caractere com o terceiro
			jne COLUNA_3_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

			COLUNA_3_2:
			mov al, [si+19] ; carrega o quarto caractere em AL
			cmp al, [si+22] ; compara o quarto caractere com o quinto
			jne COLUNA_3_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+25] ; compara o quarto caractere com o sexto
			jne COLUNA_3_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

			COLUNA_3_3:
			mov al, [si+20] ; carrega o sétimo caractere em AL
			cmp al, [si+23] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+26] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

		DIAGONAIS_3:
			mov al, [si+18] ; carrega o primeiro caractere em AL
			cmp al, [si+22] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_3_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+26] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_3_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

			DIAGONAL_3_2:
			mov al, [si+20] ; carrega o quarto caractere em AL
			cmp al, [si+22] ; compara o quarto caractere com o quinto
			jne BOARD_4 ; pula para "not_winner" se forem diferentes
			cmp al, [si+24] ; compara o quarto caractere com o sexto
			jne BOARD_4 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard3

	BOARD_4:
		mov al, byte ptr [boardWinner4]
		cmp al, '1'
		je	Board_5

		LINHAS_4:
			mov al, [si+27] ; carrega o primeiro caractere em AL
			cmp al, [si+28] ; compara o primeiro caractere com o segundo
			jne LINHA_4_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+29] ; compara o primeiro caractere com o terceiro
			jne LINHA_4_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

			LINHA_4_2:
			mov al, [si+30] ; carrega o quarto caractere em AL
			cmp al, [si+31] ; compara o quarto caractere com o quinto
			jne LINHA_4_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+32] ; compara o quarto caractere com o sexto
			jne LINHA_4_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

			LINHA_4_3:
			mov al, [si+33] ; carrega o sétimo caractere em AL
			cmp al, [si+34] ; compara o sétimo caractere com o oitavo
			jne COLUNAS_4 ; pula para "not_winner" se forem diferentes
			cmp al, [si+35] ; compara o sétimo caractere com o nono
			jne COLUNAS_4 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

		COLUNAS_4:
			mov al, [si+27] ; carrega o primeiro caractere em AL
			cmp al, [si+30] ; compara o primeiro caractere com o segundo
			jne COLUNA_4_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+33] ; compara o primeiro caractere com o terceiro
			jne COLUNA_4_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

			COLUNA_4_2:
			mov al, [si+28] ; carrega o quarto caractere em AL
			cmp al, [si+31] ; compara o quarto caractere com o quinto
			jne COLUNA_4_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+34] ; compara o quarto caractere com o sexto
			jne COLUNA_4_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

			COLUNA_4_3:
			mov al, [si+29] ; carrega o sétimo caractere em AL
			cmp al, [si+32] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_4 ; pula para "not_winner" se forem diferentes
			cmp al, [si+35] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_4 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard4

        DIAGONAIS_4:
            mov al, [si+27] ; carrega o primeiro caractere em AL
            cmp al, [si+31] ; compara o primeiro caractere com o segundo
            jne DIAGONAL_4_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+35] ; compara o primeiro caractere com o terceiro
            jne DIAGONAL_4_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard4

            DIAGONAL_4_2:
            mov al, [si+29] ; carrega o quarto caractere em AL
            cmp al, [si+31] ; compara o quarto caractere com o quinto
            jne Board_5 ; pula para "not_winner" se forem diferentes
            cmp al, [si+33] ; compara o quarto caractere com o sexto
            jne Board_5 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard4

	Board_5:
        mov al, byte ptr [boardWinner5]
        cmp al, '1'
        je    Board_6

        LINHAS_5:
            mov al, [si+36] ; carrega o primeiro caractere em AL
            cmp al, [si+37] ; compara o primeiro caractere com o segundo
            jne LINHA_5_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+38] ; compara o primeiro caractere com o terceiro
            jne LINHA_5_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard5

            LINHA_5_2:
            mov al, [si+39] ; carrega o quarto caractere em AL
            cmp al, [si+40] ; compara o quarto caractere com o quinto
            jne LINHA_5_3 ; pula para "not_winner" se forem diferentes
            cmp al, [si+41] ; compara o quarto caractere com o sexto
            jne LINHA_5_3 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard5

            LINHA_5_3:
            mov al, [si+42] ; carrega o sétimo caractere em AL
            cmp al, [si+43] ; compara o sétimo caractere com o oitavo
            jne COLUNAS_5 ; pula para "not_winner" se forem diferentes
            cmp al, [si+44] ; compara o sétimo caractere com o nono
            jne COLUNAS_5 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard5

		COLUNAS_5:
			mov al, [si+36] ; carrega o primeiro caractere em AL
			cmp al, [si+39] ; compara o primeiro caractere com o segundo
			jne COLUNA_5_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+42] ; compara o primeiro caractere com o terceiro
			jne COLUNA_5_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard5

			COLUNA_5_2:
			mov al, [si+37] ; carrega o quarto caractere em AL
			cmp al, [si+40] ; compara o quarto caractere com o quinto
			jne COLUNA_5_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+43] ; compara o quarto caractere com o sexto
			jne COLUNA_5_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard5

			COLUNA_5_3:
			mov al, [si+38] ; carrega o sétimo caractere em AL
			cmp al, [si+41] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_5 ; pula para "not_winner" se forem diferentes
			cmp al, [si+44] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_5 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard5

		DIAGONAIS_5:
			mov al, [si+36] ; carrega o primeiro caractere em AL
			cmp al, [si+40] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_5_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+44] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_5_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard5

			DIAGONAL_5_2:
			mov al, [si+38] ; carrega o quarto caractere em AL
			cmp al, [si+40] ; compara o quarto caractere com o quinto
			jne Board_6 ; pula para "not_winner" se forem diferentes
			cmp al, [si+42] ; compara o quarto caractere com o sexto
			jne Board_6 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard5

	Board_6:
        mov al, byte ptr [boardWinner6]
        cmp al, '1'
        je    Board_7

        LINHAS_6:
            mov al, [si+45] ; carrega o primeiro caractere em AL
            cmp al, [si+46] ; compara o primeiro caractere com o segundo
            jne LINHA_6_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+47] ; compara o primeiro caractere com o terceiro
            jne LINHA_6_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard6

            LINHA_6_2:
            mov al, [si+48] ; carrega o quarto caractere em AL
            cmp al, [si+49] ; compara o quarto caractere com o quinto
            jne LINHA_6_3 ; pula para "not_winner" se forem diferentes
            cmp al, [si+50] ; compara o quarto caractere com o sexto
            jne LINHA_6_3 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard6

            LINHA_6_3:
            mov al, [si+51] ; carrega o sétimo caractere em AL
            cmp al, [si+52] ; compara o sétimo caractere com o oitavo
            jne COLUNAS_6 ; pula para "not_winner" se forem diferentes
            cmp al, [si+53] ; compara o sétimo caractere com o nono
            jne COLUNAS_6 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard6

		COLUNAS_6:
			mov al, [si+45] ; carrega o primeiro caractere em AL
			cmp al, [si+48] ; compara o primeiro caractere com o segundo
			jne COLUNA_6_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+51] ; compara o primeiro caractere com o terceiro
			jne COLUNA_6_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard6

			COLUNA_6_2:
			mov al, [si+46] ; carrega o quarto caractere em AL
			cmp al, [si+49] ; compara o quarto caractere com o quinto
			jne COLUNA_6_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+52] ; compara o quarto caractere com o sexto
			jne COLUNA_6_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard6

			COLUNA_6_3:
			mov al, [si+47] ; carrega o sétimo caractere em AL
			cmp al, [si+50] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_6 ; pula para "not_winner" se forem diferentes
			cmp al, [si+53] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_6 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard6

        DIAGONAIS_6:
			mov al, [si+45] ; carrega o primeiro caractere em AL
			cmp al, [si+49] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_6_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+53] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_6_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard6

			DIAGONAL_6_2:
			mov al, [si+47] ; carrega o quarto caractere em AL
			cmp al, [si+49] ; compara o quarto caractere com o quinto
			jne Board_7 ; pula para "not_winner" se forem diferentes
			cmp al, [si+51] ; compara o quarto caractere com o sexto
			jne Board_7 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard6

	Board_7:
		mov al, byte ptr [boardWinner7]
		cmp al, '1'
		je    Board_8

        LINHAS_7:
            mov al, [si+54] ; carrega o primeiro caractere em AL
            cmp al, [si+55] ; compara o primeiro caractere com o segundo
            jne LINHA_7_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+56] ; compara o primeiro caractere com o terceiro
            jne LINHA_7_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard7

            LINHA_7_2:
            mov al, [si+57] ; carrega o quarto caractere em AL
            cmp al, [si+58] ; compara o quarto caractere com o quinto
            jne LINHA_7_3 ; pula para "not_winner" se forem diferentes
            cmp al, [si+59] ; compara o quarto caractere com o sexto
            jne LINHA_7_3 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard7

            LINHA_7_3:
            mov al, [si+60] ; carrega o sétimo caractere em AL
            cmp al, [si+61] ; compara o sétimo caractere com o oitavo
            jne COLUNAS_7 ; pula para "not_winner" se forem diferentes
            cmp al, [si+62] ; compara o sétimo caractere com o nono
            jne COLUNAS_7 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard7

		COLUNAS_7:
			mov al, [si+54] ; carrega o primeiro caractere em AL
			cmp al, [si+57] ; compara o primeiro caractere com o segundo
			jne COLUNA_7_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+60] ; compara o primeiro caractere com o terceiro
			jne COLUNA_7_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard7

			COLUNA_7_2:
			mov al, [si+55] ; carrega o quarto caractere em AL
			cmp al, [si+58] ; compara o quarto caractere com o quinto
			jne COLUNA_7_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+61] ; compara o quarto caractere com o sexto
			jne COLUNA_7_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard7

			COLUNA_7_3:
			mov al, [si+56] ; carrega o sétimo caractere em AL
			cmp al, [si+59] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_7 ; pula para "not_winner" se forem diferentes
			cmp al, [si+62] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_7 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard7

		DIAGONAIS_7:
			mov al, [si+54] ; carrega o primeiro caractere em AL
			cmp al, [si+58] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_7_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+62] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_7_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard7

			DIAGONAL_7_2:
			mov al, [si+56] ; carrega o quarto caractere em AL
			cmp al, [si+58] ; compara o quarto caractere com o quinto
			jne Board_8 ; pula para "not_winner" se forem diferentes
			cmp al, [si+60] ; compara o quarto caractere com o sexto
			jne Board_8 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard7

		
	Board_8:
        mov al, byte ptr [boardWinner8]
        cmp al, '1'
        je    Board_9

        LINHAS_8:
            mov al, [si+63] ; carrega o primeiro caractere em AL
            cmp al, [si+64] ; compara o primeiro caractere com o segundo
            jne LINHA_8_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+65] ; compara o primeiro caractere com o terceiro
            jne LINHA_8_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard8

            LINHA_8_2:
            mov al, [si+66] ; carrega o quarto caractere em AL
            cmp al, [si+67] ; compara o quarto caractere com o quinto
            jne LINHA_8_3 ; pula para "not_winner" se forem diferentes
            cmp al, [si+68] ; compara o quarto caractere com o sexto
            jne LINHA_8_3 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard8

            LINHA_8_3:
            mov al, [si+69] ; carrega o sétimo caractere em AL
            cmp al, [si+70] ; compara o sétimo caractere com o oitavo
            jne COLUNAS_8 ; pula para "not_winner" se forem diferentes
            cmp al, [si+71] ; compara o sétimo caractere com o nono
            jne COLUNAS_8 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard8

		COLUNAS_8:
			mov al, [si+63] ; carrega o primeiro caractere em AL
			cmp al, [si+66] ; compara o primeiro caractere com o segundo
			jne COLUNA_8_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+69] ; compara o primeiro caractere com o terceiro
			jne COLUNA_8_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard8

			COLUNA_8_2:
			mov al, [si+64] ; carrega o quarto caractere em AL
			cmp al, [si+67] ; compara o quarto caractere com o quinto
			jne COLUNA_8_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+70] ; compara o quarto caractere com o sexto
			jne COLUNA_8_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard8

			COLUNA_8_3:
			mov al, [si+65] ; carrega o sétimo caractere em AL
			cmp al, [si+68] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_8 ; pula para "not_winner" se forem diferentes
			cmp al, [si+71] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_8 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard8

		DIAGONAIS_8:
			mov al, [si+63] ; carrega o primeiro caractere em AL
			cmp al, [si+67] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_8_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+71] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_8_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard8

			DIAGONAL_8_2:
			mov al, [si+65] ; carrega o quarto caractere em AL
			cmp al, [si+67] ; compara o quarto caractere com o quinto
			jne Board_9 ; pula para "not_winner" se forem diferentes
			cmp al, [si+69] ; compara o quarto caractere com o sexto
			jne Board_9 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard8

	Board_9:
        mov al, byte ptr [boardWinner9]
        cmp al, '1'
        je    not_winner

        LINHAS_9:
            mov al, [si+72] ; carrega o primeiro caractere em AL
            cmp al, [si+73] ; compara o primeiro caractere com o segundo
            jne LINHA_9_2 ; pula para "not_winner" se forem diferentes
            cmp al, [si+74] ; compara o primeiro caractere com o terceiro
            jne LINHA_9_2 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard9

            LINHA_9_2:
            mov al, [si+75] ; carrega o quarto caractere em AL
            cmp al, [si+76] ; compara o quarto caractere com o quinto
            jne LINHA_9_3 ; pula para "not_winner" se forem diferentes
            cmp al, [si+77] ; compara o quarto caractere com o sexto
            jne LINHA_9_3 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard9

            LINHA_9_3:
            mov al, [si+78] ; carrega o sétimo caractere em AL
            cmp al, [si+79] ; compara o sétimo caractere com o oitavo
            jne COLUNAS_9 ; pula para "not_winner" se forem diferentes
            cmp al, [si+80] ; compara o sétimo caractere com o nono
            jne COLUNAS_9 ; pula para "not_winner" se forem diferentes
            jmp    ganhouBoard9

		COLUNAS_9:
			mov al, [si+72] ; carrega o primeiro caractere em AL
			cmp al, [si+75] ; compara o primeiro caractere com o segundo
			jne COLUNA_9_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+78] ; compara o primeiro caractere com o terceiro
			jne COLUNA_9_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard9

			COLUNA_9_2:
			mov al, [si+73] ; carrega o quarto caractere em AL
			cmp al, [si+76] ; compara o quarto caractere com o quinto
			jne COLUNA_9_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+79] ; compara o quarto caractere com o sexto
			jne COLUNA_9_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard9

			COLUNA_9_3:
			mov al, [si+74] ; carrega o sétimo caractere em AL
			cmp al, [si+77] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_9 ; pula para "not_winner" se forem diferentes
			cmp al, [si+80] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_9 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard9

		DIAGONAIS_9:
			mov al, [si+72] ; carrega o primeiro caractere em AL
			cmp al, [si+76] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_9_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+80] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_9_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard9

			DIAGONAL_9_2:
			mov al, [si+74] ; carrega o quarto caractere em AL
			cmp al, [si+76] ; compara o quarto caractere com o quinto
			jne not_winner ; pula para "not_winner" se forem diferentes
			cmp al, [si+78] ; compara o quarto caractere com o sexto
			jne not_winner ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoard9

	not_winner:
		jmp CICLO

	ganhouBoard1:
	mov byte ptr [boardWinner1], '1' ; Atualiza boardWinner1 para '1'
	jmp MOSTRA_WINNER_1

	ganhouBoard2:
	mov byte ptr [boardWinner2], '1'
	jmp MOSTRA_WINNER_2

	ganhouBoard3:
	mov byte ptr [boardWinner3], '1'
	jmp MOSTRA_WINNER_3

	ganhouBoard4:
	mov byte ptr [boardWinner4], '1'
	jmp MOSTRA_WINNER_4

	ganhouBoard5:
    mov byte ptr [boardWinner5], '1'
    jmp MOSTRA_WINNER_5

	ganhouBoard6:
    mov byte ptr [boardWinner6], '1'
    jmp MOSTRA_WINNER_6

	ganhouBoard7:
    mov byte ptr [boardWinner7], '1'
    jmp MOSTRA_WINNER_7

	ganhouBoard8:
    mov byte ptr [boardWinner8], '1' 
    jmp MOSTRA_WINNER_8

	ganhouBoard9:
    mov byte ptr [boardWinner9], '1' 
    jmp MOSTRA_WINNER_9

;########################################################################
;MOSTRA WINNERS

MOSTRA_WINNER_1:

	mov al, byte ptr [boardWinner1] ; Carrega o valor de boardWinner1 em al
	cmp al, '1' ; Compara com o caractere '1'
	jne CICLO
	
	goto_xy	53,11
	mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 0   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
	
    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array
    LOOP_WINNER_1:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_1 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_1 ; Pula para a próxima iteração se for igual a 'O'
        
        MOV BYTE PTR [SI], '-'

    PROXIMO_1:
        INC SI
        LOOP LOOP_WINNER_1  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_1:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array
        MOV DI, 0  ; Inicializa o contador de posição como 0

        LOOP_DESATIVA_1:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_1

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 0
            JE DESATIVA_1_0
            CMP DI, 1
            JE DESATIVA_1_1
            CMP DI, 2
            JE DESATIVA_1_2
            CMP DI, 3
            JE DESATIVA_1_3
            CMP DI, 4
            JE DESATIVA_1_4
            CMP DI, 5
            JE DESATIVA_1_5
            CMP DI, 6
            JE DESATIVA_1_6
            CMP DI, 7
            JE DESATIVA_1_7
            CMP DI, 8
            JE DESATIVA_1_8

            JMP PROXIMO_DESATIVA_1

        PROXIMO_DESATIVA_1:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_1  ; Repita o loop até que CX seja igual a zero

	;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_2:

	mov al, byte ptr [boardWinner2] ; Carrega o valor de boardWinner1 em al
	cmp al, '1' ; Compara com o caractere '1'
	jne CICLO
	
	goto_xy	55,11
	mov ah, 02h
    mov dl, JogadorAtual
    int 21H

		;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 1   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

    
    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 9
    LOOP_WINNER_2:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_2 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_2 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_2:
        INC SI
        LOOP LOOP_WINNER_2  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_2:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 9
        MOV DI, 9 ; Inicializa o contador de posição como 0

        LOOP_DESATIVA_2:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_2

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 9
            JE DESATIVA_2_0
            CMP DI, 10
            JE DESATIVA_2_1
            CMP DI, 11
            JE DESATIVA_2_2
            CMP DI, 12
            JE DESATIVA_2_3
            CMP DI, 13
            JE DESATIVA_2_4
            CMP DI, 14
            JE DESATIVA_2_5
            CMP DI, 15
            JE DESATIVA_2_6
            CMP DI, 16
            JE DESATIVA_2_7
            CMP DI, 17
            JE DESATIVA_2_8

            JMP PROXIMO_DESATIVA_2

        PROXIMO_DESATIVA_2:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_2  ; Repita o loop até que CX seja igual a zero
	
	;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_3:

	mov al, byte ptr [boardWinner3] ; Carrega o valor de boardWinner3 em al
	cmp al, '1' ; Compara com o caractere '1'
	jne CICLO
	
	goto_xy	57,11
	mov ah, 02h
    mov dl, JogadorAtual
    int 21H
	
	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 2   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

 
    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 18
    LOOP_WINNER_3:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_3 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_3 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_3:
        INC SI
        LOOP LOOP_WINNER_3  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_3:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 18
        MOV DI, 18 ; Inicializa o contador de posição como 18

        LOOP_DESATIVA_3:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_3

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 18
            JE DESATIVA_3_0
            CMP DI, 19
            JE DESATIVA_3_1
            CMP DI, 20
            JE DESATIVA_3_2
            CMP DI, 21
            JE DESATIVA_3_3
            CMP DI, 22
            JE DESATIVA_3_4
            CMP DI, 23
            JE DESATIVA_3_5
            CMP DI, 24
            JE DESATIVA_3_6
            CMP DI, 25
            JE DESATIVA_3_7
            CMP DI, 26
            JE DESATIVA_3_8

            JMP PROXIMO_DESATIVA_3

        PROXIMO_DESATIVA_3:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_3  ; Repita o loop até que CX seja igual a zero

	;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_4:

	mov al, byte ptr [boardWinner4] ; Carrega o valor de boardWinner4 em al
	cmp al, '1' ; Compara com o caractere '1'
	jne CICLO
	
	goto_xy	53,12
	mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 3   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 27
    LOOP_WINNER_4:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_4 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_4 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_4:
        INC SI
        LOOP LOOP_WINNER_4  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_4:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 27
        MOV DI, 27 ; Inicializa o contador de posição como 18

        LOOP_DESATIVA_4:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_4

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 27
            JE DESATIVA_4_0
            CMP DI, 28
            JE DESATIVA_4_1
            CMP DI, 29
            JE DESATIVA_4_2
            CMP DI, 30
            JE DESATIVA_4_3
            CMP DI, 31
            JE DESATIVA_4_4
            CMP DI, 32
            JE DESATIVA_4_5
            CMP DI, 33
            JE DESATIVA_4_6
            CMP DI, 34
            JE DESATIVA_4_7
            CMP DI, 35
            JE DESATIVA_4_8

            JMP PROXIMO_DESATIVA_4

        PROXIMO_DESATIVA_4:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_4 ; Repita o loop até que CX seja igual a zero
	
	;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_5:

    mov al, byte ptr [boardWinner5] ; Carrega o valor de boardWinner5 em al
    cmp al, '1' ; Compara com o caractere '1'
    jne CICLO

    goto_xy    55,12
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 4   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 36
    LOOP_WINNER_5:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_5 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_5 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_5:
        INC SI
        LOOP LOOP_WINNER_5  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_5:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 36
        MOV DI, 36 ; Inicializa o contador de posição como 18

        LOOP_DESATIVA_5:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_5

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 36
            JE DESATIVA_5_0
            CMP DI, 37
            JE DESATIVA_5_1
            CMP DI, 38
            JE DESATIVA_5_2
            CMP DI, 39
            JE DESATIVA_5_3
            CMP DI, 40
            JE DESATIVA_5_4
            CMP DI, 41
            JE DESATIVA_5_5
            CMP DI, 42
            JE DESATIVA_5_6
            CMP DI, 43
            JE DESATIVA_5_7
            CMP DI, 44
            JE DESATIVA_5_8

            JMP PROXIMO_DESATIVA_5

        PROXIMO_DESATIVA_5:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_5 ; Repita o loop até que CX seja igual a zero

    ;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_6:

    mov al, byte ptr [boardWinner6] ; Carrega o valor de boardWinner6 em al
    cmp al, '1' ; Compara com o caractere '1'
    jne CICLO

    goto_xy    57,12
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 5   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 45
    LOOP_WINNER_6:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_6 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_6 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_6:
        INC SI
        LOOP LOOP_WINNER_6  ; Repita o loop até que CX seja igual a zero

    DESATIVAR_6:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 45
        MOV DI, 45 ; Inicializa o contador de posição como 45

        LOOP_DESATIVA_6:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_6

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 45
            JE DESATIVA_6_0
            CMP DI, 46
            JE DESATIVA_6_1
            CMP DI, 47
            JE DESATIVA_6_2
            CMP DI, 48
            JE DESATIVA_6_3
            CMP DI, 49
            JE DESATIVA_6_4
            CMP DI, 50
            JE DESATIVA_6_5
            CMP DI, 51
            JE DESATIVA_6_6
            CMP DI, 52
            JE DESATIVA_6_7
            CMP DI, 53
            JE DESATIVA_6_8

            JMP PROXIMO_DESATIVA_6

        PROXIMO_DESATIVA_6:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_6 ; Repita o loop até que CX seja igual a zero


    ;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_7:

    mov al, byte ptr [boardWinner7] ; Carrega o valor de boardWinner7 em al
    cmp al, '1' ; Compara com o caractere '1'
    jne CICLO

    goto_xy    53,13
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 6   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 54
    LOOP_WINNER_7:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_7 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_7 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_7:
        INC SI
        LOOP LOOP_WINNER_7 ; Repita o loop até que CX seja igual a zero

    DESATIVAR_7:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 54
        MOV DI, 54 ; Inicializa o contador de posição como 54

        LOOP_DESATIVA_7:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_7

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 54
            JE DESATIVA_7_0
            CMP DI, 55
            JE DESATIVA_7_1
            CMP DI, 56
            JE DESATIVA_7_2
            CMP DI, 57
            JE DESATIVA_7_3
            CMP DI, 58
            JE DESATIVA_7_4
            CMP DI, 59
            JE DESATIVA_7_5
            CMP DI, 60
            JE DESATIVA_7_6
            CMP DI, 61
            JE DESATIVA_7_7
            CMP DI, 62
            JE DESATIVA_7_8

            JMP PROXIMO_DESATIVA_7

        PROXIMO_DESATIVA_7:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_7 ; Repita o loop até que CX seja igual a zero

    ;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_8:

    mov al, byte ptr [boardWinner8] ; Carrega o valor de boardWinner8 em al
    cmp al, '1' ; Compara com o caractere '1'
    jne CICLO

    goto_xy    55,13
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 7   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

    ;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 63
    LOOP_WINNER_8:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_8 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_8 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_8:
        INC SI
        LOOP LOOP_WINNER_8 ; Repita o loop até que CX seja igual a zero

    DESATIVAR_8:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 63
        MOV DI, 63 ; Inicializa o contador de posição como 63

        LOOP_DESATIVA_8:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_8

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 63
            JE DESATIVA_8_0
            CMP DI, 64
            JE DESATIVA_8_1
            CMP DI, 65
            JE DESATIVA_8_2
            CMP DI, 66
            JE DESATIVA_8_3
            CMP DI, 67
            JE DESATIVA_8_4
            CMP DI, 68
            JE DESATIVA_8_5
            CMP DI, 69
            JE DESATIVA_8_6
            CMP DI, 70
            JE DESATIVA_8_7
            CMP DI, 71
            JE DESATIVA_8_8

            JMP PROXIMO_DESATIVA_8

        PROXIMO_DESATIVA_8:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_8 ; Repita o loop até que CX seja igual a zero

    ;jmp CICLO
	jmp WINNER_FINAL

MOSTRA_WINNER_9:

    mov al, byte ptr [boardWinner9] ; Carrega o valor de boardWinner9 em al
    cmp al, '1' ; Compara com o caractere '1'
    jne CICLO

    goto_xy    57,13
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

	;guarda no array final
	mov al, jogadorAtual
    mov si, offset arrayFinal
    add si, 8   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array

;desativar o mini tabuleiro
    MOV CX, 9  ; Defina o contador do loop para 9
    MOV SI, offset array + 72
    LOOP_WINNER_9:
        MOV AL, [SI] ; Carrega o valor da posição atual do array em AL
        CMP AL, 'X' ; Compara com o caractere 'X'
        JE PROXIMO_9 ; Pula para a próxima iteração se for igual a 'X'
        CMP AL, 'O' ; Compara com o caractere 'O'
        JE PROXIMO_9 ; Pula para a próxima iteração se for igual a 'O'
       
        MOV BYTE PTR [SI], '-'
    PROXIMO_9:
        INC SI
        LOOP LOOP_WINNER_9 ; Repita o loop até que CX seja igual a zero

    DESATIVAR_9:
        MOV CX, 9  ; Defina o contador do loop para 9
        MOV SI, offset array + 72
        MOV DI, 72 ; Inicializa o contador de posição como 63

        LOOP_DESATIVA_9:
            MOV AL, [SI]
            CMP AL, '-'
            JNE PROXIMO_DESATIVA_9

            ; Exibir 0FFh na tela com base no índice do array
            CMP DI, 72
            JE DESATIVA_9_0
            CMP DI, 73
            JE DESATIVA_9_1
            CMP DI, 74
            JE DESATIVA_9_2
            CMP DI, 75
            JE DESATIVA_9_3
            CMP DI, 76
            JE DESATIVA_9_4
            CMP DI, 77
            JE DESATIVA_9_5
            CMP DI, 78
            JE DESATIVA_9_6
            CMP DI, 79
            JE DESATIVA_9_7
            CMP DI, 80
            JE DESATIVA_9_8

            JMP PROXIMO_DESATIVA_9

        PROXIMO_DESATIVA_9:
            INC SI
            INC DI
            LOOP LOOP_DESATIVA_9 ; Repita o loop até que CX seja igual a zero

    ;jmp CICLO
	jmp WINNER_FINAL
;########################################################################
;VERIFICA WINNER FINAL

WINNER_FINAL:

	mov si, offset arrayFinal ; carrega o endereço do array em SI
	
	BOARD_FINAL:
		mov al, byte ptr [FinalWinner]
		cmp al, '1'
		je	CICLO

		LINHAS_FINAL:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+1] ; compara o primeiro caractere com o segundo
			jne LINHA_FINAL_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+2] ; compara o primeiro caractere com o terceiro
			jne LINHA_FINAL_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

			LINHA_FINAL_2:
			mov al, [si+3] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne LINHA_FINAL_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+5] ; compara o quarto caractere com o sexto
			jne LINHA_FINAL_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

			LINHA_FINAL_3:
			mov al, [si+6] ; carrega o sétimo caractere em AL
			cmp al, [si+7] ; compara o sétimo caractere com o oitavo
			jne COLUNAS_FINAL ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o sétimo caractere com o nono
			jne COLUNAS_FINAL ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

		COLUNAS_FINAL:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+3] ; compara o primeiro caractere com o segundo
			jne COLUNA_FINAL_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+6] ; compara o primeiro caractere com o terceiro
			jne COLUNA_FINAL_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

			COLUNA_FINAL_2:
			mov al, [si+1] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne COLUNA_FINAL_3 ; pula para "not_winner" se forem diferentes
			cmp al, [si+7] ; compara o quarto caractere com o sexto
			jne COLUNA_FINAL_3 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

			COLUNA_FINAL_3:
			mov al, [si+2] ; carrega o sétimo caractere em AL
			cmp al, [si+5] ; compara o sétimo caractere com o oitavo
			jne DIAGONAIS_FINAL ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o sétimo caractere com o nono
			jne DIAGONAIS_FINAL ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

		DIAGONAIS_FINAL:
			mov al, [si] ; carrega o primeiro caractere em AL
			cmp al, [si+4] ; compara o primeiro caractere com o segundo
			jne DIAGONAL_FINAL_2 ; pula para "not_winner" se forem diferentes
			cmp al, [si+8] ; compara o primeiro caractere com o terceiro
			jne DIAGONAL_FINAL_2 ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

			DIAGONAL_FINAL_2:
			mov al, [si+2] ; carrega o quarto caractere em AL
			cmp al, [si+4] ; compara o quarto caractere com o quinto
			jne CICLO ; pula para "not_winner" se forem diferentes
			cmp al, [si+6] ; compara o quarto caractere com o sexto
			jne CICLO ; pula para "not_winner" se forem diferentes
			jmp	ganhouBoardFinal

	ganhouBoardFinal:
	mov byte ptr [FinalWinner], '1' ; Atualiza boardWinner1 para '1'
	jmp MOSTRA_WINNER_FINAL

;########################################################################
;MOSTRA WINNER FINAL

MOSTRA_WINNER_FINAL:

	mov al, byte ptr [FinalWinner] ; Carrega o valor de boardWinner1 em al
	cmp al, '1' ; Compara com o caractere '1'
	jne CICLO

    call FINAL

;########################################################################
;DESATIVA OS TABULEIROS

;DESATIVA_TABULEIRO_1
    DESATIVA_1_0:
        goto_xy 4, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_1:
        goto_xy 6, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_2:
        goto_xy 8, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1
    
    ;linha 2
    DESATIVA_1_3:
        goto_xy 4, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_4:
        goto_xy 6, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_5:
        goto_xy 8, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    ;linha 3
    DESATIVA_1_6:
        goto_xy 4, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_7:
        goto_xy 6, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1

    DESATIVA_1_8:
        goto_xy 8, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_1
    
;DESATIVA_TABULEIRO_2
    DESATIVA_2_0:
        goto_xy 12, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_1:
        goto_xy 14, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_2:
        goto_xy 16, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2
    
    ;linha 2
    DESATIVA_2_3:
        goto_xy 12, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_4:
        goto_xy 14, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_5:
        goto_xy 16, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    ;linha 3
    DESATIVA_2_6:
        goto_xy 12, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_7:
        goto_xy 14, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

    DESATIVA_2_8:
        goto_xy 16, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_2

;DESATIVA_TABULEIRO_3
    DESATIVA_3_0:
        goto_xy 20, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_1:
        goto_xy 22, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_2:
        goto_xy 24, 7
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3
    
    ;linha 2
    DESATIVA_3_3:
        goto_xy 20, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_4:
        goto_xy 22, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_5:
        goto_xy 24, 8
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    ;linha 3
    DESATIVA_3_6:
        goto_xy 20, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_7:
        goto_xy 22, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

    DESATIVA_3_8:
        goto_xy 24, 9
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_3

;DESATIVA_TABULEIRO_4
    DESATIVA_4_0:
        goto_xy 4, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_1:
        goto_xy 6, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_2:
        goto_xy 8,11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4
    
    ;linha 2
    DESATIVA_4_3:
        goto_xy 4, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_4:
        goto_xy 6, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_5:
        goto_xy 8, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    ;linha 3
    DESATIVA_4_6:
        goto_xy 4, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_7:
        goto_xy 6, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

    DESATIVA_4_8:
        goto_xy 8, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_4

;DESATIVA_TABULEIRO_5
    DESATIVA_5_0:
        goto_xy 12, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_1:
        goto_xy 14, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_2:
        goto_xy 16,11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5
    
    ;linha 2
    DESATIVA_5_3:
        goto_xy 12, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_4:
        goto_xy 14, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_5:
        goto_xy 16, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    ;linha 3
    DESATIVA_5_6:
        goto_xy 12, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_7:
        goto_xy 14, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5

    DESATIVA_5_8:
        goto_xy 16, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_5
    
;DESATIVA_TABULEIRO_6
    DESATIVA_6_0:
        goto_xy 20, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_1:
        goto_xy 22, 11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_2:
        goto_xy 24,11
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6
    
    ;linha 2
    DESATIVA_6_3:
        goto_xy 20, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_4:
        goto_xy 22, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_5:
        goto_xy 24, 12
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    ;linha 3
    DESATIVA_6_6:
        goto_xy 20, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_7:
        goto_xy 22, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6

    DESATIVA_6_8:
        goto_xy 24, 13
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_6


;DESATIVA_TABULEIRO_7
    DESATIVA_7_0:
        goto_xy 4, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_1:
        goto_xy 6, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_2:
        goto_xy 8,15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7
    
    ;linha 2
    DESATIVA_7_3:
        goto_xy 4, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_4:
        goto_xy 6, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_5:
        goto_xy 8, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    ;linha 3
    DESATIVA_7_6:
        goto_xy 4, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_7:
        goto_xy 6, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

    DESATIVA_7_8:
        goto_xy 8, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_7

;DESATIVA_TABULEIRO_8
    DESATIVA_8_0:
        goto_xy 12, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_1:
        goto_xy 14, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_2:
        goto_xy 16,15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8
    
    ;linha 2
    DESATIVA_8_3:
        goto_xy 12, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_4:
        goto_xy 14, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_5:
        goto_xy 16, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    ;linha 3
    DESATIVA_8_6:
        goto_xy 12, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_7:
        goto_xy 14, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8

    DESATIVA_8_8:
        goto_xy 16, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_8


;DESATIVA_TABULEIRO_9
    DESATIVA_9_0:
        goto_xy 20, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_1:
        goto_xy 22, 15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_2:
        goto_xy 24,15
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9
    
    ;linha 2
    DESATIVA_9_3:
        goto_xy 20, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_4:
        goto_xy 22, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_5:
        goto_xy 24, 16
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    ;linha 3
    DESATIVA_9_6:
        goto_xy 20, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_7:
        goto_xy 22, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

    DESATIVA_9_8:
        goto_xy 22, 17
        mov ah, 02h
        mov dl, 0FFh
        int 21H
        JMP PROXIMO_DESATIVA_9

;########################################################################
;FINAL

;########################################################################
FIM:				
			RET
AVATAR		endp

;########################################################################
;MOSTRA A STRING DOS JOGADORES
MOSTRA MACRO STR 
    lea dx, STR + 2 ; Pular os dois primeiros bytes (tamanho da string)
    mov ah, 9
    int 21h
ENDM

;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax

		call		apaga_ecran
        
        goto_xy		0,0
        lea dx, msgInicio
        mov ah, 9
        int 21h

        ; Exibir mensagem para jogador 1
        goto_xy		0,2
        lea dx, msg1
        mov ah, 9
        int 21h

        ; Receber string do jogador 1
        lea dx, player1
        mov ah, 0ah
        int 21h

        ; Exibir mensagem para jogador 2
        lea dx, msg2
        mov ah, 9
        int 21h

        ; Receber string do jogador 2
        lea dx, player2
        mov ah, 0ah
        int 21h

        ; Exibir mensagem para jogador 1
        goto_xy		0,5
        lea dx, msgFinal
        mov ah, 9
        int 21h

        call 	LE_TECLA

        call		apaga_ecran

		; Inicialização do gerador de números aleatórios
		MOV AH, 00H  ; Configurar função AH=00H para inicializar o gerador de números aleatórios
		INT 1AH      ; Chamar a interrupção para obter o contador de tempo atual em CX e DX

		; Gerar número aleatório entre 0 e 1
		MOV AX, CX   ; Mover o valor de CX para AX
		MOV BX, DX   ; Mover o valor de DX para BX
		XOR AX, BX   ; Executar a operação XOR entre AX e BX para obter um valor aleatório em AX

		; Atribuir símbolos aos jogadores com base no valor aleatório
		MOV BL, AL   ; Mover o valor aleatório para BL
		AND BL, 0001H ; Máscara para manter apenas o bit menos significativo

		GOTO_XY		5,1
		MOSTRA 		player1
		GOTO_XY		5,2
		MOSTRA 		player2

		;A JOGAR
		GOTO_XY		10,4
		MOV AX, 'X'  ; Armazenar 'X' em AX
		CMP BL, 0
		JE s_ajogar
		MOV AX, 'O'  ; Se BL for diferente de 0, armazenar 'O' em AX
		s_ajogar:
		MOV DL, AL   ; Mover o símbolo para DL
		MOV AH, 02H

		MOV JogadorAtual, AL ;guarda quem é que está a jogar
		
		;Jogador1
		GOTO_XY		1,1
		MOV AL, 'X'
		CMP BL, 0
		JE s_jogador1
		MOV AL, 'O'
		s_jogador1:
		MOV DL, AL
		MOV AH, 02H
		INT 21H

		;Jogador2
		GOTO_XY		1,2
		MOV AL, 'O'
		CMP BL, 0
		JE s_jogador2
		MOV AL, 'X'
		s_jogador2:
		MOV DL, AL
		MOV AH, 02H
		INT 21H

        goto_xy	    3,1
        mov         ah, 02h
        mov         dl, '-'
        int         21H

        goto_xy	    3,2
        mov         ah, 02h
        mov         dl, '-'
        int         21H

		goto_xy		0,0
		call		IMP_FICH

		call 		AVATAR
		goto_xy		0,22

        FINAL proc
            mov al, byte ptr [FinalWinner]
		    cmp al, '1'
            jne EMPATE

            call		apaga_ecran
            GOTO_XY		0,0
            MOSTRA 		msgVencedor
            GOTO_XY		50,8
            MOSTRA 		msgVencedor2
            goto_xy	    60,8
            mov         ah, 02h
            mov         dl, JogadorAtual
            int         21H

            EMPATE:
            GOTO_XY		52,8
            MOSTRA 		msgEmpate

            goto_xy	    0,22

        FINAL endp

		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main


		
