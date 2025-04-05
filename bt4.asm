.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'
    MSG3   DB 13, 10, 'SAP XEP CHUOI THEO THU TU MA ASCII: $'
    buffer DB 100, ?, 100 DUP(' ')    
    newline DB 13,10,"$" 
    sorted_str DB 100 DUP('$')
.CODE
MAIN Proc
    ; LAY SEGMENT DATA VAO DS
    MOV AX, @DATA
    MOV DS, AX
    CALL NHAP   
    CALL XUAT 
    CALL SAPXEP
    ; KET THUC CHUONG TRINH
    MOV AH, 4Ch
    INT 21h  
    
MAIN ENDP

NHAP PROC
    MOV AH, 09H
    LEA DX, MSG1
    INT 21H
    
    MOV AH, 0AH
    LEA DX, buffer
    INT 21H
    
    XOR BX, BX
    MOV BL, [buffer + 1]
    RET
NHAP ENDP

XUAT PROC
    MOV AH, 09H
    LEA DX, MSG2
    INT 21H

    MOV AH, 09H
    LEA DX, buffer + 2
    INT 21H
    
    MOV AH, 09H
    LEA DX, newline
    INT 21H
    RET
XUAT ENDP

SAPXEP PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    
    LEA DI, sorted_str
    MOV CX, 50
    MOV AL, '$'
    REP STOSB

    
    LEA SI, buffer + 2
    LEA DI, sorted_str
    XOR CX, CX
COPY_LOOP:
    MOV AL, [SI]
    CMP AL, 0DH              
    JE COPY_DONE
    CMP AL, ' '              
    JE SKIP_CHAR             
    MOV [DI], AL
    INC DI
    INC CX
SKIP_CHAR:
    INC SI
    JMP COPY_LOOP
COPY_DONE:
    CMP CX, 1
    JLE SORT_DONE
    DEC CX
OUTER_LOOP:
    LEA SI, sorted_str
    MOV DX, CX
INNER_LOOP:
    MOV AL, [SI]
    MOV BL, [SI+1]
    CMP AL, BL
    JLE NO_SWAP
    MOV [SI], BL
    MOV [SI+1], AL
NO_SWAP:
    INC SI
    DEC DX
    JNZ INNER_LOOP
    LOOP OUTER_LOOP
SORT_DONE:
    MOV AH, 09H
    LEA DX, MSG3
    INT 21H
    
    MOV AH, 09H
    LEA DX, sorted_str
    INT 21H
    
    MOV AH, 09H
    LEA DX, newline
    INT 21H

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SAPXEP ENDP

ENDP MAIN