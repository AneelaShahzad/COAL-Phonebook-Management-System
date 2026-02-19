.MODEL SMALL
.STACK 100H
.DATA

                     ;---------------------------MESSAGES------------------------
    DISPLAY1          DB  0AH,0DH,"--------------------------------------------------------------------------------$"       ; Prints a horizontal separator line for menu clarity
    NEWLINE           DB  0AH,0DH, "$"      ; Simple newline/carriage return for spacing
    MSG               DB  0AH,0DH, "                       PHONEBOOK MANAGEMENT SYSTEM$"
            ; Menu options for user actions
    MSG1              DB  0AH,0DH, "           1. ADD CONTANT$"
    MSG2              DB  0AH,0DH, "           2. UPDATE CONTANT$"
    MSG3              DB  0AH,0DH, "           3. SEARCH CONTANT$"
    MSG4              DB  0AH,0DH, "           4. DELETE CONTANT$"
    MSG5              DB  0AH,0DH, "           5. DISPLAY CONTANT$"
    MSG6              DB  0AH,0DH, "           6. Exit$"
            ; Prompt asking user to select a menu option
    MSG7              DB  0AH,0DH, "           Enter your Choice: $"
            ; Prompts for contact details
    MSG8              DB  0AH,0DH, "           Enter Name: $"
    MSG9              DB  0AH,0DH, "           Enter Number: $"
            ; Headers for menu
    MSG10             DB  0AH,0DH, "                      ----ADDING NEW CONTACT----$"
    MSGSU1            DB  0AH,0DH, "                      ----UPDATE CONTACT----      $"
    MSG_SEARCH        DB  0AH,0DH, "                      ----SEARCH CONTACT----$"
    MSG_DELETE        DB  0AH,0DH, "                      ----DELETE CONTACT----$"
    MSG_DISPLAY       DB  0AH,0DH, "                      ----ALL CONTACTS----$"
            ; Success/failure messages for add operation
    MSG_SUCCESS       DB  0AH,0DH, "           CONTACT ADDED SUCCESSFULLY!$"
    MSG_FAIL          DB  0AH,0DH, "           Failed to ADD new contact!$"
            ; Validation error messages for name/number input
    MSG_NAME_LONG     DB  0AH,0DH, "           YOUR ENTERED EXCEEDS 25 CHARACTERS$"
    MSG_NUM_LONG      DB  0AH,0DH, "           YOUR ENTERED NUMBER EXCEEDS 11 CHARACTERS$"
    MSG_NUM_INVALID   DB  0AH,0DH, "           INVALID OR WRONG NUMBER ENTERED!$"
            ; Shown when trying to display/delete but no contacts exist
    MSG_EMPTY         DB  0AH,0DH, "                     PHONEBOOK IS ALREADY EMPTY!$"
            ; Shown when maximum contacts are reached
    MSG_FULL          DB  0AH,0DH, "                        PHONEBOOK IS FULL!$"   
            ; Labels used when displaying contact details                       
    MSG_INDEX         DB  0AH,0DH, "            Contact No: $"
    MSG_NAME          DB  0AH,0DH, "            Name: $"
    MSG_NUM           DB  0AH,0DH, "            Number: $"
            ; Search results feedback
    MSG_FOUND         DB  0AH,0DH, "            CONTACT FOUND$"
    MSG_NOT_FOUND     DB  0AH,0DH, "            CONTACT NOT FOUND$"
            ; Shows current name/number before update
    MSG_CUR_NAME      DB  0AH,0DH, "            Name: $"
    MSG_CUR_NUM       DB  0AH,0DH, "            Number: $"
            ; Prompts user for confirmation before updating fields
    MSG_CHG_NAME      DB  0AH,0DH, "            DO YOU WANT TO UPDATE NAME? (Y/N):  $"
    MSG_CHG_NUM       DB  0AH,0DH, "            DO YOU WANT TO UPDATE NUMBER? (Y/N):  $"
            ; Prompts for new values during update
    MSG_ENTER_NEWNAME DB  0AH,0DH, "            Enter New Name: $"
    MSG_ENTER_NEWNUM  DB  0AH,0DH, "            Enter New Number: $"
        ; Input prompt for search operation
    MSG_ENTER_SEARCH  DB  0DH,0AH, "            Enter Name to Search: $"
    MSG_DEL_CONFIRM   DB  0AH,0DH, '            Are You sure you want to DELETE this contact? (Y/N)$'
        ; Confirmation and success messages for delete operation
    MSG_DELETED       DB  0AH,0DH, '            CONTACT IS DELETED SUCCESSFULLY!$'


                        ;--------------------VARIABLES AND CONSTANTS-------------------------
    SEARCH_INDEX      DB  ?
    STR1              DB  35                                                       ; max length of input (20 chars)
                      DB  ?                                                        ; actual length entered (will be set by DOS)
                      DB  35 DUP (?)                                               ; space for characters
    STR2              DB  20                                                     ; max length of input (20 chars)
                      DB  ?                                                        ; actual length entered (will be set by DOS)
                      DB  20 DUP (?)                                               ; space for characters
    COUNT             DB  0
    MAX_CONTACTS      EQU 5                                                        ;this will tell how many contact canbbe store in the array
    NAME_LEN          EQU 35                                                       ;max lenght of the names
    NUM_LEN           EQU 20                                                      ;max lenght of the numbers
    NAMES             DB  MAX_CONTACTS * NAME_LEN DUP (?)                          ;this will tell how much memory is used to store name in array
    NUMBERS           DB  MAX_CONTACTS * NUM_LEN  DUP (?)                          ;and how much memory is used to store the numbers   


.CODE
; ============================
; MAIN FUNCTION
; ============================
MAIN PROC

    ; ============================
    ; INITIALIZE DATA SEGMENT
    ; ============================
                          MOV  AX, @DATA          ; Load address of data segment
                          MOV  DS, AX             ; Initialize DS register with data segment

                          MOV  COUNT, 0           ; Initialize contact count to zero

    ; ============================
    ; CLEAR SCREEN FOR OUTPUT
    ; ============================
                          MOV AH, 06h             ; BIOS scroll up function
                          MOV AL, 00h             ; Clear entire screen
                          MOV BH, 07h             ; Attribute: white text on black background
                          MOV CX, 0000h           ; Upper-left corner (row 0, col 0)
                          MOV DX, 184Fh           ; Lower-right corner (row 24, col 79)
                          INT 10h                 ; Call BIOS video interrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;                MENU CODE               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    

    MENU:                  
    ; Display title line (separator)
                          LEA  DX, DISPLAY1
                          CALL PRINT_MSG

    ; Display program title banner
                          LEA  DX, MSG
                          CALL PRINT_MSG

    ; Display another separator line
                          LEA  DX, DISPLAY1
                          CALL PRINT_MSG

    ; Display menu options
                          LEA  DX, MSG1           ; Option 1: Add Contact
                          CALL PRINT_MSG
                          LEA  DX, MSG2           ; Option 2: Update Contact
                          CALL PRINT_MSG
                          LEA  DX, MSG3           ; Option 3: Search Contact
                          CALL PRINT_MSG
                          LEA  DX, MSG4           ; Option 4: Delete Contact
                          CALL PRINT_MSG
                          LEA  DX, MSG5           ; Option 5: Display Contact
                          CALL PRINT_MSG
                          LEA  DX, MSG6           ; Option 6: Exit program
                          CALL PRINT_MSG

    ; Prompt user to enter a choice (1–6)
                          LEA  DX, MSG7
                          CALL PRINT_MSG

    ; ============================
    ; TAKE INPUT FROM USER
    ; ============================
                          MOV  AH, 01H            ; DOS function: read character
                          INT  21H                ; Read keystroke into AL

    ; ============================
    ; CHECK INPUT AND JUMP TO ROUTINE
    ; ============================
                          CMP  AL, '1'            ; If '1', jump to Add Contact
                          JE   CALL_ADD
                          CMP  AL,'2'             ; If '2', jump to Update Contact
                          JE   CALL_UPDATE
                          CMP  AL,'3'             ; If '3', jump to Search Contact
                          JE   CALL_SEARCH
                          CMP  AL,'4'             ; If '4', jump to Delete Contact
                          JE   CALL_DELETE
                          CMP  AL, '5'            ; If '5', jump to Display Contact
                          JE   CALL_DISPLAY
                          CMP  AL, '6'            ; If '6', jump to Exit program
                          JE   EXIT_LABEL
                          JMP  MENU               ; If invalid input, redisplay menu

CALL_ADD:            
                          CALL ADD_CONTACT        ; Call Add Contact procedure
                          JMP  MENU               ; Return to menu

CALL_DISPLAY:         
                          CALL DISPLAY_CONTACTS   ; Call Display Contacts procedure
                          JMP  MENU               ; Return to menu

CALL_UPDATE:          
                          CALL UPDATE_CONTACT     ; Call Update Contact procedure
                          JMP  MENU               ; Return to menu

CALL_SEARCH:          
                          CALL SEARCH_CONTACT     ; Call Search Contact procedure
                          JMP  MENU               ; Return to menu

CALL_DELETE:
                          CALL DELETE_CONTACT     ; Call Delete Contact procedure
                          JMP MENU                ; Return to menu

EXIT_LABEL:           
                          MOV  AH, 4CH            ; DOS function: terminate program
                          INT  21H                ; Exit to DOS
MAIN ENDP

; ============================
; PRINT MESSAGE FUNCTION
; ============================
PRINT_MSG PROC
                          MOV  AH, 09H            ; DOS function: display string
                          INT  21H                ; Print string at DS:DX until '$'
                          RET                     ; Return
PRINT_MSG ENDP

; ============================
; READ INPUT FUNCTION
; ============================
READ_INPUT PROC
                          MOV  AH, 0AH            ; DOS function: buffered input
                          INT  21H                ; Read input into buffer at DS:DX
                          RET                     ; Return
READ_INPUT ENDP

; ============================
; ADD CONTACT FUNCTION
; ============================
ADD_CONTACT PROC
    ; --- Check if phonebook is full ---
                          MOV  AL, COUNT          ; Load current contact count
                          CMP  AL, MAX_CONTACTS   ; Compare with maximum allowed
                          JE   MOVE               ; If equal, phonebook full
                          JNE  GO                 ; Otherwise, continue

    MOVE:                 
                          CALL PHONEBOOK_FULL_PROC ; Display "Phonebook Full" message

    GO:           
    ; --- Display header for adding contact ---
                          LEA  DX, NEWLINE
                          CALL PRINT_MSG
                          LEA  DX, MSG10
                          CALL PRINT_MSG

    ; --- Prompt for name ---
                          LEA  DX, MSG8           ; "Enter Name:"
                          CALL PRINT_MSG
                          LEA  DX, STR1           ; Input buffer for name
                          CALL READ_INPUT

    ; --- Validate Name ---
                          CALL VALIDATE_NAME      ; Ensure name is valid

    ; --- Store Name ---
                          CALL STORE_NAME         ; Save name in array

    ; --- Prompt for number ---
                          LEA  DX, MSG9           ; "Enter Number:"
                          CALL PRINT_MSG
                          LEA  DX, STR2           ; Input buffer for number
                          CALL READ_INPUT

    ; --- Validate Number ---
                          CALL VALIDATE_NUMBER    ; Ensure number is valid

    ; --- Store Number ---
                          CALL STORE_NUMBER       ; Save number in array

    ; --- Success message and increment count ---
                          LEA  DX, NEWLINE
                          CALL PRINT_MSG
                          LEA  DX, MSG_SUCCESS    ; "Contact Added Successfully!"
                          CALL PRINT_MSG
                          INC  COUNT              ; Increment total contacts
                          RET                     ; Return
ADD_CONTACT ENDP

; ============================
; VALIDATE NAME FUNCTION
; ============================
VALIDATE_NAME PROC
                          MOV  CL, [STR1+1]             ; load length of entered name
                          CMP  CL, 25                   ; compare with max allowed length (25)
                          JA   NAME_TOO_LONG            ; jump if longer than 25 characters
                          CMP  CL, 0                    ; check if length is zero
                          JE   VALID1                   ; jump if empty (invalid)
                          JNE  HERE1                    ; otherwise continue
    VALID1:               
                          CALL NAME_NOT_ADDED_PROC      ; call error handler for empty name
    HERE1:                
                          RET                           ; return from procedure
    NAME_TOO_LONG:        
                          LEA  DX, MSG_NAME_LONG        ; load "name too long" message
                          CALL PRINT_MSG                ; print error message
                          CALL NAME_NOT_ADDED_PROC      ; call error handler for invalid name
VALIDATE_NAME ENDP

; ============================
; VALIDATE NUMBER FUNCTION
; ============================
VALIDATE_NUMBER PROC
                          MOV  CL, [STR2+1]             ; load length of entered number
                          CMP  CL, 11                   ; compare with max allowed length (11)
                          JA   NUMBER_TOO_LONG          ; jump if longer than 11 digits
                          CMP CL, 11                    ; check if exactly 11 digits
                          JNE NUMBER_INVALID            ; if not 11, invalid
                          CMP  CL, 0                    ; check if empty
                          JE   VALID2                   ; jump if empty (invalid)
                          MOV AL,[STR2+2]               ; load first digit of number
                          CMP AL,'0'                    ; check if first digit is '0'
                          JNE  NUMBER_INVALID           ; if not '0', invalid
                          JE HERE2                      ; if '0', continue validation
    VALID2:               
                          CALL NUMBER_NOT_ADDED_PROC    ; call error handler for empty number

    NUMBER_TOO_LONG:      
                          LEA  DX, MSG_NUM_LONG         ; load "number too long" message
                          CALL PRINT_MSG                ; print error message
                          CALL NUMBER_NOT_ADDED_PROC    ; call error handler for invalid number
    HERE2:                
                          LEA  SI, STR2+2               ; point SI to start of number string
    VALID_NUM_LOOP:       
                          MOV  AL, [SI]                 ; load current digit
                          CMP  AL, '0'                  ; check if >= '0'
                          JB   NUMBER_INVALID            ; if below '0', invalid
                          CMP  AL, '9'                  ; check if <= '9'
                          JA   NUMBER_INVALID            ; if above '9', invalid
                          INC  SI                        ; move to next digit
                          DEC  CL                        ; decrement remaining length
                          JNZ  VALID_NUM_LOOP            ; repeat until all digits checked
    NUMBER_VALID:         
                          RET                           ; return if number is valid
    NUMBER_INVALID:       
                          CALL NUMBER_INVALID_PROC      ; call error handler for invalid number
VALIDATE_NUMBER ENDP

; ============================
; STORE NAME FUNCTION
; ============================
STORE_NAME PROC
                          MOV  AL, COUNT                ; load current contact count
                          MOV  BL, NAME_LEN             ; load max name length
                          MUL  BL                       ; AX = COUNT * NAME_LEN (offset)
                          LEA  DI, NAMES                ; point DI to names array
                          ADD  DI, AX                   ; move DI to correct position
                          LEA  SI, STR1+2               ; point SI to entered name string
                          MOV  CL, [STR1+1]             ; load length of name
    COPY_NAME_LOOP:       
                          MOV  AL, [SI]                 ; copy character from input
                          MOV  [DI], AL                 ; store character in array
                          INC  SI                        ; move to next input char
                          INC  DI                        ; move to next array position
                          DEC  CL                        ; decrement length counter
                          JNZ COPY_NAME_LOOP             ; repeat until all chars copied
                          JMP STORE_NAME_DONE            ; jump to end
    STORE_NAME_DONE:      
                          RET                           ; return from procedure
STORE_NAME ENDP

; ============================
; STORE NUMBER FUNCTION
; ============================
STORE_NUMBER PROC
                          MOV  AL, COUNT                ; load current contact count
                          CBW                           ; convert AL to AX (sign extend)
                          MOV  BL, NUM_LEN              ; load max number length
                          MUL  BL                       ; AX = COUNT * NUM_LEN (offset)
                          LEA  DI, NUMBERS              ; point DI to numbers array
                          ADD  DI, AX                   ; move DI to correct position
                          LEA  SI, STR2+2               ; point SI to entered number string
                          MOV  CL, [STR2+1]             ; load length of number
    COPY_NUM_LOOP:        
                          MOV  AL, [SI]                 ; copy digit from input
                          MOV  [DI], AL                 ; store digit in array
                          INC  SI                        ; move to next input digit
                          INC  DI                        ; move to next array position
                          DEC  CL                        ; decrement length counter
                          JNZ  COPY_NUM_LOOP             ; repeat until all digits copied
    STORE_NUM_DONE:       
                          RET                           ; return from procedure
STORE_NUMBER ENDP

; ============================
; ERROR HANDLING FUNCTIONS
; ============================
PHONEBOOK_FULL_PROC PROC
                          LEA  DX, MSG_FULL             ; load "phonebook full" message
                          CALL PRINT_MSG                ; print message
                          JMP  EXIT_LABEL               ; terminate program
PHONEBOOK_FULL_PROC ENDP

DISPLAY_EMPTY PROC
                          LEA DX,MSG_EMPTY              ; load "phonebook empty" message
                          CALL PRINT_MSG                ; print message
                          RET                           ; return
DISPLAY_EMPTY ENDP

NUMBER_INVALID_PROC PROC
                          LEA  DX, MSG_NUM_INVALID      ; load "invalid number" message
                          CALL PRINT_MSG                ; print message
                          CALL NUMBER_NOT_ADDED_PROC    ; call error handler
                          JMP  MENU                     ; return to menu
NUMBER_INVALID_PROC ENDP

NAME_NOT_ADDED_PROC PROC
                          LEA  DX, MSG_FAIL             ; load "failed to add contact" message
                          CALL PRINT_MSG                ; print message
                          JMP  MENU                     ; return to menu
NAME_NOT_ADDED_PROC ENDP

NUMBER_NOT_ADDED_PROC PROC
                          LEA  DX, MSG_FAIL             ; load "failed to add contact" message
                          CALL PRINT_MSG                ; print message
                          JMP  MENU                     ; return to menu
NUMBER_NOT_ADDED_PROC ENDP

; ============================
; DISPLAY CONTACT FUNCTIONS
; ============================
DISPLAY_CONTACTS PROC
    ; Check if empty
    MOV AL, COUNT              ; load current contact count
    CMP AL, 0                  ; compare with zero
    JNE CONTINUE_DISP          ; if not zero, continue to display
    CALL DISPLAY_EMPTY          ; if zero, call empty phonebook message
    RET                         ; return from procedure

CONTINUE_DISP:
    LEA DX,MSG_DISPLAY          ; load "ALL CONTACTS" header
    CALL PRINT_MSG              ; print header

    MOV BL, 0                   ; initialize index to 0
DISPLAY_LOOP:

    CMP BL, COUNT               ; compare index with total count
    JAE DISPLAY_DONE            ; if index >= count, end display

    ; ---------- DISPLAY CONTACT NUMBER ----------
    LEA DX, MSG_INDEX           ; load "Contact No:" label
    CALL PRINT_MSG              ; print label

    MOV AL, BL                  ; load index (0-based)
    INC AL                      ; convert to 1-based numbering
    ADD AL, '0'                 ; convert to ASCII digit
    MOV DL, AL                  ; move digit into DL
    MOV AH, 02H                 ; DOS function: display character
    INT 21H                     ; print contact number

    ; ---------- DISPLAY NAME ----------
    LEA DX, MSG_NAME            ; load "Name:" label
    CALL PRINT_MSG              ; print label

    MOV AL, BL                  ; load index
    MOV CL, NAME_LEN            ; load max name length
    MUL CL                      ; AX = index * NAME_LEN (offset)
    LEA SI, NAMES               ; point SI to names array
    ADD SI, AX                  ; move SI to correct contact position

    MOV CX, NAME_LEN            ; set loop counter for name length

PRINT_NAME:
    MOV DL, [SI]                ; load character from name
    CMP DL, 20H                 ; check if below space (invalid/empty)
    JB END_NAME                 ; if so, end name printing
    MOV AH, 02H                 ; DOS function: display character
    INT 21H                     ; print character
    INC SI                      ; move to next character
    LOOP PRINT_NAME              ; repeat until CX exhausted

END_NAME:

    ; ---------- DISPLAY NUMBER ----------
    LEA DX, MSG_NUM             ; load "Number:" label
    CALL PRINT_MSG              ; print label

    MOV AL, BL                  ; load index
    MOV CL, NUM_LEN             ; load max number length
    MUL CL                      ; AX = index * NUM_LEN (offset)
    LEA SI, NUMBERS             ; point SI to numbers array
    ADD SI, AX                  ; move SI to correct contact position

    MOV CX,11                   ; set loop counter for 11 digits

PRINT_NUM:
    MOV DL, [SI]                ; load digit from number
    MOV AH, 02H                 ; DOS function: display character
    INT 21H                     ; print digit
    INC SI                      ; move to next digit
    LOOP PRINT_NUM               ; repeat until CX exhausted

END_NUM:

    INC BL                      ; increment index
    JMP DISPLAY_LOOP            ; repeat for next contact

DISPLAY_DONE:
    RET                         ; return when all contacts displayed

DISPLAY_CONTACTS ENDP

; ============================
; UPDATE CONTACT FUNCTIONS
; ============================
UPDATE_CONTACT PROC
                          CMP COUNT,0                  ; check if phonebook has contacts
                          JNE CONTINUE_UPDATION        ; if not empty, continue
                          JMP GO_BACK                  ; if empty, jump to GO_BACK
GO_BACK:
                          CALL DISPLAY_EMPTY           ; show "phonebook empty" message
                          RET                          ; return

 CONTINUE_UPDATION:
                          LEA  DX,MSGSU1               ; load "UPDATE CONTACT" header
                          CALL PRINT_MSG               ; print header

    ; ask name to search
                          LEA  DX, MSG8                ; load "Enter Name:" prompt
                          CALL PRINT_MSG               ; print prompt
                          LEA  DX, STR1                ; set buffer for input
                          CALL READ_INPUT              ; read name input

                          CALL SEARCHING_CONTACT       ; search for entered name
                          CMP  SEARCH_INDEX, 0FFH      ; check if not found (0FFh = invalid index)
                          JE   UPDATE_NOT_FOUND        ; if not found, jump to error

    ; show found
                          LEA  DX, MSG_FOUND           ; load "CONTACT FOUND" message
                          CALL PRINT_MSG               ; print message

    ; show current name
                          LEA  DX, MSG_CUR_NAME        ; load "Name:" label
                          CALL PRINT_MSG               ; print label
                          CALL SHOW_FOUND_NAME         ; display found contact name

    ; show current number
                          LEA  DX, MSG_CUR_NUM         ; load "Number:" label
                          CALL PRINT_MSG               ; print label
                          CALL SHOW_FOUND_NUMBER       ; display found contact number

    ; change name?
                          LEA  DX, MSG_CHG_NAME        ; load "Update Name? (Y/N)" prompt
                          CALL PRINT_MSG               ; print prompt
                          MOV  AH,01H                  ; DOS function: read char
                          INT  21H                     ; read user input
                          CMP  AL,'Y'                  ; check if 'Y'
                          JE   DO_UPDATE_NAME          ; if yes, update name
                          CMP  AL,'y'                  ; check if 'y'
                          JE   DO_UPDATE_NAME          ; if yes, update name

    SKIP_NAME:            

    ; change number?
                          LEA  DX, MSG_CHG_NUM         ; load "Update Number? (Y/N)" prompt
                          CALL PRINT_MSG               ; print prompt
                          MOV  AH,01H                  ; DOS function: read char
                          INT  21H                     ; read user input
                          CMP  AL,'Y'                  ; check if 'Y'
                          JE   DO_UPDATE_NUM           ; if yes, update number
                          CMP  AL,'y'                  ; check if 'y'
                          JE   DO_UPDATE_NUM           ; if yes, update number

                          RET                          ; return if no updates

    DO_UPDATE_NAME:       
                          LEA  DX, MSG_ENTER_NEWNAME   ; load "Enter New Name:" prompt
                          CALL PRINT_MSG               ; print prompt
                          LEA  DX, STR1                ; set buffer for new name
                          CALL READ_INPUT              ; read new name
                          CALL VALIDATE_NAME           ; validate new name
                          CALL UPDATE_NAME             ; update name in array
                          JMP  SKIP_NAME               ; continue to number update check

    DO_UPDATE_NUM:        
                          LEA  DX, MSG_ENTER_NEWNUM    ; load "Enter New Number:" prompt
                          CALL PRINT_MSG               ; print prompt
                          LEA  DX, STR2                ; set buffer for new number
                          CALL READ_INPUT              ; read new number
                          CALL VALIDATE_NUMBER         ; validate new number
                          CALL UPDATE_NUMBER           ; update number in array
                          RET                          ; return

    UPDATE_NOT_FOUND:     
                          LEA  DX, MSG_NOT_FOUND       ; load "CONTACT NOT FOUND" message
                          CALL PRINT_MSG               ; print message
                          RET                          ; return
UPDATE_CONTACT ENDP

; ============================
; UPDATE NAME FUNCTION
; ============================
UPDATE_NAME PROC
                          MOV  AL, SEARCH_INDEX        ; load index of found contact
                          MOV  BL, NAME_LEN            ; load max name length
                          MUL  BL                      ; AX = index * NAME_LEN (offset)
                          LEA  DI, NAMES               ; point DI to names array
                          ADD  DI, AX                  ; move DI to correct position
                          LEA  SI, STR1+2              ; point SI to new name string
                          MOV  CL, [STR1+1]            ; load length of new name

    UPD_NAME_LOOP:        
                          MOV  AL, [SI]                ; copy character from input
                          MOV  [DI], AL                ; store character in array
                          INC  SI                      ; move to next input char
                          INC  DI                      ; move to next array position
                          DEC  CL                      ; decrement length counter
                          JNZ  UPD_NAME_LOOP           ; repeat until all chars copied

    DONE_UPD_NAME:        
                          RET                          ; return
UPDATE_NAME ENDP

; ============================
; UPDATE NUMBER FUNCTION
; ============================
UPDATE_NUMBER PROC
                          MOV  AL, SEARCH_INDEX        ; load index of found contact
                          MOV  BL, NUM_LEN             ; load max number length
                          MUL  BL                      ; AX = index * NUM_LEN (offset)
                          LEA  DI, NUMBERS             ; point DI to numbers array
                          ADD  DI, AX                  ; move DI to correct position
                          LEA  SI, STR2+2              ; point SI to new number string
                          MOV  CL, 11                  ; set loop counter (11 digits)

    UPD_NUM_LOOP:         
                          MOV  AL, [SI]                ; copy digit from input
                          MOV  [DI], AL                ; store digit in array
                          INC  SI                      ; move to next input digit
                          INC  DI                      ; move to next array position
                          DEC  CL                      ; decrement length counter
                          JNZ  UPD_NUM_LOOP            ; repeat until all digits copied

    DONE_UPD_NUM:         
                          RET                          ; return
UPDATE_NUMBER ENDP

; ============================
; SEARCH CONTACT FUNCTION
; ============================
SEARCHING_CONTACT PROC
                          MOV  SEARCH_INDEX, 0FFH       ; initialize search index to "not found" (0FFh)
                          MOV  BL, 0                    ; start from first contact (index 0)

    NEXT_CONTACT:         
                          CMP  BL, COUNT                ; compare index with total contacts
                          JAE  DONE                     ; if BL >= COUNT, all checked → exit

    ; calculate current name's address: DI = NAMES + (BL*NAME_LEN)
                          MOV  AL, BL                   ; load index
                          MOV  CL, NAME_LEN             ; load max name length
                          MUL  CL                       ; AX = BL * NAME_LEN (offset)
                          LEA  DI, NAMES                ; point DI to names array
                          ADD  DI, AX                   ; move DI to correct contact position

    ; SI = user input name
                          LEA  SI, STR1+2               ; point SI to entered name string
                          MOV  CL, [STR1+1]             ; load input length

    COMPARE_LOOP:         
                          CMP  CL, 0                    ; check if all characters matched
                          JE   FOUND                    ; if yes, contact found
                          MOV  AL, [SI]                 ; load character from input
                          CMP  AL, [DI]                 ; compare with stored character
                          JNE  NOT_MATCH                ; if mismatch, go to next contact
                          INC  SI                       ; move to next input character
                          INC  DI                       ; move to next stored character
                          DEC  CL                       ; decrement length counter
                          JMP  COMPARE_LOOP             ; repeat comparison

    FOUND:                
                          MOV  SEARCH_INDEX, BL         ; save found index
                          RET                           ; return

    NOT_MATCH:            
                          INC  BL                       ; increment index (next contact)
                          JMP  NEXT_CONTACT             ; repeat search

    DONE:                 
                          RET                           ; return if not found
SEARCHING_CONTACT ENDP

; ============================
; SHOW FOUND NAME FUNCTION
; ============================
SHOW_FOUND_NAME PROC
                          MOV  AL, SEARCH_INDEX         ; load found index
                          MOV  BL, NAME_LEN             ; load max name length
                          MUL  BL                       ; AX = index * NAME_LEN (offset)
                          LEA  DI, NAMES                ; point DI to names array
                          ADD  DI, AX                   ; move DI to correct position

    ; get length of name
                          MOV  CL, NAME_LEN             ; set loop counter
    SHOW_NAME_LOOP:       
                          MOV  AL, [DI]                 ; load character from name
                          CMP  AL, 0                    ; check if null/empty
                          JE   DONE_SHOW_NAME           ; stop if null
                          MOV  DL, AL                   ; move char into DL
                          MOV  AH, 02H                  ; DOS function: display char
                          INT  21H                      ; print character
                          INC  DI                       ; move to next char
                          DEC  CL                       ; decrement counter
                          JNZ  SHOW_NAME_LOOP           ; repeat until done

    DONE_SHOW_NAME:       
                          RET                           ; return
SHOW_FOUND_NAME ENDP

; ============================
; SHOW FOUND NUMBER FUNCTION
; ============================
SHOW_FOUND_NUMBER PROC
                          MOV  AL, SEARCH_INDEX         ; load found index
                          MOV  BL, NUM_LEN              ; load max number length
                          MUL  BL                       ; AX = index * NUM_LEN (offset)
                          LEA  DI, NUMBERS              ; point DI to numbers array
                          ADD  DI, AX                   ; move DI to correct position

                          MOV  CL, 11                   ; set loop counter (11 digits)
    SHOW_NUM_LOOP:        
                          MOV  AL, [DI]                 ; load digit from number
                          MOV  DL, AL                   ; move digit into DL
                          MOV  AH, 02H                  ; DOS function: display char
                          INT  21H                      ; print digit
                          INC  DI                       ; move to next digit
                          DEC  CL                       ; decrement counter
                          JNZ  SHOW_NUM_LOOP            ; repeat until done

    DONE_SHOW_NUM:        
                          RET                           ; return
SHOW_FOUND_NUMBER ENDP

; ============================
; SEARCH CONTACT FUNCTION
; ============================
SEARCH_CONTACT PROC
                          CMP COUNT,0                   ; check if phonebook empty
                          JE BACK                       ; if empty, jump to BACK

                          LEA DX,MSG_SEARCH             ; load "SEARCH CONTACT" header
                          CALL PRINT_MSG                ; print header

                          LEA  DX, MSG8                 ; load "Enter Name:" prompt
                          CALL PRINT_MSG                ; print prompt
                          LEA  DX, STR1                 ; set buffer for input
                          CALL READ_INPUT               ; read name input
                          CALL SEARCHING_CONTACT        ; search for entered name
                          CMP  SEARCH_INDEX,0FFH        ; check if not found
                          JE   NOT_FOUND                ; if not found, jump

                          LEA  DX, MSG_FOUND            ; load "CONTACT FOUND" message
                          CALL PRINT_MSG                ; print message

                          LEA DX,MSG_INDEX              ; load "Contact No:" label
                          CALL PRINT_MSG                ; print label

                          MOV AL,SEARCH_INDEX           ; load found index
                          INC AL                        ; convert to 1-based
                          ADD AL,'0'                    ; convert to ASCII digit
                          MOV DL,AL                     ; move digit into DL
                          MOV AH,02H                    ; DOS function: display char
                          INT 21H                       ; print contact number

                          LEA  DX, MSG_CUR_NAME         ; load "Name:" label
                          CALL PRINT_MSG                ; print label
                          CALL SHOW_FOUND_NAME          ; display found name

    ; show current number
                          LEA  DX, MSG_CUR_NUM          ; load "Number:" label
                          CALL PRINT_MSG                ; print label
                          CALL SHOW_FOUND_NUMBER        ; display found number
                          RET                           ; return

    NOT_FOUND:            
                          LEA  DX, MSG_NOT_FOUND        ; load "CONTACT NOT FOUND" message
                          CALL PRINT_MSG                ; print message
                          RET                           ; return

    BACK:
                         CALL DISPLAY_EMPTY             ; show "phonebook empty" message
                         RET                            ; return
SEARCH_CONTACT ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
;````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
;````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
;````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
;````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DELETE CONTACT ROUTINE - Works for multiple contacts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELETE_CONTACT PROC
    CMP COUNT,0                     ; check if phonebook has contacts
    JNE CONTINUE_DEL                ; if not empty, continue deletion
    JMP DISPLAY_EMPTY_RET            ; if empty, jump to display empty message

CONTINUE_DEL:
    ; Prompt for name to delete
    LEA DX,MSG_DELETE               ; load "DELETE CONTACT" header
    CALL PRINT_MSG                  ; print header

    LEA DX,MSG_ENTER_SEARCH          ; load "Enter Name to Search" prompt
    CALL PRINT_MSG                   ; print prompt

    LEA DX,STR1                      ; set buffer for input
    CALL READ_INPUT                  ; read name input

    ; Search for contact
    CALL SEARCHING_CONTACT           ; search for entered name
    CMP SEARCH_INDEX,0FFH            ; check if not found
    JE NOT_FOUND_DEL                 ; if not found, jump

FOUND_OK:
    ; Display found contact
    LEA DX,MSG_FOUND                 ; load "CONTACT FOUND" message
    CALL PRINT_MSG                   ; print message

    LEA DX,MSG_INDEX                 ; load "Contact No:" label
    CALL PRINT_MSG                   ; print label
    MOV AL,SEARCH_INDEX              ; load found index
    INC AL                           ; convert to 1-based
    ADD AL,'0'                       ; convert to ASCII digit
    MOV DL,AL                        ; move digit into DL
    MOV AH,02H                       ; DOS function: display char
    INT 21H                          ; print contact number

    LEA DX,MSG_NAME                  ; load "Name:" label
    CALL PRINT_MSG                   ; print label
    CALL SHOW_FOUND_NAME             ; display found name

    LEA DX,MSG_NUM                   ; load "Number:" label
    CALL PRINT_MSG                   ; print label
    CALL SHOW_FOUND_NUMBER           ; display found number

    ; Confirm deletion
CONFIRM_LOOP:
    LEA DX,MSG_DEL_CONFIRM           ; load "Confirm Deletion? (Y/N)" prompt
    CALL PRINT_MSG                   ; print prompt

    MOV AH,01H                       ; DOS function: read char
    INT 21H                          ; read user input

    CMP AL,'Y'                       ; check if 'Y'
    JE DO_DELETE                     ; if yes, delete
    CMP AL,'y'                       ; check if 'y'
    JE DO_DELETE                     ; if yes, delete
    CMP AL,'N'                       ; check if 'N'
    JE CANCEL_DELETE                 ; if no, cancel
    CMP AL,'n'                       ; check if 'n'
    JE CANCEL_DELETE                 ; if no, cancel
    JMP CONFIRM_LOOP                 ; loop until valid input

DO_DELETE:
    ; If deleting last contact, no shift needed
    MOV AL,SEARCH_INDEX              ; load index of contact to delete
    MOV BL,COUNT                     ; load total count
    DEC BL                           ; last index = COUNT-1
    CMP AL,BL                        ; compare with last index
    JE DELETE_LAST_ONLY              ; if last, jump

    CALL SHIFTING                    ; shift contacts up
    DEC COUNT                        ; decrement count
    JMP DELETE_DONE
DELETE_LAST_ONLY:
    DEC COUNT                        ; decrement count
    CALL CLEAN_LAST                  ; clear last contact
DELETE_DONE:
    LEA DX,MSG_DELETED               ; load "CONTACT DELETED" message
    CALL PRINT_MSG                   ; print message
    RET
CANCEL_DELETE:
    ; User canceled deletion
    RET
NOT_FOUND_DEL:
    LEA DX,MSG_NOT_FOUND             ; load "CONTACT NOT FOUND" message
    CALL PRINT_MSG                   ; print message
    RET
DISPLAY_EMPTY_RET:
    CALL DISPLAY_EMPTY               ; show "phonebook empty" message
    RET
DELETE_CONTACT ENDP

;---------------------------------------
SHIFTING PROC
    ; Check if shift is needed
    MOV AL,COUNT                     ; load total count
    DEC AL                           ; last index = COUNT-1
    CMP AL,SEARCH_INDEX              ; compare with index to delete
    JLE SHIFT_DONE                   ; if deleting last, no shift

    ; Shift NAMES
    MOV AL,SEARCH_INDEX              ; load index
    INC AL                           ; next contact index
    CBW                              ; sign extend AL → AX
    MOV BL,NAME_LEN                  ; load name length
    MUL BL                           ; AX = next index * NAME_LEN
    LEA SI,NAMES                     ; point SI to names array
    ADD SI,AX                        ; SI = source (next contact)

    MOV AL,SEARCH_INDEX              ; load index again
    CBW
    MOV BL,NAME_LEN
    MUL BL                           ; AX = index * NAME_LEN
    LEA DI,NAMES                     ; point DI to names array
    ADD DI,AX                        ; DI = destination (deleted contact)

    MOV AL,COUNT                     ; load total count
    DEC AL                           ; last index
    SUB AL,SEARCH_INDEX              ; number of contacts to shift
    CBW
    MOV BL,NAME_LEN
    MUL BL                           ; AX = total bytes to shift
    MOV CX,AX                        ; set loop counter

SHIFT_NAMES_LOOP:
    MOV AL,[SI]                      ; copy character from source
    MOV [DI],AL                      ; store at destination
    INC SI                           ; move to next source
    INC DI                           ; move to next destination
    DEC CX                           ; decrement counter
    JNZ SHIFT_NAMES_LOOP             ; repeat until done

    ; Shift NUMBERS
    MOV AL,SEARCH_INDEX              ; load index
    INC AL                           ; next contact index
    CBW
    MOV BL,NUM_LEN                   ; load number length
    MUL BL                           ; AX = next index * NUM_LEN
    LEA SI,NUMBERS                   ; point SI to numbers array
    ADD SI,AX                        ; SI = source (next number)

    MOV AL,SEARCH_INDEX              ; load index again
    CBW
    MOV BL,NUM_LEN
    MUL BL                           ; AX = index * NUM_LEN
    LEA DI,NUMBERS                   ; point DI to numbers array
    ADD DI,AX                        ; DI = destination (deleted number)

    MOV AL,COUNT                     ; load total count
    SUB AL,SEARCH_INDEX              ; number of contacts to shift
    DEC AL
    CBW
    MOV BL,NUM_LEN
    MUL BL                           ; AX = total bytes to shift
    MOV CX,AX                        ; set loop counter

SHIFT_NUM_LOOP:
    MOV AL,[SI]                      ; copy digit from source
    MOV [DI],AL                      ; store at destination
    INC SI                           ; move to next source
    INC DI                           ; move to next destination
    DEC CX                           ; decrement counter
    JNZ SHIFT_NUM_LOOP               ; repeat until done

    ; Clean last contact (moved up)
    CALL CLEAN_LAST

SHIFT_DONE:
    RET
SHIFTING ENDP

;---------------------------------------
CLEAN_LAST PROC
    ; Clear last name
    MOV AL,COUNT                     ; load total count
    CBW
    MOV BL,NAME_LEN                  ; load name length
    MUL BL                           ; AX = COUNT * NAME_LEN
    LEA SI,NAMES                     ; point SI to names array
    ADD SI,AX                        ; SI = last name position

    MOV CX,NAME_LEN                  ; set loop counter
DEL_LAST_NAME:
    MOV BYTE PTR [SI],' '            ; overwrite with space
    INC SI                           ; move to next char
    DEC CX                           ; decrement counter
    JNZ DEL_LAST_NAME                ; repeat until done

    ; Clear last number
    MOV AL,COUNT                     ; load total count
    CBW
    MOV BL,NUM_LEN                   ; load number length
    MUL BL                           ; AX = COUNT * NUM_LEN
    LEA SI,NUMBERS                   ; point SI to numbers array
    ADD SI,AX                        ; SI = last number position

    MOV CX,NUM_LEN                   ; set loop counter
DEL_LAST_NUM:
    MOV BYTE PTR [SI],' '            ; overwrite with space
    INC SI                           ; move to next digit
    DEC CX                           ; decrement counter
    JNZ DEL_LAST_NUM                 ; repeat until done

    RET
CLEAN_LAST ENDP

END MAIN