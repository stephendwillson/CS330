;Stephen Willson
;Program 4 Hexadecimal - Due November 12, 2010
;This program is a hexadecimal adder/subtractor. It will allow the user
;to enter in a 4 digits number, an operation (+ or -), another 4 digit
;number, and an equals sign. It will print out all the numbers and signs
;entered, and will then calculate the answer and print it on the screen.

	.model tiny
	.stack
	.code
	.startup

;  *****  put program instructions here *******************

SStart:
	mov dh,00h              ;This section is here so DH and CL aren't
	mov cl,04h              ;reset every single time a + or - is
				;entered. They'll only be reset after a
				;calculation is completed and when the
				;program initially begins. DH is the
				;indicator for whether the program will add
				;or subtract. By default, 01h is subtraction
				;and 00h is addition. CL is set to 04h so
				;later in the program, we can 'pack' digits
				;into BX by moving each hex digit one space
				;to the left.

Start:
	mov bx,0000h            ;BX is reset to 0000h each time the + or -
				;is entered, meaning the user is ready to
				;type another hex string. This way, we
				;don't have to worry about anything else
				;that might end up in BX when we go to 'pack'
				;the digits into BX.

Gkey:
	mov ah,07h              ;These lines wait for a key to be pressed
	int 21h                 ;and then stores its ASCII value in AL.


	cmp al,40h              ;The pressed key's ASCII is compared to 40h,
	jz IntJmp               ;the ASCII for an '@' symbol. @ in this
				;program is pressed when the user is done
				;with it completely. If they hit @, it jumps
				;to an intermediate jump, which then jumps
				;down to the Done label, ending the program.


	cmp al,3dh              ;The key's value is then compared to 3Dh, the
	jz Calculate            ;ASCII value for an '=' sign. If they hit an
				;=, we jump to the Calculation label, doing
				;whatever operation the user specified.


	cmp al,2bh              ;Then the key's value is compared to 2Bh, the
	jz Plus                 ;ASCII value for a '+' sign. If they hit a +,
				;it jumps down to the Plus label, preparing
				;for the user to type in their second number.


	cmp al,2dh              ;Then the key's value is compared to 2Dh, the
	jz Minus                ;ASCII value for a '-' sign. If they hit a -,
				;it jumps down to the Minus label, preparing
				;for the user to type in their second number
				;and setting DH to 01h to signify subtraction.


	cmp al,30h              ;Here, the key's value is compared to 30h.
	jc Gkey                 ;Basically, with the cmp command, the carry
				;flag will be set if the destination is less
				;than the source. This means that if the
				;pressed key's ASCII value stored in AL is
				;less than 30h, the jump will fire, and we
				;go right back to the Gkey label and ignore
				;the keypress. 30h is used because for this
				;program, all the ASCII values below 30h are
				;either meaningless or we've already checked
				;for them.


	cmp al,67h              ;The key's ASCII value is compared to 67h,
	jnc Gkey                ;the ASCII for a lowercase 'g'. This time,
				;instead of jumping on carry, it jumps on
				;no carry, meaning it will jump if the
				;destination is greater than or equal to the
				;source. 67h is used because all of the ASCII
				;values higher than 66h are useless in this
				;program.


	cmp al,3ah              ;The pressed key is compared to 3Ah, jumping
	jc Proceed              ;on carry to the Proceed label, meaning the
				;key was a valid keypress. A jump with carry
				;will jump if destination is less than source.
				;3Ah is used because it's one higher than 39h,
				;the ASCII for 9, so basically, any input with
				;an ASCII value from 30h to 39h is valid
				;(values below 30h were already rejected
				;earlier). We care about these because 30h
				;through 39h are the ASCII values for 0-9.


	cmp al,41h              ;The key's ASCII is compared to 41h next, the
	jc Gkey                 ;ASCII for a capital 'A'. If the ASCII for the
				;key is less than that, we throw it away and
				;go back to Gkey. Since this is a hex adder
				;and subtractor, characters a-f and A-F are
				;still valid, though.


	cmp al,47h              ;Here, the key's ASCII value is compared to
	jc Proceed              ;47h, the value for a capital 'G'. We use
				;G so if the value is lower than G, it will
				;jump ahead to the Proceed label. This takes
				;care of the rest of filtering for capital
				;A-F.


	cmp al,61h              ;Lastly, the key's value is compared to 61h,
	jc Gkey                 ;the ASCII value for lowercase 'a'. If the
				;key's value is lower, it's trashed and we
				;jump back up to Gkey. We need to keep values
				;from 61h-66h, though, since they represent
				;lowercase a-f. Values greater than or equal
				;to 67h were taken care of earlier. The
				;program at this point has effectively
				;filtered out all unnecessary keys.

Proceed:
	mov ah,02h              ;These three lines will print the pressed
	mov dl,al               ;key to the screen by sticking its ASCII
	int 21h                 ;value in AL and then using int 21h with
				;an 02h to print out whatever's in AL.


	sub al,30h              ;30h is subtracted from the pressed key's
				;ASCII value to allow us to work with the
				;actual number, not its ASCII. 30h is used
				;because it's the ASCII value for a 0. So,
				;for example, if a 4 is typed, the ASCII
				;for a 4 is 34h. 34 - 30 = 04, leaving us
				;with the actual value, not its ASCII.

	cmp al,0ah              ;Compares value in AL after subtracting
	jc Pack                 ;30h to 0Ah. If key's value is equal to or
	sub al,07h              ;greater than 0Ah, the jump is skipped
				;and we subtract 07h for the difference
				;between numerical characters (0-9) and
				;characters with ASCII codes higher than
				;that. If the key's value is less than
				;0Ah, meaning it's a numerical character,
				;the jump with carry fires and we skip
				;the subtraction.

Pack:
	shl bx,cl               ;This shifts left by CL. At the beginning,
				;in the Sstart section, CL was set to 04h.
				;In this Pack section, all the digits that
				;are entered get 'packed' into BX, one by
				;one. So, the first digit goes into the
				;least significant place, and the next time
				;a digit is entered, the first digit will
				;shift to the left one position and the
				;newest digit will now be in the least
				;significant position.

	and al,0fh              ;We 'and' AL with 0Fh so the most significant
				;digit in AL becomes a 0 and the least
				;significant digit stays the same. This way,
				;one digit can be focused on at a time.

	or bl,al                ;Now, we 'or' BL with AL. This will leave
				;BL's most significant digit as whatever
				;it was, leaving the previously packed digit
				;alone. However, it will change BL's least
				;significant digit to the digit that's left
				;in AL after the previous 'and'. That digit
				;has been effectively 'packed' into the BL
				;register now.

	jmp Gkey                ;If the program's at this line of code, it
				;means the user hasn't entered in an '='
				;sign yet, so the strings of digits still
				;need to keep being entered in and packed.
				;It jumps back to Gkey to continue getting
				;the user's input.

IntJmp:
	jmp Done                ;This is just an intermediate jump to the
				;end of the program. After a certain length,
				;jumps will start throwing an error because
				;you're jumping too far. Placing the
				;intermediate jump right here means that it
				;can never be wandered into by accident, so
				;it's the logical place to put it.
Minus:
	mov dh,01h              ;This puts an 01h into DH. As explained above,
				;this program assumes that an 01h indicates
				;subtract and a 00h indicates add.

Plus:
	push bx                 ;Once a string of digits is fully packed
				;into BX and the user hits a + or - sign,
				;the contents of BX are pushed onto the stack
				;for temporary storage. This way, we can also
				;pack the second number into BX without
				;trashing our original data.


	mov dl,al               ;These lines will print out the contents
	mov ah,02h              ;of AL by moving them to DL and using int
	int 21h                 ;21h. At this point, the contents of AL will
				;be the sign that was pressed by the user,
				;either a plus or minus (+ or -).


	jmp Start               ;Just a jump back to Start to let the user
				;type in the second number. We don't want to
				;go to calculate until the equals (=) sign is
				;keyed in.

Calculate:
	mov cl,0ch              ;CL is set to 0Ch here so later, we can
				;shift by 12 (3 hex digits). It's not set
				;to 0Ch in the section where it's used
				;because that section will loop and a
				;requirement for it to work correctly is
				;04h being subtracted from CL every time.
				;If it was set to 0Ch there, it would get
				;reset to 0Ch every time. We want to shift
				;by 12 in the first place so we can take
				;the most significant hex digit of the final
				;answer and move it over to the least
				;significant position and then print it.


	mov ah,02h              ;These three lines move what's in AL to DL
	mov dl,al               ;and then print it out. At this point in the
	int 21h                 ;program, the ASCII for an '=' sign will
				;always be in AL, since when that key is hit,
				;the program jumps to the Calculate section.
				;An '=' is printed just so the full equation
				;prints to the screen (hex digits +/- hex
				;digits = answer), not just parts of it.


	pop ax                  ;Pop pulls the most recent item put on the
				;stack and puts it into the specified
				;register. In this case, it's stuck into AX.
				;Now, the first number the user entered is
				;stored in AX and the second is stored in BX.


	cmp dh,01h              ;Checks DH to see if we need to subtract.
	jz SubCalc              ;If there's an 01h in DH, the program will
				;jump ahead to a separate section for
				;doing subtraction. Otherwise, it skips the
				;jump and hits the next few lines that do the
				;addition commands.


	add ax,bx               ;Simply adds AX and BX, the two registers
				;that contain the two hex strings the user
				;entered.


	mov bx,ax               ;Sticks the answer back into BX so there's
				;a safe copy of it somewhere. It won't be
				;safe in AX since the next few print commands
				;make use of AH, trashing the data stored
				;there in the process.


	jnc Prnt                ;If there's no carry from the addition, skip
	mov dl,31h              ;the next few lines and go to the Prnt
	mov ah,02h              ;section. If there is a carry, though, that
	int 21h                 ;means we've gone over the allotted 16 bits.
	jmp Prnt                ;If that's the case, this section prints out
				;a '1' before the answer to show that a carry
				;happened. For example, if the user did
				;FFFF+1, it would print out 10000. Even if
				;the 1 is printed, though, we still jump over
				;the subtraction calculation and go to the
				;Prnt section.

SubCalc:
	sub ax,bx               ;Same as above, only we subtract instead of
	mov bx,ax               ;add. The answer is stuck in BX for the same
				;reason as above, too. This way, the answer
				;isn't lost if the data in AX is trashed.

Prnt:
	mov ax,bx               ;Here, the answer is copied back into AX so
				;it can be fiddled with and changed back to
				;the ASCII values representing it and then
				;printed to the screen. It's critical that
				;it's copied in right here, since Prnt and
				;Prnt2 will essentially loop back to this
				;point repeatedly, but after trashing most
				;of the data in AX. This way, we can work
				;with the original answer on each iteration
				;of the loop.


	shr ax,cl               ;The answer is shifted to the right by CL,
				;which starts off at 0Ch and goes down by
				;4 each time through the loop. The first time,
				;the answer's most significant digit will
				;be moved to the least significant position.
				;Each time after, the next digit to the right
				;in the original answer will be isolated in
				;the least significant position (since it
				;shifts first by 12 = 3 hex digits, then
				;8 = 2 hex digits, then 4 = 1 hex digit, then
				;finally it shifts by 00h, leaving the least
				;significant digit where it is).


	and al,0fh              ;We 'and' AL with 0Fh so the most significant
				;digit becomes a 0 and the least significant
				;digit is left alone. This way, we can mess
				;with a single digit at a time.


	add al,30h              ;30h is added to the digit left in AL so
	cmp al,3Ah              ;we can get the correct ASCII for it. If
	jc Prnt2                ;the digit is a 1, 30 + 1 = 31, the correct
	add al,07h              ;ASCII value for a 1. It's then compared to
				;3A to see if it's greater than the ASCII
				;value of a 9 (39h). If it is bigger, the
				;carry flag will not be set and the jump is
				;skipped, meaning we add 07h for the
				;difference between numerical characters and
				;characters with ASCII codes higher than that.
				;If not, the jump with carry fires and we skip
				;ahead to the Prnt2 section, not adding 07h
				;and leaving the digit with just the 30h
				;added.

Prnt2:
	mov dl,al               ;The key's value is then moved into DL and
	mov ah,02h              ;printed to the screen using int 21h.
	int 21h


	sub cl,04h              ;04h is subtracted, as explained above, so
	cmp cl,0FCh             ;when this section loops, the next time
	jnz Prnt                ;through, it will shift the digits to the
				;right by one less position. Then it's
				;compared to FCh. FCh is used because it
				;will be the value in CL if 04h is subtracted
				;from 00h. Once the loop runs after shifting
				;by 00h, we've finished all the printing and
				;we don't want the print section to loop
				;again, so we go ahead to finish the rest of
				;code below.


	mov dl,0dh              ;This section simply does a carriage return
	int 21h                 ;and a line feed to jump down to the next
	mov dl,0ah              ;line in the command prompt where all the
	int 21h                 ;keys, symbols, and answers are being printed.


	jmp SStart              ;After the answer is printed to the screen,
				;the program jumps back to Sstart, not Start.
				;There, DH is reset back to 00h so we don't
				;always subtract, and CL is reset to 04h so
				;we don't accidentally shift by 0Fh, the
				;value CL is at after the print loop is
				;finished.
Done:


;  ************  *********************************  **********


		mov ax ,4c00h   ;quit
		int 21h
	end

