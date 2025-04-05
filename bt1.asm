.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'

    buffer DB 100, ?, 100 DUP(' ')    

.CODE
MAIN Proc
    ; LAY SEGMENT DATA VAO DS
    MOV AX, @DATA
    MOV DS, AX

    ; HIEN THONG BAO "NHAP VAO CHUOI:"
    MOV AH, 9
    LEA DX, MSG1
    INT 21h

    ; G?I CHUONG TRÌNH CON NHAP
    CALL NHAP

    ; HIEN THONG BAO "CHUOI DAU RA:"
    MOV AH, 9
    LEA DX, MSG2
    INT 21h

    ; G?I CHUONG TRÌNH CON XUAT
    CALL XUAT

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

END MAIN

