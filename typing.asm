org 100h

jmp start

; =========================
; Messages
; =========================

titleMsg db 13,10,'===== DYNAMIC TYPING ACCURACY ANALYZER =====$'

menuMsg db 13,10,13,10,'Choose a sentence level:',13,10
        db '1. Easy',13,10
        db '2. Medium',13,10
        db '3. Hard',13,10
        db 'Enter choice: $'

invalidMsg db 13,10,'Invalid choice. Easy sentence selected.$'

showMsg db 13,10,13,10,'Type this sentence:',13,10,'$'
inputMsg db 13,10,13,10,'Now retype the sentence and press Enter:',13,10,'$'

resultTitle db 13,10,13,10,'===== RESULT =====$'

expectedMsg db 13,10,'Expected Characters: $'
typedMsg    db 13,10,'Typed Characters: $'
correctMsg  db 13,10,'Correct Characters: $'
mistakeMsg  db 13,10,'Mistakes: $'

perfectMsg db 13,10,'Final Result: Perfect Typing $'
goodMsg    db 13,10,'Final Result: Good Typing $'
poorMsg    db 13,10,'Final Result: Needs Practice $'

; =========================
; Sentences
; =========================

s1 db 'ASSEMBLY IS EASY'
s1Len equ $-s1
db '$'

s2 db 'COMPUTER ORGANIZATION IS IMPORTANT'
s2Len equ $-s2
db '$'

s3 db 'PRACTICE MAKES A PROGRAMMER BETTER'
s3Len equ $-s3
db '$'

; =========================
; Variables
; =========================

targetPtr dw 0
targetLen db 0
maxLen    db 0

correct  db 0
mistakes db 0

; DOS buffered input format:
; first byte  = maximum characters
; second byte = actual typed length
; remaining bytes = typed characters

inputBuffer db 80,0
times 80 db 0

; =========================
; Program Start
; =========================

start:

; display title
mov dx, titleMsg
mov ah, 09h
int 21h

; display menu
mov dx, menuMsg
mov ah, 09h
int 21h

; take menu choice
mov ah, 01h
int 21h

cmp al, '1'
je selectEasy

cmp al, '2'
je selectMedium

cmp al, '3'
je selectHard

jmp invalidChoice


; =========================
; Sentence Selection
; =========================

selectEasy:
mov ax, s1
mov [targetPtr], ax
mov byte [targetLen], s1Len
jmp afterSelection

selectMedium:
mov ax, s2
mov [targetPtr], ax
mov byte [targetLen], s2Len
jmp afterSelection

selectHard:
mov ax, s3
mov [targetPtr], ax
mov byte [targetLen], s3Len
jmp afterSelection

invalidChoice:
mov dx, invalidMsg
mov ah, 09h
int 21h

mov ax, s1
mov [targetPtr], ax
mov byte [targetLen], s1Len


afterSelection:

; show selected sentence message
mov dx, showMsg
mov ah, 09h
int 21h

; display selected sentence
mov dx, [targetPtr]
mov ah, 09h
int 21h

; ask user to retype
mov dx, inputMsg
mov ah, 09h
int 21h

; take full sentence input using DOS buffered input
mov byte [inputBuffer + 1], 0
mov dx, inputBuffer
mov ah, 0Ch
mov al, 0Ah
int 21h


; =========================
; Reset Counters
; =========================

mov byte [correct], 0
mov byte [mistakes], 0


; =========================
; Find Maximum Length
; =========================

mov al, [targetLen]
mov bl, [inputBuffer + 1]

cmp al, bl
ja targetIsLonger

mov [maxLen], bl
jmp startCompare

targetIsLonger:
mov [maxLen], al


; =========================
; Compare Sentences
; =========================

startCompare:

mov si, 0
mov cl, [maxLen]
mov ch, 0

cmp cx, 0
je showResult


compareLoop:

; check if current index is outside target sentence
mov al, [targetLen]
mov ah, 0
cmp si, ax
jae countMistake

; check if current index is outside typed sentence
mov al, [inputBuffer + 1]
mov ah, 0
cmp si, ax
jae countMistake

; compare target character with typed character
mov bx, [targetPtr]
mov al, [bx + si]

mov dl, [inputBuffer + 2 + si]

cmp al, dl
je countCorrect


countMistake:
mov al, [mistakes]
inc al
mov [mistakes], al
jmp nextChar


countCorrect:
mov al, [correct]
inc al
mov [correct], al


nextChar:
inc si
loop compareLoop


; =========================
; Show Result
; =========================

showResult:

mov dx, resultTitle
mov ah, 09h
int 21h

; expected characters
mov dx, expectedMsg
mov ah, 09h
int 21h

mov al, [targetLen]
call printNumber

; typed characters
mov dx, typedMsg
mov ah, 09h
int 21h

mov al, [inputBuffer + 1]
call printNumber

; correct characters
mov dx, correctMsg
mov ah, 09h
int 21h

mov al, [correct]
call printNumber

; mistakes
mov dx, mistakeMsg
mov ah, 09h
int 21h

mov al, [mistakes]
call printNumber


; =========================
; Final Result Decision
; =========================

cmp byte [mistakes], 0
je perfectResult

cmp byte [mistakes], 3
jbe goodResult

jmp poorResult


perfectResult:
mov dx, perfectMsg
mov ah, 09h
int 21h
jmp endProgram


goodResult:
mov dx, goodMsg
mov ah, 09h
int 21h
jmp endProgram


poorResult:
mov dx, poorMsg
mov ah, 09h
int 21h


; =========================
; End Program
; =========================

endProgram:
mov ah, 4Ch
int 21h


; =========================
; Procedure: Print Number
; Prints numbers from 0 to 99
; =========================

printNumber:

push ax
push bx
push cx
push dx

mov ah, 0
mov bl, 10
div bl

mov cl, ah

cmp al, 0
je printSingleDigit

mov dl, al
add dl, 48
mov ah, 02h
int 21h

printSingleDigit:

mov dl, cl
add dl, 48
mov ah, 02h
int 21h

pop dx
pop cx
pop bx
pop ax

ret