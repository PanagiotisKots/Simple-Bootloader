bits 16
org 0x7c00

boot:
    mov ax, 0x2401
    int 0x15
    mov ax, 0x3
    int 0x10
    cli
    lgdt [gdt_pointer]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:boot2

gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32
boot2:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esi, text_lines
    mov ebx, 0xb8000   ; Video memory base address

    ; Clear screen
    xor di, di        ; Start at the beginning of the video memory
    mov cx, 80 * 25   ; Number of text cells (80 columns * 25 rows)
    mov ax, 0x0F00   ; Light gray on black background
    rep stosw        ; Fill the screen with spaces

    ; Display text lines in green
.display_lines:
    mov ecx, 0       ; Reset line counter
.next_line:
    lodsb            ; Load next byte from esi into al
    or al, al       ; Check for null terminator
    jz .done_display ; If null, finish displaying lines

    ; Set text attribute for green text on black background
    mov ah, 0x0A    ; Green on black
    mov [ebx], ax   ; Write character and attribute to video memory
    add ebx, 2      ; Move to the next character cell
    inc ecx         ; Increment line character count
    cmp ecx, 80     ; Check if the line is full (80 characters)
    jb .next_line   ; If not, load the next character

    ; Move to the next line
    add ebx, 160    ; Move to the next line (80 * 2)
    jmp .display_lines

.done_display:
    ; Display "Hello World!" in green
    mov esi, hello
    mov ebx, 0xb8000 + 80 * 2 * 24 ; Move to line 24 (last line on the screen)

.loop:
    lodsb            ; Load next byte from hello string
    or al, al       ; Check for null terminator
    jz halt          ; If null, finish
    or eax, 0x0100  ; Set the high byte to green
    mov word [ebx], ax ; Write character and attribute to video memory
    add ebx, 2      ; Move to the next character cell
    jmp .loop

halt:
    cli
    hlt

text_lines:
    db "Welcome to the Old School Linux OS!", 0
    db "This is a custom bootloader.", 0
    db "Enjoy your stay.", 0
    db "Loading, please wait...", 0
    db "System initializing...", 0
    db "Hello World!", 0

times 510 - ($ - $$) db 0
dw 0xaa55
