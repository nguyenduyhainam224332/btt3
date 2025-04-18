.MODEL SMALL
.STACK 100h

.DATA
    MSG1   DB 13, 10, 'NHAP VAO CHUOI: $'       ; Thông báo nhập chuỗi
    MSG2   DB 13, 10, 'CHUOI DAU RA: $'  ; Thông báo hiển thị chuỗi sau khi nhập
    MSG3   DB 13, 10, 'SAP XEP VA NEU RA TAN SO XUAT HIEN CUA KI TU TRONG MA ASCII: $' ; Thông báo hiển thị chuỗi đã sắp xếp và tần suất của ký tự
    buffer DB 100, ?, 100 DUP(' ')    ; Bộ đệm chứa chuỗi nhập vào
    newline DB 13,10,"$"   ; Ký tự xuống dòng
    sorted_str DB 100 DUP('$')   ; Mảng chứa chuỗi đã sắp xếp
    freq_table DB 128 DUP(0)  ; Mảng lưu trữ tần suất của các ký tự
    dash DB "-$"     ; Dấu "–" để hiển thị giữa ký tự và tần suất
    comma DB ", $"   ; Dấu "," để phân cách giữa các vị trí
    stat_format DB " -- $"  ; Định dạng cho tần suất
    slash DB "/$"   ; Dấu "/" cho định dạng

    
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL NHAP   
    CALL XUAT
    CALL TANXUAT 
    CALL SAPXEP
    CALL SAPXEP2

    MOV AH, 4CH
    INT 21H
MAIN ENDP

NHAP PROC    ;Nhập chuỗi từ người dùng và lưu vào buffer. Sau đó lấy độ dài của chuỗi.
    MOV AH, 09H
    LEA DX, msg1
    INT 21H
    
    MOV AH, 0AH
    LEA DX, buffer
    INT 21H
    
    XOR BX, BX
    MOV BL, [buffer + 1]
    RET
NHAP ENDP

XUAT PROC    ;Hiển thị chuỗi vừa nhập ra màn hình.
    MOV AH, 09H
    LEA DX, msg2
    INT 21H

    MOV AH, 09H
    LEA DX, buffer + 2
    INT 21H
    
    MOV AH, 09H
    LEA DX, newline
    INT 21H
    RET
XUAT ENDP

TANXUAT PROC    ;Tính toán tần suất của các ký tự trong chuỗi và hiển thị tần suất của từng ký tự.
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    

    LEA DI, freq_table
    MOV CX, 128
    XOR AL, AL
    REP STOSB

    LEA SI, buffer + 2
COUNT_LOOP:
    MOV AL, [SI]
    CMP AL, 0DH
    JE COUNT_DONE
    
    XOR AH, AH
    LEA DI, freq_table
    ADD DI, AX
    INC BYTE PTR [DI]
    INC SI
    JMP COUNT_LOOP

COUNT_DONE:
    MOV CX, 0
SHOW_STAT:
    LEA DI, freq_table
    ADD DI, CX
    CMP BYTE PTR [DI], 0
    JE NEXT_CHAR
    
    MOV AH, 02H
    MOV DL, CL
    INT 21H
    
    MOV AH, 09H
    LEA DX, stat_format
    INT 21H
    
    XOR AH, AH
    MOV AL, [DI]
    CALL InGiaTri
    
    MOV AH, 09H
    LEA DX, slash
    INT 21H
    
    MOV AX, BX
    CALL InGiaTri
    
    MOV AH, 09H
    LEA DX, stat_format
    INT 21H
    
    PUSH CX
    LEA SI, buffer + 2
    MOV DI, 1
FIND_POS:
    MOV AL, [SI]
    CMP AL, 0DH
    JE POS_DONE
    
    CMP AL, CL
    JNE NEXT_POS
    
    MOV AX, DI
    CALL InGiaTri
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TANXUAT ENDP

SAPXEP PROC    ;Sắp xếp chuỗi theo thứ tự ASCII.
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SAPXEP ENDP

SAPXEP2 PROC            ;In chuỗi đã sắp xếp với tần suất xuất hiện của mỗi ký tự kèm theo dấu - giữa ký tự và tần suất.
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    
    MOV AH, 09H
    LEA DX, MSG3
    INT 21H

    
    MOV CX, 0           
    XOR BX, BX          
SHOW_FREQ_LOOP:
    LEA DI, freq_table
    ADD DI, CX
    CMP BYTE PTR [DI], 0
    JE NEXT_FREQ_CHAR   
    CMP BX, 0
    JE SKIP_DASH
    MOV AH, 09H
    LEA DX, dash
    INT 21H
SKIP_DASH:
    INC BX              
    MOV AH, 02H
    MOV DL, CL
    INT 21H
    XOR AH, AH
    MOV AL, [DI]
    CALL InGiaTri

NEXT_FREQ_CHAR:
    INC CX
    CMP CX, 128
    JL SHOW_FREQ_LOOP
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
SAPXEP2 ENDP

InGiaTri PROC        ;In số lần xuất hiện của ký tự hoặc tần suất vào màn hình.
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
