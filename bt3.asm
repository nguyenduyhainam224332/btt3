.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'
    MSG3   DB 13, 10, 'TAN SUAT XUAT HIEN TRONG CHUOI: $'
    buffer DB 100, ?, 100 DUP(' ')  
    freq_table DB 128 DUP(0)  
    stat_format DB " -- $"
    slash DB "/$"
    comma DB ", $"  
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
    CALL Frequency

    ; KET THUC CHUONG TRINH
    MOV AH, 4Ch
    INT 21h  
    
MAIN ENDP
NHAP Proc    ;Hàm nhập 
    MOV DX, OFFSET buffer
    MOV AH, 0Ah
    INT 21h
    RET
NHAP ENDP

XUAT PROC    ;Hàm xuất
    XOR BX, BX
    MOV BL, buffer[1]            
    MOV buffer[BX+2], '$'        

    MOV DX, OFFSET buffer + 2   
    MOV AH, 9
    INT 21h
    RET
XUAT ENDP  

Frequency PROC
    PUSH AX     ; lưu trạng thái các thanh ghi vào trong ngăn xếp
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    
    LEA DI, freq_table
       MOV CX, 128        ; Duyệt qua tất cả 128 ký tự ASCII
    XOR AL, AL         ; Khởi tạo AL = 0 (số lần xuất hiện ban đầu của các ký tự)
    REP STOSB          ; Lặp qua mảng freq_table để khởi tạo tất cả giá trị bằng 0  

    
    LEA SI, buffer + 2  
COUNT_LOOP:
    MOV AL, [SI]       ; Lấy ký tự trong chuỗi
    CMP AL, 0DH        ; Kiểm tra xem có phải ký tự kết thúc chuỗi không (0Dh là mã ASCII của dấu xuống dòng)
    JE COUNT_DONE      ; Nếu là ký tự kết thúc chuỗi, thoát vòng lặp
    
    CMP AL, ' '        ; So sánh kí tự với khoảng trắng, nếu kí tự là khoảng trắng, bỏ qua nó
    JE NEXT_CHAR       
    
    CMP AL, '$'        ; So sánh kí tự với $, nếu kí tự là $, bỏ qua nó
    JE NEXT_CHAR
    
    XOR AH, AH         ; Xóa giá trị AH
    LEA DI, freq_table
    ADD DI, AX         ; Di chuyển đến vị trí của ký tự trong mảng `freq_table` (mỗi chỉ số là một ký tự ASCII)
    INC BYTE PTR [DI]  ; Tăng tần suất xuất hiện của ký tự này
    INC SI
    JMP COUNT_LOOP
COUNT_DONE:
    ; Đặt lại chỉ số ASCII để bắt đầu hiển thị thống kê
    MOV CX, 0           
SHOW_STAT:
    LEA DI, freq_table
    ADD DI, CX             ; Di chuyển đến vị trí trong mảng freq_table tương ứng với ký tự có mã ASCII = CX
    CMP BYTE PTR [DI], 0   ; Nếu tần suất là 0, bỏ qua ký tự này
    JE NEXT_CHAR        

    MOV AH, 02H
    MOV DL, CL             ; In ký tự ra màn hình
    INT 21H

    MOV AH, 09H
    LEA DX, stat_format
    INT 21H

    XOR AH, AH
    MOV AL, [DI]
    CALL PrintNumber

    MOV AH, 09H
    LEA DX, slash
    INT 21H

    MOV AX, BX
    CALL PrintNumber   

    MOV AH, 09H
    LEA DX, stat_format
    INT 21H


    PUSH CX
    LEA SI, buffer + 2      ; Duyệt qua chuỗi để in vị trí các ký tự
    MOV DI, 1           
FIND_POS:
    MOV AL, [SI]
    CMP AL, 0DH
    JE POS_DONE         

    CMP AL, CL
    JNE NEXT_POS        

    MOV AX, DI
    CALL PrintNumber
    MOV AH, 09H
    LEA DX, comma
    INT 21H

NEXT_POS:
    INC SI
    INC DI
    JMP FIND_POS

POS_DONE:
    MOV AH, 09H
    LEA DX, newline
    INT 21H
    POP CX

NEXT_CHAR:
    INC CX
    CMP CX, 128
    JL SHOW_STAT        

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Frequency ENDP


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
