paint macro  x1, y1, x2, y2, color
    mov al, 0d                      ; number of lines by which to scroll                      
    mov ah, 06h                     ; interruption to change colors
    mov bh, color                   ; color that'll be painted
    mov ch, y1                      ; y start position
    mov cl, x1                      ; x start position
    mov dh, y2                      ; y finish position
    mov dl, x2                      ; x finish position
    int 10h
endm

movecursor macro x, y       
    mov ah, 02h                     ; interruption to move cursor       
    mov bh, 0d                      ; page of the emulator terminal
    mov dh, y                       ; y position
    mov dl, x                       ; x position
    int 10h         
endm

print macro char, amount
    local label1
    mov cl, amount                  ; store amount in a register
    label1:                         ; return point
        mov dl, char                ; prepare the char to print in dl
        mov ah, 2h                  ; interruption to print chars
        int 21h
        dec cl                      ; decrement amount
        cmp cl, 0d                  ; compare amount with zero
        jne label1                  ; if not equals, loop
endm


.model small
.stack 100h  
.data
    trash db 50 dup(?)
    msgpresskey db '>> PRESIONA UNA TECLA PARA CONTINUAR <<$'
    msgintro01 db '>> Introduccion <<$'
    msgintro02 db 'Bienvenido a SimonDice, donde deberas$'
    msgintro03 db 'memorizar una secuencia de colores y$'
    msgintro04 db 'hacer click en los correspondientes$'
    msgintro05 db 'mientras la secuencia se alarga$'
    msgintro06 db 'en cada nivel y aumenta la velocidad.$'
    msgcargando db '>> CARGANDO <<$'
    msgdificultad db '>> DIFICULTAD <<$'
    msgganaste db '>> GANASTE <<$'
    msgperdiste db '>> PERDISTE <<$'
    msgmemoriza db '>> MEMORIZA <<$'
    msgtuturno db  '>> Tu Turno <<$'
    msggraciasporjugar db 'Gracias por jugar$'
    msgpuntaje db 'Puntaje: $'
    msgnivel db 'Nivel: $'
    msgreiniciar db 'r: reiniciar$'
    msgsalir db 's: salir$'
    msgfacil db '0: Facil$'
    msgmedio db '1: Medio$'
    msgdificil db '2: Dificil$'
    msgauto db '3: Auto$'
    msgoption db '--> $'
    option db 0d
    seedcounter db 20
    listnotrandomseed db 20 dup(?)
    seed db 10 dup(?)
    multiplier db 10 dup(?)
    random db 10 dup(?)
    listtrytoguess db 10 dup(?)
    amounttrytoguess db 0d
    indextrytoguess db 0d
    colorguess db 0d
    curX dw 0d
    curY dw 0d
    puntaje db 0d
    nivel db 0d
    vecesperdidas db 0d
    timertolose dw 0d         
.code
start:
    
    mov ax, @data                       ; store data direction in ax
    mov ds, ax                          ; move the direction in data segment
    
    call introscreen                    ; call to the presentation screen
    
    ;>>>>>>>>>> MAIN <<<<<<<<<<
    reloadpoint:                        ; mark to reload the program
    
    call loadscreen                     ; calling load screen, where pseudorandom numbers are make
    
    call firstscreen                    ; first screen, where the user choose the difficulty
    
    call mousesetup                     ; turn on the mouse pointer
    
    call gamescreen                     ; here starts the game
    
    ;>>>>>>>>>> END MAIN <<<<<<<<<< 
    
    ;>>>>>>>>>> SETUP <<<<<<<<<<
    mousesetup:
                                        ; clean all registers
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor di, di
        
                                        ; reset mouse, initialize it and get its status
        int 33h
        cmp ax, 0d 
        
                                        ; display mouse cursor
        popa
        mov ax, 1d
        int 33h
        pusha    
        
        ret                             ; return
    ;>>>>>>>>>> END SETUP <<<<<<<<<<
    
    
    ;>>>>>>>>>> METHODS <<<<<<<<<<
    introscreen:
        pusha
        paint 0d, 0d, 79d, 24d, 143d    ; paint the background in gray
        paint 19d, 4d, 60d, 20d, 15d    ; paint a black square
        
        movecursor 32d, 7d              ; move cursor at (32,7)
        lea dx, msgintro01              ; print intro 01 message
        mov ah, 9h
        int 21h
        
        movecursor 21d, 10d             ; move cursor at (21,10)
        lea dx, msgintro02              ; print intro 02 message
        mov ah, 9h
        int 21h
        
        movecursor 21d, 11d             ; move cursor at (21,11)
        lea dx, msgintro03              ; print intro 03 message
        mov ah, 9h
        int 21h
        
        movecursor 21d, 12d             ; move cursor at (21,12)
        lea dx, msgintro04              ; print intro 04 message
        mov ah, 9h
        int 21h
        
        movecursor 21d, 13d             ; move cursor at (21,13)
        lea dx, msgintro05              ; print intro 05 message
        mov ah, 9h
        int 21h
        
        movecursor 21d, 14d             ; move cursor at (21,14)
        lea dx, msgintro06              ; print intro 06 message
        mov ah, 9h
        int 21h
        
        movecursor 20d, 18d             ; move cursor at (21,18)
        lea dx, msgpresskey             ; print press key message
        mov ah, 9h
        int 21h
          
        mov ah, 0d                      ; wait for the user to press a key
        int 16h                         ; wait interruption 16h/0h
        
        popa
        ret
    
    loadscreen:
        pusha                           ; store all registers in stack
        paint 0d, 0d, 79d, 24d, 143d
        paint 31d, 10d, 46d, 12d, 128d
        paint 32d, 11d, 45d, 11d, 141d
        
        movecursor 31d, 10d             ; move cursor at (31, 10)
        print '-', 16d                  ; print '-' 16 times
        movecursor 31d, 12d             ; move cursor at (31, 12)
        print '-', 16d                  ;print '-' 16 times
        movecursor 31d, 11d             ; move cursor at (31, 11)
        mov dl, '|'                     ; move '|' char in dl
        call putc                       ; print the char
        movecursor 46d, 11d             ; move cursor at (46, 11)
        mov dl, '|'                     ; move '|' char in dl
        call putc                       ; print the char
        
        movecursor 32d, 7d              ; move cursor at (32, 7)
        lea dx, msgcargando             ; store load message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
        
        ; -- LOAD DATA --
        call getseeds                   ; call getseeds sub routine
        movecursor 32d, 11d             ; move cursor at (32, 11)
        print '#', 5d                   ; print '#' 5 times
        
        call dividearray                ; call dividearray sub routine
        movecursor 37d, 11d             ; move cursor at (37, 11)
        print '#', 5d                   ; print '#' 5 times
        
        call generaterandomnumber       ; call generaterandomnumber sub routine
        movecursor 42d, 11d             ; move cursor at (42, 11)
        print '#', 4d                   ; print '#' 4 times
        ; -- END LOAD --
        
        movecursor 20d, 7d              ; move cursor at (20, 7)
        lea dx, msgpresskey             ; get press key message in dx
        mov ah, 9h                      ; call print string interruption
        int 21h
        
        mov ah, 0d                      ; wait until a key is pressed
        int 16h
        
        popa                            ; get all registers from stack
        ret
    
    firstscreen:
        pusha
        paint 0d, 0d, 40d, 12d, 127d    ; paint gray
        paint 41d, 0d, 79d, 12d, 159d   ; paint blue
        paint 0d, 13d, 40d, 24d, 207d   ; paint red
        paint 41d, 13d, 79d, 24d, 175d  ; paint green
        paint 19d, 4d, 60d, 20d, 15d    ; Paint black with white letters
                   
        movecursor 32d, 7d              ; move cursor at (32,7)
        lea dx, msgdificultad           ; print difficulty message
        mov ah, 9h                      ; call print string interruption
        int 21h 

        movecursor 35d, 10d             ; move cursor at (35,10)
        lea dx, msgfacil                ; print easy difficulty message
        mov ah, 9h                      ; call print string interruption
        int 21h 
        
        movecursor 35d, 12d             ; move cursor at (35,12)
        lea dx, msgmedio                ; print medium difficulty message
        mov ah, 9h                      ; call print string interruption
        int 21h       
        
        movecursor 35d, 14d             ; move cursor at (35,14)
        lea dx, msgdificil              ; print hard difficulty message
        mov ah, 9h                      ; call print string interruption
        int 21h
        
        movecursor 35d, 16d             ; move cursor at (35,16)
        lea dx, msgauto                 ; print auto difficulty message
        mov ah, 9h                      ; call print string interruption
        int 21h
        
        inputoption:
        paint 20d, 18d, 27d, 20d, 15d   ; print a black line
        movecursor 21d, 19d             ; move cursor at (21,19)
        lea dx, msgoption               ; print the input place message
        mov ah, 9h                      ; call print string interruption
        int 21h
        xor ax, ax                      ; erase ax register
        mov ah, 1h                      ; wait for an input of difficulty
        int 21h
        
        cmp al, '0'                     ; verify if it's 0
        je labeloption
        cmp al, '1'                     ; verify if it's 1
        je labeloption                 
        cmp al, '2'                     ; verify if it's 2
        je labeloption                  
        cmp al, '3'                     ; verify if it's not 3, if it's not, ask again
        jne inputoption 
        
        mov al, vecesperdidas           ; if it's 3 move time losts as option
        add al, 48d
        
        labeloption:
        sub al, 48d                     ; substract 48d to get the number
        mov option, al                  ; store the number in option variable
         
        mov cx, 07h                     ; wait 0,5 seconds (0,5 million microseconds)
        mov dx, 0A120h
        mov ah, 86h                     ; wait interruption
        int 15h
        
        popa
        ret
    
    gamescreen:
        pusha                           ; store all registers in stack
        pusha                           ; store all registers in stack
        paint 0d, 0d, 79d, 24d, 15d     ; paint all the screen in black
        paint 0d, 0d, 20d, 12d, 143d    ; paint gray
        paint 21d, 0d, 42d, 12d, 31d    ; paint blue
        paint 0d, 13d, 20d, 24d, 79d    ; paint red
        paint 21d, 13d, 42d, 24d, 47d   ; paint green
        paint 43d, 0d, 79d, 24d, 15d    ; paint black
        popa
        
        movecursor 53d, 1d              ; move cursor to (53, 1)
        lea dx, msgdificultad           ; get msgdificultad to dx
        mov ah,9h                       ; call print string interruption
        int 21h
        
        movecursor 55d, 3d              ; move cursor to (53, 3)
        cmp option, 0d                  ; verify if difficulty is easy
        je printeasy
        cmp option, 1d                  ; verify if difficulty is medium
        je printmedium
        cmp option, 2d                  ; verify if difficulty is hard
        je printhard                 
        
        printeasy:                      ; get msgfacil to dx
            lea dx, msgfacil            ; call print string interruption
            mov ah, 9h
            int 21h
            jmp printdificultend        ; exit
        
        printmedium:
            lea dx, msgmedio            ; get msgmedio to dx
            mov ah, 9h                  ; call print string interruption
            int 21h
            jmp printdificultend        ; exit
        
        printhard:  
            lea dx, msgdificil          ; get msgdificil to dx
            mov ah, 9h                  ; call print string interruption
            int 21h 
            
        printdificultend:
        
        movecursor 55d, 17d             ; move cursor to (55, 17)
        lea dx, msgreiniciar            ; get msgreiniciar to dx
        mov ah, 9h                      ; call print string interruption
        int 21h
        
        movecursor 55d, 19d             ; move cursor to (55, 19)
        lea dx, msgsalir                ; get msgsalir to dx
        mov ah, 9h                      ; call print string interruption
        int 21h
        
        ; wait 1 seconds (1 million microseconds)(1000000 = 0f4240h) 
        mov cx, 0fh 
        mov dx, 04240h
        mov ah, 86h
        int 15h
        
        ; --- START GAME ---
        startgame:
            xor cx, cx                          ; clean cx
            mov cl, 1d                          ; move 1 to cl
            gameloop1:
                
                pusha                           ; store all registers in stack
                movecursor 55d, 12d             ; move cursor to (55, 12)
                lea dx, msgmemoriza             ; get msgmemoriza in dx
                mov ah, 9h                      ; print string interruption
                int 21h
                movecursor 55d, 13d             ; move cursor to (55, 13)
                lea dx, msgpuntaje              ; get score message in dx
                mov ah, 9h                      ; print string interruption
                int 21h
                
                pusha                           ; store all registers in stack
                xor ax, ax                      ; clean ax
                mov al, puntaje                 ; store the score in al
                call print_2digits              ; print the score in 2 digits format
                popa                            ; get all registers from stack
                
                
                movecursor 55d, 14d             ; move cursor to (55, 14)
                lea dx, msgnivel                ; store level message in dx
                mov ah, 9h                      ; print string interruption
                int 21h
                
                mov dl, nivel                   ; move level in dl
                add dl, 48d                     ; add 48 to get the ascii code
                mov ah, 2h                      ; print char interruption
                int 21h
                popa                            ; get all registers from stack
                      
                      
                mov indextrytoguess, 0d         ; reset indextrytoguess 
                mov amounttrytoguess, 0d        ; reset amounttrytoguess 
                mov ch, 0d                      ; reset ch
                xor di, di                      ; reset di
                gameloop2:
                    call check_r_s_keys         ; check if the user pressed r or s key
                    lea bx, random              ; move random list direction in bx
                    mov al, byte ptr [bx + di]  ; store one of the numbers in al
                    call paintcolor             ; paint the color of the list
                    
                    inc di                      ; increment di
                    inc ch                      ; increment ch
                    
                    cmp ch, cl                  ; compare the inner counter with the outer counter
                    jne gameloop2               ; if they're not the same yet, repeat inner loop
                
                call trytoguess                 ; user's turn
                inc cl                          ; increment cl
                inc nivel                       ; increment the level
                cmp cl, 11d                     ; compare the out loop counter with 11
                jne gameloop1                   ; if they're not equals repeat loop 1
        
            call wonscreen                      ; if the outer counter reachs 11, you win
            
    wonscreen:
        paint 0d, 0d, 40d, 12d, 127d    ; paint gray
        paint 41d, 0d, 79d, 12d, 159d   ; paint blue
        paint 0d, 13d, 40d, 24d, 207d   ; paint red
        paint 41d, 13d, 79d, 24d, 175d  ; paint green
        paint 19d, 4d, 60d, 20d, 15d    ; Paint black with white letters
        
        movecursor 32d, 7d              ; move cursor to (32, 7)
        lea dx, msgganaste              ; put the win message in dx
        mov ah, 9h                      ; print string interruption
        int 21h 
        
        call printwonlostmessage        ; print score, level, reload and exit
        
        jmp reloadorexit
        
    lostscreen:
    
        inc vecesperdidas               ; increment vecesperdidas
        
        cmp vecesperdidas, 3d           ; if vecesperdidas is equals to 3, stop the program
        je exit 
        
        
        paint 0d, 0d, 40d, 12d, 127d    ; paint gray
        paint 41d, 0d, 79d, 12d, 159d   ; paint blue
        paint 0d, 13d, 40d, 24d, 207d   ; paint red
        paint 41d, 13d, 79d, 24d, 175d  ; paint green
        paint 19d, 4d, 60d, 20d, 15d    ; Paint black with white letters
        
        
        movecursor 32d, 7d              ; move cursor to (32, 7)
        lea dx, msgperdiste             ; put the lost message in dx
        mov ah, 9h                      ; print string interruption
        int 21h 
        
        call printwonlostmessage        ; print score, level, reload and exit
        
        jmp reloadorexit
         
         
    reloadorexit:
        call check_r_s_keys             ; check if the user pressed r or s key
        jmp reloadorexit        
    
    printwonlostmessage:
        pusha
        movecursor 32d, 10d             ; move cursor to (32,10)
        lea dx, msgpuntaje              ; put the score message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
                
        pusha                           ; store all registers in stack
        xor ax, ax                      ; reset ax
        mov al, puntaje                 ; store the score in al
        call print_2digits              ; print score in 2 digits format
        popa                            ; get all registers from stack
        
        movecursor 32d, 12d             ; move cursor to (32,12)
        lea dx, msgnivel                ; put the level message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
                
        mov dl, nivel                   ; store the level in dl
        add dl, 48d                     ; add 48d to get ascii code
        mov ah, 2h                      ; print char interruption
        int 21h
        
        movecursor 35d, 15d             ; move cursor to (35,15)
        lea dx, msgreiniciar            ; put the restart message in dx
        mov ah, 9h                      ; print string interruption
        int 21h 
        
        movecursor 35d, 17d             ; move cursor to (35,17)
        lea dx, msgsalir                ; put the exit message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
        popa                            ; get all registers from stack
        ret                             ; return

;   -----   -----   -----   User Turn   -----   -----   -----        
    trytoguess:
        pusha                           ; store all registers to stack
        xor di, di                      ; reset di
        xor cx, cx                      ; reset cx
        
        pusha                           ; store all registers to stack
        movecursor 55d, 12d             ; move cursor at (55, 12)
        lea dx, msgtuturno              ; move tuturno message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
        popa                            ; get all registers from stack
        
        again:
        pusha                           ; store all registers to stack
        xor bx, bx                      ; reset bx
        xor cx, cx                      ; reset cx
        xor dx, dx                      ; reset dx
        mov timertolose, 0d             ; reset the timer of the user to lose
        check_button:
            call check_r_s_keys         ; check if the user has pressed r or s key
            inc timertolose             ; increment timer to lose
            cmp timertolose, 55d        ; compare timer to lose with 55, 10 is one second
            je lostscreen               ; if they're equals you lose
            
            mov ax, 3h                  ; check mouse button status
            int 33h
            cmp bl, 1d                  ; compare bl with 1, value of left click
            jne check_button            ; if it's not, check the button again
            mov curX, cx                ; move x position in cx
            mov curY, dx                ; move y position in dx
            
            ; -- cursor check --
            cmp curY, 69h               ; compare y position with 69h
            jl grayorblue               ; if it's less jump to grayorblue 
            jmp redorgreen              ; if it's greater jumpt to redorgreen 
            
            grayorblue:
                cmp curX, 0A8h          ; compare x position with 0A8h
                jl isgray               ; if it's less is gray color
                jmp isblue              ; if it's greater is blue
            
            redorgreen:
                cmp curX, 0A8h          ; compare x position with 0A8h
                jl isred                ; if it's less is red color
                jmp isgreen             ; if it's greater is green
                
            isgray:
                mov colorguess, 0d              ; move 0 to colorguess
                paint 0d, 0d, 20d, 12d, 127d    ; paint light gray
                mov cx, 0Bh                     ; wait 0,76 seconds
                mov dx, 098C0h
                mov ah, 86h
                int 15h
                paint 0d, 0d, 20d, 12d, 143d    ; paint dark gray
                jmp cursorcheckend 
                
            isblue:
                mov colorguess, 3d              ; move 3 to colorguess
                paint 21d, 0d, 42d, 12d, 159d   ; paint light blue
                mov cx, 0Bh                     ; wait 0,76 seconds
                mov dx, 098C0h
                mov ah, 86h
                int 15h
                paint 21d, 0d, 42d, 12d, 31d    ; paint blue
                jmp cursorcheckend
                
            isred:
                mov colorguess, 2d              ; move 2 to colorguess
                paint 0d, 13d, 20d, 24d, 207d   ; paint light red
                mov cx, 0Bh                     ; wait 0,76 seconds
                mov dx, 098C0h
                mov ah, 86h
                int 15h
                paint 0d, 13d, 20d, 24d, 79d    ; paint red  
                jmp cursorcheckend
                
            isgreen:
                mov colorguess, 1d              ; move 1 to colorguess
                paint 21d, 13d, 42d, 24d, 175d  ; paint light green
                mov cx, 0Bh                     ; wait 0,76 seconds
                mov dx, 098C0h
                mov ah, 86h
                int 15h
                paint 21d, 13d, 42d, 24d, 47d   ; paint green
                
            cursorcheckend:
            popa
        
        lea bx, listtrytoguess                  ; move random list to bx
        mov dl, byte ptr [bx + di]              ; move the number/color that you've to guess to dl
        mov dh, colorguess                      ; move the nombre/color that you've selected to dh
        cmp dl, dh                              ; compare if they're equals
        jne lostscreen                          ; if not, jump to lostscreen
        
        inc di                                  ; if they're the same, increment di
        inc cl                                  ; increment cl
        inc puntaje                             ; increment puntaje
        
        movecursor 55d, 13d                     ; move cursor at (55, 13)
        lea dx, msgpuntaje                      ; store score in dx
        mov ah, 9h                              ; print string interruption
        int 21h
                
        pusha                                   ; store all registers in stack
        xor ax, ax                              ; clean ax
        mov al, puntaje                         ; move score in al
        call print_2digits                      ; print the score
        popa                                    ; get all registers from stack
        
        cmp cl, amounttrytoguess                ; compare counter with the amount of colors to guess
        jne again                               ; if they're not equals, click the next color
        
        popa                                    ; get all registers from stack
        ret                                     ; return
    
    check_r_s_keys:
        pusha                                   ; store all registers in stack
        mov dl, 255
        mov ah, 6h                              ; check terminal buffer insterruption
        int 21h
        mov ah, 0d                              ; store 0 in ah
        
        cmp al, 's'                             ; compare al with s, if it's true, exit
        je exit
        
        cmp al, 'r'                             ; compare al with r, if it's true, reload
        jz reload
        popa                                    ; get all registers from stack
        ret                                     ; return
    
    paintcolor:
        pusha                                   ; store all registers in stack
        cmp al, 2d                              ; compare al with 2
        jl paintgrey                            ; if less jump to paintgrey
        cmp al, 5d                              ; compare al with 5
        jl paintgreen                           ; if less jump to paintgreen
        cmp al, 7d                              ; compare al with 7
        jl paintred                             ; if less jump to paintred
        jmp paintblue                           ; if it's not any of these, jump to paintblue
        
        paintgrey:
            paint 0d, 0d, 20d, 12d, 127d        ; paint light gray
            call waitdificult                   ; wait depending on the difficulty
            paint 0d, 0d, 20d, 12d, 143d        ; paint dark gray
            pusha                               ; store all registers in stack
            xor bx, bx                          ; clear bx
            xor cx, cx                          ; clear cx
            lea bx, listtrytoguess              ; move listtrytoguess in bx 
            mov cl, indextrytoguess             ; move indextrytoguess in cl
            mov di, cx                          ; move cx, the index, in di
            mov byte ptr [bx + di], 0           ; add 0 to the list
            inc amounttrytoguess                ; increment amounttrytoguess 
            inc indextrytoguess                 ; increment indextrytoguess
            popa                                ; get all registers from stack
            jmp paintcolorend   
        paintgreen:
            paint 21d, 13d, 42d, 24d, 175d      ; paint light green
            call waitdificult                   ; wait depending on the difficulty
            paint 21d, 13d, 42d, 24d, 47d       ; paint green
            pusha                               ; store all registers in stack
            xor bx, bx                          ; clear bx
            xor cx, cx                          ; clear cx
            lea bx, listtrytoguess              ; move listtrytoguess in bx 
            mov cl, indextrytoguess             ; move indextrytoguess in cl
            mov di, cx                          ; move cx, the index, in di
            mov byte ptr [bx + di], 1           ; add 1 to the list
            inc amounttrytoguess                ; increment amounttrytoguess 
            inc indextrytoguess                 ; increment indextrytoguess
            popa                                ; get all registers from stack
            jmp paintcolorend
        paintred:
            paint 0d, 13d, 20d, 24d, 207d       ; paint light red 
            call waitdificult                   ; wait depending on the difficulty
            paint 0d, 13d, 20d, 24d, 79d        ; paint red
            pusha                               ; store all registers in stack
            xor bx, bx                          ; clear bx
            xor cx, cx                          ; clear cx
            lea bx, listtrytoguess              ; move listtrytoguess in bx 
            mov cl, indextrytoguess             ; move indextrytoguess in cl
            mov di, cx                          ; move cx, the index, in di
            mov byte ptr [bx + di], 2           ; add 2 to the list
            inc amounttrytoguess                ; increment amounttrytoguess 
            inc indextrytoguess                 ; increment indextrytoguess
            popa                                ; get all registers from stack
            jmp paintcolorend
        paintblue:
            paint 21d, 0d, 42d, 12d, 159d       ; paint light blue 
            call waitdificult                   ; wait depending on the difficulty
            paint 21d, 0d, 42d, 12d, 31d        ; paint bule
            pusha                               ; store all registers in stack
            xor bx, bx                          ; clear bx
            xor cx, cx                          ; clear cx
            lea bx, listtrytoguess              ; move listtrytoguess in bx 
            mov cl, indextrytoguess             ; move indextrytoguess in cl
            mov di, cx                          ; move cx, the index, in di
            mov byte ptr [bx + di], 3           ; add 3 to the list
            inc amounttrytoguess                ; increment amounttrytoguess 
            inc indextrytoguess                 ; increment indextrytoguess
            popa                                ; get all registers from stack
        
        paintcolorend: 
        popa                                    ; get all registers from stack
        ret                                     ; return
    
    waitdificult:
        pusha                                   ; store all registers in stack
        
        call checkleveldifficulty               ; check if the difficulty needs to be increased
        
        cmp option, 0d                          ; compare option with 0
        je easy                                 ; jump to easy label
        cmp option, 1d                          ; compare option with 1
        je medium                               ; jump to medium label
        cmp option, 2d                          ; compare option with 2
        je hard                                 ; jump to hard label
        
        easy:
            ; wait 1 seconds (1 million microseconds)(1000000 = 0f4240h) 
            mov cx, 0fh 
            mov dx, 04240h
            mov ah, 86h
            int 15h
            jmp waitdificultend  
        
        medium:
            ; wait 0,75 seconds (0,75 million microseconds)(750000 = 0b71b0h) 
            mov cx, 0bh 
            mov dx, 071b0h
            mov ah, 86h
            int 15h
            jmp waitdificultend 
        
        hard:
            ; wait 0,38 seconds (0,38 million microseconds)(380000 = 05cc60h) 
            mov cx, 05h 
            mov dx, 0cc60h
            mov ah, 86h
            int 15h
            
        waitdificultend:
        popa                                ; get all registers from stack
        ret                                 ; return
    
    checkleveldifficulty:
        pusha                               ; store all registers to stack
        cmp nivel, 6d                       ; compare current level with 6d
        jg setoptionto2                     ; if it's greater, jump to setoptionto2
        cmp nivel, 3d                       ; compare current level with 3d
        jg setoptionto1                     ; if it's greater, jump to setoptionto1
        jmp exitcheckleveldifficulty        ; if it's less than 3, exit
        setoptionto2:
            mov option, 2d                  ; mov set difficulty to hard
            jmp exitcheckleveldifficulty    ; exit
        setoptionto1:
            mov option, 1d                  ; set difficulty to medium
        exitcheckleveldifficulty:
        popa                                ; get all data from stack
        ret                                 ; return
    
    reload:
        mov nivel, 0d                       ; reset nivel
        mov puntaje, 0d                     ; reset puntaje
        mov indextrytoguess, 0d             ; reset indextrytoguess
        mov amounttrytoguess, 0d            ; reset amounttrytoguess
        mov seedcounter, 20d                ; set seedcounter to 20
        jmp reloadpoint                     ; restart program
    
    print_2digits:
        pusha                               ; store all registers to stack
        aam                                 ; separate last digit from the rest
        mov bl, al                          ; store right digits in bl
        mov dl, ah                          ; store left digits in dl
        add dl, 48d                         ; add 48d to get the ascii code
        mov ah, 2h                          ; print char interruption
        int 21h
        mov dl, bl                          ; store right digits in dl
        add dl, 48d                         ; add 48d to get the ascii code
        mov ah, 2h                          ; print char interruption
        int 21h
        popa                                ; get all registers from stack
        ret                                 ; return
    
    putc:
        pusha                               ; store all registers to stack
        mov ah, 2h                          ; print char interruption
        int 21h
        popa                                ; get all registers from stack
        ret                                 ; return
    
    ;return control to the os (stop program)
    exit:
        paint 0d, 0d, 40d, 12d, 127d    ; paint gray
        paint 41d, 0d, 79d, 12d, 159d   ; paint blue
        paint 0d, 13d, 40d, 24d, 207d   ; paint red
        paint 41d, 13d, 79d, 24d, 175d  ; paint green
        paint 19d, 4d, 60d, 20d, 15d    ; Paint black with white letters
        
        movecursor 32d, 5d              ; move cursor to (32,5)    
        lea dx, msggraciasporjugar      ; get msggraciasporjugar message in dx 
        mov ah, 9h                      ; print string interruption
        int 21h
        
        movecursor 32d, 7d              ; move cursor to (32,7)
        lea dx, msgpuntaje              ; get msggpuntaje message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
        
        pusha                           ; store all register in stack
        xor ax, ax                      ; clean ax
        mov al, puntaje                 ; store the user score in al
        call print_2digits              ; prints it
        popa                            ; get all register from stack
        
        movecursor 32d, 9d              ; move cursor to (32,9)
        lea dx, msgnivel                ; get msgnivel message in dx
        mov ah, 9h                      ; print string interruption
        int 21h
        
        pusha                           ; store all register in stack
        xor ax, ax                      ; clean ax
        mov al, nivel                   ; store the highest level in al
        call print_2digits              ; prints it
        popa                            ; get all register from stack
        
        ; wait 3 seconds (3 million microseconds)(3000000 = 2dC6C0h) 
        mov cx, 02dh 
        mov dx, 0C6C0h
        mov ah, 86h
        int 15h
                           
        mov ax, 4c00h                   ;store os return control interruption in AH
        int 21h                         ;wait/do it                         
        
    
    
;   ######    ################    ######    RandomNumberGeneratorSector     ######   ################    ###### 
   
    generaterandomnumber:         
        ; ----------------- Generate Random Number -----------------
        ;seed
        ;suma
        ;multiplier
        ;modulo
        ;RandomNumber = (seed*multiplier + suma) % modulo   
        
        pusha                           ; store all registers in stack        
        
        xor ax, ax                      ; clean ax
        xor bx, bx                      ; clean bx
        xor cx, cx                      ; clean cx
        xor dx, dx                      ; clean dx
        xor di, di                      ; clean di
        
        mov bx, offset seed             ; store seed list in bx
        mov dx, offset multiplier       ; store multiplier list in dx
        loop3:
            mov al, [bx + di]           ; get a number from seed list
            
            push bx                     ; save bx in stack
            push dx                     ; save dx in stack
            mov bx, dx                  ; move multiplier list to bx
            xor dx, dx                  ; clean dx
            mov dl, [bx + di]           ; get a number from multiplier list
            mul dl                      ; multiply the seed number with the multiplier number
            pop dx                      ; get dx from stack
            pop bx                      ; get bx from stack
            
            push dx                     ; save dx in stack
            mov dl, 11d                 ; store 11 in dl to add
            mov dh, 17d                 ; store 17 in dh to get the remainder
            add al, dl                  ; realize the add with 11
            div dh                      ; divide the result with 17, remainder in ah
            pop dx                      ; get dx from stack
            
            ; resto en ah               
            cmp ah, 10d                 ; compare random number with 10
            jge makeonedigit            ; if is greater or equal, makes it into 1 digit number
            returnmakeonedigit:
            
            pusha                       ; store all registers in stack
            mov di, cx                  ; store the number of iteration in di
            mov bx, offset random       ; move random list in bx
            mov byte ptr [bx + di], ah  ; add the new random number to the list
            popa                        ; get all registers from stack
            
            inc di                      ; increment di
            inc cl                      ; inc cl, the counter
            cmp cl, 10d                 ; compare the counter with 10
            jne loop3                   ; if they're not equals, next iteration
        popa                            ; get all registers from stack
        ret                             ; return
        
        
        makeonedigit:
            shr ah, 1                   ; move the binary number one to right(0100 -> 0010)
            jmp returnmakeonedigit
            
    
;   -----   -----   ----- Get seeds number sector
    getseeds:
        pusha
        xor di, di                      ; clean di
        seedstart:
        mov ah, 2Ch                     ; get OS current time interruption             
        int 21h
    
        ; DH = second
        ; DL = mili second
        
        cmp dh, dl                      ; verify if second is greater than milisecond
        jle seedstart                   ; To avoid errors with div zero
        cmp dl, 0d                      ; verify if milisecon is zero
        je seedstart                    
        cmp dh, 0d                      ; verify if second is zero
        je seedstart                    
        
        xor ax, ax                      ; cleans ax
        
        mov al, dh                      ; move second to al
        div dl                          ; divide second with milisecond
        
        mov dh, al                      ; move result to dh
        xor ax, ax                      ; cleans ax
        mov al, dh                      ; move result to al
              
        ; vefify if the number is one of the cases to get a 1 digit number      
        cmp al, 100d
        jg ifgreater100                 ; compare if the number is greater than 100
        cmp al, 100d
        je if100                        ; compare if the number is equals to 100
        labelgreater100: 
        
        cmp al, 10d                     ; compare if the number is greater than 10
        jg ifgreater10
        cmp al, 10d                     ; compare if the number is equals to 10
        je if10
        labelgreater10:
        
        
        pusha                           ; store all registers in stack
        mov bx, offset listnotrandomseed; store listnotrandomseed in bx 
        mov [bx + di], al               ; add the new number to the list
        popa                            ; get all registers from stack
        
        inc di                          ; increase di
        dec seedcounter                 ; decrease seedcounter
        
        cmp seedcounter, 0d             ; verify if seedcounter is not 0
        jne seedstart
        popa                            ; get all registers from stack
        ret                             ; return
    
    ifgreater100:
        mov dl, 100d                    ; store 100 in dl
        div dl                          ; divide al with 100
        jmp labelgreater100             ; jump to labelgreater100 
    
    if100:
        mov dl, 97d                     ; store 97 in dl
        sub al, dl                      ; substract 97 from 100
        jmp labelgreater10              ; jump to labelgreater100 
    
    ifgreater10:
        mov dl, 10d                     ; store 10 in dl
        div dl                          ; divide al with 10
        jmp labelgreater10              ; jump to labelgreater10
        
    if10:
        mov dl, 3d                      ; store 3 in dl
        sub al, dl                      ; substract 3 from 10
        jmp labelgreater10              ; jump to labelgreater10
        
    
    
;   -----   -----   ----- Divide an array by 2
    dividearray:
        pusha
        ; divide an array by 2
        xor ax, ax                          ; clean ax
        xor bx, bx                          ; clean bx 
        xor cx, cx                          ; clean cx 
        xor dx, dx                          ; clean dx
        xor di, di                          ; clean di
        
        mov bx, offset listnotrandomseed    ; get listnotrandomseed in bx
        loop1:
            mov al, [bx + di]               ; store number from list in al
            mov dl, al                      ; copy the number in dl
            
            pusha                           ; store all registers in stack
            mov di, cx                      ; move the iteration counter number in do to use it as index
            mov bx, offset seed             ; store seed list in bx
            mov byte ptr [bx + di], dl      ; add the number in the seed list
            popa                            ; get all registers from stack
            
            inc di                          ; increment di
            inc cl                          ; increment cl
            cmp cl, 10d                     ; jump to loop1 if is not equals to 10
            jne loop1
             
        mov cl, 0d                          ; mov 0 to cl
        loop2:
            mov al, [bx + di]               ; store number from list in al
            mov dl, al                      ; copy the number in dl
            
            pusha                           ; store all registers in stack
            mov di, cx                      ; move the iteration counter number in do to use it as index
            mov bx, offset multiplier       ; store multiplier list in bx
            mov byte ptr [bx + di], dl      ; add the number in the multiplier list
            popa                            ; get all registers from stack
            
            inc di                          ; increment di
            inc cl                          ; increment cl
            
            cmp cl, 10d                     ; jump to loop2 if is not equals to 10
            jne loop2
        popa                                ; get all registers from stack
        ret                                 ; return
        
    ;>>>>>>>>>> END METHODS <<<<<<<<<<
    
end start