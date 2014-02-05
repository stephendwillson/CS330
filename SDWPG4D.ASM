;Stephen Willson
;Program 4 Decimal - Due November 12, 2010
;This program is a decimal adder/subtractor. It will allow the user to
;enter in a 4 digit number, an operation (+ or -), another 4 digit number,
;and an equals sign. It will print out all the numbers and signs entered,
;and will then calculate the answer and print it on the screen.

	.model tiny
	.stack
	.code
	.startup

;  *****  put program instructions here *******************

SStart:
	mov dh,00h
	mov cl,04h
Start:
	mov bx,0000h
Gkey:
	mov ah,07h
	int 21h
	cmp al,40h
	jz IntJmp
	cmp al,3dh
	jz Calculate
	cmp al,2bh
	jz Plus
	cmp al,2dh
	jz Minus
	cmp al,30h
	jc Gkey

					;In the hex program, there was a
					;compare to 67h here. We don't need
					;it in the decimal program, though,
					;since it dealt with allowing values
					;from 67h downward (allowing values
					;from lowercase 'g' and lower). We
					;don't want those keys in this
					;program.
	cmp al,3ah
	jc Proceed
					;There was also a compare to 41h,
					;the ASCII value for a capital 'A'.
					;Since we don't want any of the
					;capital hex digits (A-F), we don't
					;need to allow for those characters.

					;There was another compare to 47h,
					;the ASCII value for a capital 'G'.
					;This was the second half of allowing
					;keys A-F, none of which we want, so
					;that line was removed.

					;Lastly, there was a compare to 61h,
					;the ASCII value for a lowercase 'a'.
					;This was the second half of the
					;filter for allowing lowercase a-g.
					;Again, since we don't want those
					;keys, we don't want to allow them.
	jmp Gkey
Proceed:
	mov ah,02h
	mov dl,al
	int 21h
	sub al,30h

					;There were 3 lines here in the hex
					;program that dealt with subtracting
					;another 07h on top of the 30h to
					;account for the difference between
					;numerical characters and letters
					;(A-F or a-f), but since we don't
					;need to worry about hex values in
					;this program, we leave those lines
					;out.
Pack:
	shl bx,cl

					;Here, I removed the line 'and al,0fh'
					;because it isn't necessary in this
					;program. It dealt with masking out
					;the most significant digit in AL, but
					;was only necessary for the lowercase
					;letters (a-f). The lowercase letters
					;sit 20h higher on the ASCII chart. If
					;the user entered in an 'a', after
					;subtracting 30h and 07h, its value
					;would be 2Ah, not the 0Ah we wanted.
					;In either case, the letters don't
					;matter in this program, so we don't
					;worry about that.


	or bl,al
	jmp Gkey
IntJmp:
	jmp Done
Minus:
	mov dh,01h
Plus:
	push bx
	mov dl,al
	mov ah,02h
	int 21h
	jmp Start
Calculate:
	mov cl,0ch
	mov ah,02h
	mov dl,al
	int 21h
	pop ax
	cmp dh,01h
	jz SubCalc


	add al,bl                       ;Here, we only add two 8 bit registers
	daa                             ;instead of two 16 bit registers
					;because the daa/das commands will
					;only work on 8 bit registers.


	mov bl,al                       ;Then, the answer is stuck into BL
	mov al,ah                       ;and AH is moved into AL. This stores
					;half of the answer in BX so we can
					;use BX later, and moves the rest of
					;AH into AL for use in the next
					;calculation.


	adc al,bh                       ;Now, we add the other half of the
	daa                             ;equation, only this time, an add
					;with carry is used because we need
					;to worry about the carry from the
					;previous operation.


	mov bh,al                       ;Then, the answer is stuck in BH.
					;Now, the whole answer is in BX.
	jnc Prnt
	mov dl,31h
	mov ah,02h
	int 21h
	jmp Prnt
SubCalc:
	cmp ax,bx                       ;Here, we compare AX and BX to see
	jnc SubCalc2                    ;which is bigger. If AX is bigger,
	mov bp,ax                       ;then we jump straight to SubCalc2
	mov ah,02h                      ;where the calculation actually
	mov dl,2dh                      ;happens. Otherwise, if BX is larger,
	int 21h                         ;we know the answer will be negative.
	mov ax,bx                       ;In that case, we print out a minus
	mov bx,bp                       ;sign (that's the 2Dh), and swap
					;around AX and BX, using BP as a
					;temporary holder while swapping.
					;They need to switch because if we
					;did AX - BX with AX being smaller
					;than BX, a negative answer would
					;be printed out as the 100's
					;complement, rather than the actual
					;answer. So, if we did 0 - 10, instead
					;of printing out -10 like it should,
					;it would print out 90. Instead,
					;if we swap them, the equation would
					;go 10 - 0 = 10, and we just print out
					;a negative sign before the 10 and get
					;the correct answer that way.
SubCalc2:
	sub al,bl                       ;Here, the actual calculation happens
	das                             ;for the subtraction. This works the
	mov bl,al                       ;exact same as the addition above,
	mov al,ah                       ;only we use sub and sbb instead for
	sbb al,bh                       ;subtraction, as well as das instead
	das                             ;of daa for decimal adjustment after
	mov bh,al                       ;subtraction.
Prnt:
	mov ax,bx
	shr ax,cl
	and al,0fh
	add al,30h

					;Here, a few lines have been removed
					;relevant to adding an extra 07h
					;beyond the added 30h to get the
					;ASCII for letters (a-f) versus
					;numerical characters. We don't need
					;to do that for this program, though,
					;since we're only dealing with decimal
					;numbers.


	mov dl,al
	mov ah,02h
	int 21h
	sub cl,04h
	cmp cl,0FCh
	jnz Prnt

	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h
	jmp SStart
Done:


;  ************  *********************************  **********


		mov ax ,4c00h   ;quit
		int 21h
	end

