.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'
    MSG3   DB 13, 10, 'SO CHU SO TRONG CHUOI: $'
    buffer DB 100, ?, 100 DUP(' ')    
    MSG4   DB " VI TRI: $"
    MSG5   DB "$"   
    newline DB 13,10,"$"
.CODE
MAIN Proc
    ; LAY SEGMENT DATA VAO DS
    MOV AX, @DATA
    MOV DS, AX

    ; HIEN THONG BAO "NHAP VAO CHUOI:"
    MOV AH, 9
    LEA DX, MSG1
    INT 21h

    
    CALL NHAP

    ; HIEN THONG BAO "CHUOI DAU RA:"
    MOV AH, 9
    LEA DX, MSG2
    INT 21h

  
    CALL XUAT
    ; HIEN THONG BAO "SO CHU SO TRONG CHUOI:"
    MOV AH, 9
    LEA DX, MSG3
    INT 21h
    
    
    CALL PHANBIET
    ; KET THUC CHUONG TRINH
    MOV AH, 4Ch
    INT 21h  
    
MAIN ENDP


NHAP Proc
    MOV DX, OFFSET buffer
    MOV AH, 0Ah
    INT 21h
    RET
NHAP ENDP

XUAT PROC
    XOR BX, BX
    MOV BL, buffer[1]            
    MOV buffer[BX+2], '$'        

    MOV DX, OFFSET buffer + 2   
    MOV AH, 9
    INT 21h
    RET
XUAT ENDP  

PHANBIET PROC
    
    
    LEA SI, buffer + 2  
    MOV CX, 1           

SCAN_LOOP:
    MOV AL, [SI]        
    CMP AL, 0DH         
    JE DONE              
    
    CMP AL, '0'         
    JL NEXT              
    CMP AL, '9'         
    JG NEXT              

    CALL XuatGiaTri       
    PUSH CX
    CALL XuatViTri   
    POP CX

NEXT:
    INC CX               
    INC SI               
    JMP SCAN_LOOP        

DONE:
    RET
PHANBIET ENDP

XuatGiaTri PROC
    MOV AH, 02H
    MOV DL, AL
    INT 21H
    RET
XuatGiaTri ENDP

XuatViTri PROC
    MOV AH, 09H
    LEA DX, MSG4  
    INT 21H
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AX, CX    
    CALL PrintNumber
    POP DX
    POP CX
    POP BX
    POP AX
    
    MOV AH, 09H
    LEA DX, MSG5  
    INT 21H
    
    MOV AH, 09H
    LEA DX, newline
    INT 21H
    RET
XuatViTri ENDP

PrintNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    MOV CX, 0

PrintNumberLoop:
    MOV DX, 0
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ PrintNumberLoop

PrintDigits:
    POP DX
    MOV AH, 02H
    INT 21H
    LOOP PrintDigits

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintNumber ENDP

END MAIN

