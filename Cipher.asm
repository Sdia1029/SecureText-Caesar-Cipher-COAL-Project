; ============================================================
;  CipherASM - Caesar Cipher Tool ADVANCED
;  NASM 0.98.38 | DOSBox | 16-bit COM file
; ============================================================

[BITS 16]
[ORG 0x100]

    jmp  start

; ============================================================
; DATA SECTION
; ============================================================

banner1     db 13,10,"$"
banner2     db "  +====================================+",13,10,"$"
banner3     db "  |   CipherASM - Caesar Cipher        |",13,10,"$"
banner4     db "  |   NASM Assembly  |  COAL Project   |",13,10,"$"
banner5     db "  +====================================+",13,10,"$"

menu_msg    db 13,10,"$"
menu1       db "  [1] Encrypt Text",13,10,"$"
menu2       db "  [2] Decrypt Text",13,10,"$"
menu3       db "  [3] Brute Force (All 25 Keys)",13,10,"$"
menu4       db "  [4] Step-by-Step Encrypt",13,10,"$"
menu5       db "  [5] Statistics of Text",13,10,"$"
menu6       db "  [6] Exit",13,10,13,10,"$"
choice_msg  db "  Choice (1-6): $"

enter_text  db 13,10,"  Enter text (max 50 chars): $"
enter_key   db 13,10,"  Shift key (1-25): $"

lbl_orig    db 13,10,"  [ORIGINAL ] : $"
lbl_enc     db 13,10,"  [ENCRYPTED] : $"
lbl_dec     db 13,10,"  [DECRYPTED] : $"

brute_hdr   db 13,10,"  [BRUTE FORCE - All 25 Keys]",13,10
            db "  ----------------------------",13,10,"$"
key_lbl     db "  Key $"
colon_lbl   db " : $"
pause_msg   db 13,10,"  -- Press any key for more --",13,10,"$"

; Step by step
step_hdr    db 13,10,"  [STEP BY STEP ENCRYPTION]",13,10
            db "  --------------------------",13,10,"$"
step_char   db "  Char '$"
step_arr    db "' + shift = '$"
step_end    db "'",13,10,"$"
step_res    db 13,10,"  Final Result : $"

; Statistics
stat_hdr    db 13,10,"  [TEXT STATISTICS]",13,10
            db "  ------------------",13,10,"$"
stat_total  db "  Total Chars  : $"
stat_upper  db "  Uppercase    : $"
stat_lower  db "  Lowercase    : $"
stat_space  db "  Spaces       : $"
stat_other  db "  Others       : $"

; Messages
again_msg   db 13,10,"  Run again? (Y/N): $"
again_err   db "  [!] Press Y or N only!",13,10,"$"
bye_msg     db 13,10,"  Goodbye! Thank you :)",13,10,"$"
err_choice  db 13,10,"  [!] Enter 1-6 only!",13,10,"$"
err_key     db 13,10,"  [!] Key must be 1-25! Try again.",13,10,"$"
err_empty   db 13,10,"  [!] Empty input! Try again.",13,10,"$"
newline_s   db 13,10,"$"
space_s     db " $"

; Variables
input_buf   db 51, 0
            times 52 db 0
work_buf    times 54 db 0
shift_key   db 0
str_len     db 0
brute_ctr   db 0
pause_ctr   db 0

; stat counters
cnt_upper   db 0
cnt_lower   db 0
cnt_space   db 0
cnt_other   db 0

; ============================================================
; START
; ============================================================
start:
    mov  ax, cs
    mov  ds, ax
    mov  es, ax
    call print_banner

main_loop:
    call print_menu
    call read_char
    call print_nl

    cmp  al, '1'
    jne  ml2
    call do_encrypt
    jmp  ask_again
ml2:
    cmp  al, '2'
    jne  ml3
    call do_decrypt
    jmp  ask_again
ml3:
    cmp  al, '3'
    jne  ml4
    call do_brute
    jmp  ask_again
ml4:
    cmp  al, '4'
    jne  ml5
    call do_stepbystep
    jmp  ask_again
ml5:
    cmp  al, '5'
    jne  ml6
    call do_stats
    jmp  ask_again
ml6:
    cmp  al, '6'
    je   do_exit
    mov  dx, err_choice
    call print_str
    jmp  main_loop

ask_again:
    mov  dx, again_msg
    call print_str
    call read_char
    call print_nl
    cmp  al, 'Y'
    je   main_loop
    cmp  al, 'y'
    je   main_loop
    cmp  al, 'N'
    je   do_exit
    cmp  al, 'n'
    je   do_exit
    mov  dx, again_err
    call print_str
    jmp  ask_again

do_exit:
    mov  dx, bye_msg
    call print_str
    mov  ah, 4Ch
    int  21h

; ============================================================
; PRINT BANNER
; ============================================================
print_banner:
    mov  dx, banner1
    call print_str
    mov  dx, banner2
    call print_str
    mov  dx, banner3
    call print_str
    mov  dx, banner4
    call print_str
    mov  dx, banner5
    call print_str
    ret

; ============================================================
; PRINT MENU
; ============================================================
print_menu:
    mov  dx, menu_msg
    call print_str
    mov  dx, menu1
    call print_str
    mov  dx, menu2
    call print_str
    mov  dx, menu3
    call print_str
    mov  dx, menu4
    call print_str
    mov  dx, menu5
    call print_str
    mov  dx, menu6
    call print_str
    mov  dx, choice_msg
    call print_str
    ret

; ============================================================
; ENCRYPT
; ============================================================
do_encrypt:
enc_txt:
    call get_text
    cmp  byte [str_len], 0
    jne  enc_key
    mov  dx, err_empty
    call print_str
    jmp  enc_txt
enc_key:
    call get_key
    cmp  byte [shift_key], 0
    je   enc_key

    mov  dx, lbl_orig
    call print_str
    call print_inbuf

    call cipher_inbuf

    mov  dx, lbl_enc
    call print_str
    call print_inbuf
    ret

; ============================================================
; DECRYPT
; ============================================================
do_decrypt:
dec_txt:
    call get_text
    cmp  byte [str_len], 0
    jne  dec_key
    mov  dx, err_empty
    call print_str
    jmp  dec_txt
dec_key:
    call get_key
    cmp  byte [shift_key], 0
    je   dec_key

    mov  dx, lbl_orig
    call print_str
    call print_inbuf

    mov  al, 26
    sub  al, [shift_key]
    mov  [shift_key], al
    call cipher_inbuf

    mov  dx, lbl_dec
    call print_str
    call print_inbuf
    ret

; ============================================================
; BRUTE FORCE
; ============================================================
do_brute:
bf_txt:
    call get_text
    cmp  byte [str_len], 0
    jne  bf_go
    mov  dx, err_empty
    call print_str
    jmp  bf_txt
bf_go:
    mov  dx, lbl_orig
    call print_str
    call print_inbuf

    mov  dx, brute_hdr
    call print_str

    mov  byte [brute_ctr], 1
    mov  byte [pause_ctr], 0

bf_loop:
    mov  al, [brute_ctr]
    cmp  al, 26
    jge  bf_end

    mov  al, [pause_ctr]
    cmp  al, 10
    jl   bf_nopp
    mov  dx, pause_msg
    call print_str
    call read_char
    call print_nl
    mov  byte [pause_ctr], 0
bf_nopp:
    call copy_buf

    mov  al, 26
    sub  al, [brute_ctr]
    mov  [shift_key], al

    mov  dx, key_lbl
    call print_str
    mov  al, [brute_ctr]
    call print_num
    mov  dx, colon_lbl
    call print_str

    call cipher_workbuf
    call print_wbuf
    call print_nl

    mov  al, [brute_ctr]
    inc  al
    mov  [brute_ctr], al
    mov  al, [pause_ctr]
    inc  al
    mov  [pause_ctr], al
    jmp  bf_loop
bf_end:
    ret

; ============================================================
; STEP BY STEP ENCRYPT  (FIXED)
; ============================================================
do_stepbystep:
sbs_txt:
    call get_text
    cmp  byte [str_len], 0
    jne  sbs_key
    mov  dx, err_empty
    call print_str
    jmp  sbs_txt
sbs_key:
    call get_key
    cmp  byte [shift_key], 0
    je   sbs_key

    mov  dx, step_hdr
    call print_str

    mov  si, input_buf+2
    xor  cx, cx
    mov  cl, [str_len]
    cmp  cx, 0
    je   sbs_done

sbs_loop:
    push cx
    push si

    mov  al, [si]

    ; only show letters
    cmp  al, 'A'
    jl   sbs_chk_low
    cmp  al, 'Z'
    jg   sbs_chk_low
    jmp  sbs_show
sbs_chk_low:
    cmp  al, 'a'
    jl   sbs_skip
    cmp  al, 'z'
    jg   sbs_skip

sbs_show:
    push ax                 ; original char bachao

    mov  dx, step_char
    call print_str

    pop  ax                 ; wapas lao
    push ax                 ; dobara bachao (shift ke liye)

    mov  dl, al             ; original char print karo
    mov  ah, 02h
    int  21h

    pop  ax                 ; shift ke liye wapas lao
    call shift_char
    mov  bl, al             ; shifted char bl mein save

    mov  dx, step_arr
    call print_str

    mov  dl, bl             ; shifted char print
    mov  ah, 02h
    int  21h

    mov  dx, step_end
    call print_str

sbs_skip:
    pop  si
    pop  cx
    inc  si
    loop sbs_loop

sbs_done:
    call cipher_inbuf
    mov  dx, step_res
    call print_str
    call print_inbuf
    ret

; ============================================================
; STATISTICS
; ============================================================
do_stats:
stat_txt:
    call get_text
    cmp  byte [str_len], 0
    jne  stat_go
    mov  dx, err_empty
    call print_str
    jmp  stat_txt
stat_go:
    mov  byte [cnt_upper], 0
    mov  byte [cnt_lower], 0
    mov  byte [cnt_space], 0
    mov  byte [cnt_other], 0

    mov  si, input_buf+2
    xor  cx, cx
    mov  cl, [str_len]
    cmp  cx, 0
    je   stat_print

stat_loop:
    push cx
    mov  al, [si]

    cmp  al, 'A'
    jl   st_chk_low
    cmp  al, 'Z'
    jg   st_chk_low
    mov  al, [cnt_upper]
    inc  al
    mov  [cnt_upper], al
    jmp  st_next

st_chk_low:
    mov  al, [si]
    cmp  al, 'a'
    jl   st_chk_sp
    cmp  al, 'z'
    jg   st_chk_sp
    mov  al, [cnt_lower]
    inc  al
    mov  [cnt_lower], al
    jmp  st_next

st_chk_sp:
    cmp  al, ' '
    jne  st_other
    mov  al, [cnt_space]
    inc  al
    mov  [cnt_space], al
    jmp  st_next

st_other:
    mov  al, [cnt_other]
    inc  al
    mov  [cnt_other], al

st_next:
    inc  si
    pop  cx
    loop stat_loop

stat_print:
    mov  dx, stat_hdr
    call print_str

    mov  dx, stat_total
    call print_str
    mov  al, [str_len]
    call print_num
    call print_nl

    mov  dx, stat_upper
    call print_str
    mov  al, [cnt_upper]
    call print_num
    call print_nl

    mov  dx, stat_lower
    call print_str
    mov  al, [cnt_lower]
    call print_num
    call print_nl

    mov  dx, stat_space
    call print_str
    mov  al, [cnt_space]
    call print_num
    call print_nl

    mov  dx, stat_other
    call print_str
    mov  al, [cnt_other]
    call print_num
    call print_nl
    ret

; ============================================================
; GET TEXT
; ============================================================
get_text:
    mov  dx, enter_text
    call print_str
    mov  ah, 0Ah
    mov  dx, input_buf
    int  21h
    call print_nl
    mov  al, [input_buf+1]
    mov  [str_len], al
    xor  ah, ah
    mov  bx, input_buf+2
    add  bx, ax
    mov  byte [bx], '$'
    ret

; ============================================================
; GET KEY
; ============================================================
get_key:
gk_retry:
    mov  dx, enter_key
    call print_str
    call read_char
    sub  al, '0'
    mov  bl, al
    call read_char
    cmp  al, 13
    je   gk_one
    sub  al, '0'
    mov  bh, al
    mov  al, bl
    mov  cl, 10
    mul  cl
    add  al, bh
    jmp  gk_chk
gk_one:
    mov  al, bl
gk_chk:
    call print_nl
    cmp  al, 1
    jl   gk_bad
    cmp  al, 25
    jg   gk_bad
    mov  [shift_key], al
    ret
gk_bad:
    mov  dx, err_key
    call print_str
    jmp  gk_retry

; ============================================================
; CIPHER INBUF
; ============================================================
cipher_inbuf:
    mov  si, input_buf+2
    xor  cx, cx
    mov  cl, [str_len]
    cmp  cx, 0
    je   ci_end
ci_lp:
    mov  al, [si]
    call shift_char
    mov  [si], al
    inc  si
    loop ci_lp
ci_end:
    ret

; ============================================================
; CIPHER WORKBUF
; ============================================================
cipher_workbuf:
    mov  si, work_buf
    xor  cx, cx
    mov  cl, [str_len]
    cmp  cx, 0
    je   cw_end
cw_lp:
    mov  al, [si]
    call shift_char
    mov  [si], al
    inc  si
    loop cw_lp
cw_end:
    ret

; ============================================================
; SHIFT CHAR
; ============================================================
shift_char:
    cmp  al, 'A'
    jl   sc_low
    cmp  al, 'Z'
    jg   sc_low
    sub  al, 'A'
    add  al, [shift_key]
    cmp  al, 26
    jl   sc_up_ok
    sub  al, 26
sc_up_ok:
    add  al, 'A'
    ret
sc_low:
    cmp  al, 'a'
    jl   sc_end
    cmp  al, 'z'
    jg   sc_end
    sub  al, 'a'
    add  al, [shift_key]
    cmp  al, 26
    jl   sc_lo_ok
    sub  al, 26
sc_lo_ok:
    add  al, 'a'
sc_end:
    ret

; ============================================================
; COPY BUF
; ============================================================
copy_buf:
    mov  si, input_buf+2
    mov  di, work_buf
    xor  cx, cx
    mov  cl, [str_len]
    inc  cx
    rep  movsb
    ret

; ============================================================
; UTILITIES
; ============================================================
print_str:
    mov  ah, 09h
    int  21h
    ret

print_inbuf:
    mov  dx, input_buf+2
    call print_str
    ret

print_wbuf:
    mov  dx, work_buf
    call print_str
    ret

read_char:
    mov  ah, 01h
    int  21h
    ret

print_nl:
    mov  dx, newline_s
    call print_str
    ret

print_num:
    cmp  al, 10
    jl   pn_one
    mov  bl, al
    xor  ah, ah
    mov  cl, 10
    div  cl
    push ax
    add  al, '0'
    mov  dl, al
    mov  ah, 02h
    int  21h
    pop  ax
    mov  al, ah
    add  al, '0'
    mov  dl, al
    mov  ah, 02h
    int  21h
    ret
pn_one:
    add  al, '0'
    mov  dl, al
    mov  ah, 02h
    int  21h
    ret