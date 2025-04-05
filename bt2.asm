.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'
    MSG3   DB 13, 10, 'SO CHU SO TRONG CHUOI: $'
    buffer DB 100, ?, 100 DUP(' ')    
    MSG4   DB " VI TRI: $"
    MSG5   DB "$"   
    newline DB 13,10,"$"           ; Khai báo biến newline, khi xác định hết 1 kí tự sẽ chèn thêm $ vào cuối
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

PHANBIET PROC ; Chương trình phân biệt giữa số và chữ cái
    LEA SI, buffer + 2  ; SI trỏ đến vị trí bắt đầu chuỗi nhập
    MOV CX, 1           ; CX dùng để duyệt qua từng ký tự trong chuỗi          

SCAN_LOOP:
    MOV AL, [SI]        ; Lấy ký tự từ chuỗi
    CMP AL, 0DH         ; So sánh với ký tự xuống dòng (kết thúc chuỗi)
    JE DONE              ; Nếu gặp ký tự xuống dòng thì kết thúc
    
    CMP AL, '0'         ; Kiểm tra nếu là chữ số
    JL NEXT              ; Nếu nhỏ hơn '0', không phải chữ số, bỏ qua
    CMP AL, '9'         ; Kiểm tra nếu là chữ số (<= '9')
    JG NEXT              ; Nếu lớn hơn '9', không phải chữ số, bỏ qua  

    CALL XuatGiaTri       ; Nếu là chữ số, in ra ký tự
    PUSH CX
    CALL XuatViTri       ; In vị trí của ký tự
    POP CX

NEXT:
    INC CX               ; Tăng chỉ số ký tự
    INC SI               ; Di chuyển đến ký tự tiếp theo
    JMP SCAN_LOOP        ; Lặp lại
DONE:
    RET
PHANBIET ENDP

XuatGiaTri PROC          ; Hàm xuất giá trị
    MOV AH, 02H
    MOV DL, AL
    INT 21H
    RET
XuatGiaTri ENDP

XuatViTri PROC            ; Hàm chỉ ra vị trí của kí tự trong chuỗi
    MOV AH, 09H
    LEA DX, MSG4  
    INT 21H
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AX, CX    
    CALL InGiaTri
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

InGiaTri PROC        ; Hàm in ra các số
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    MOV CX, 0

InSoLanLap:
    MOV DX, 0
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ InSoLanLap

InSo:
    POP DX
    MOV AH, 02H
    INT 21H
    LOOP InSo

    POP DX
    POP CX
    POP BX
    POP AX
    RET
InGiaTri ENDP

END MAIN

