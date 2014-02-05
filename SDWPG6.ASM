;Stephen Willson
;Program 6 - Due December 3, 2010
;This program checks back and forth from the keyboard to the project.
;If a key is hit on the keyboard, then it's printed to the screen and its
;ASCII is displayed on the project's 7-segment displays. If data (ASCII values)
;is sent from the project, three tabs will print on the monitor and then the
;key the ASCII represents will print on the screen. This will continue
;until the user hits '@'.

	.model tiny
	.stack
	.code
	.startup

;  *****  put program instructions here *******************
	mov dx,02f8h            ;These lines initialize the serial port.
	mov al,03h              ;02F8h corresponds to the COM2 hardware
	out dx,al               ;location for the data register. 03h is used
				;to set it up for using no parity, 1 stop bit,
				;and 8 data bits, since that's what our project
				;is using.

poll:
	mov ah,0bh              ;Here, we start the polling process. Using
	int 21h                 ;int 21h with 0Bh will check the keyboard
	cmp al,0ffh             ;buffer for any data there. If a key was
	jz outp                 ;pressed, FFh is put into AL. If not, 00h is
				;put into AL. We just compare AL to FFh, and
				;if the zero flag is set (if AL's contents are
				;FFh) then we jump down to the 'outp' label to
				;handle the data.


	mov dx,02fdh            ;If there wasn't a key pressed, though, we need
	in al,dx                ;to check for whether there's data to read in.
	and al,01h              ;We check the line status register, the
	cmp al,01h              ;location of which is 02FDh. Then, after
	jnz poll                ;reading it into AL, we 'and' it with 01h to
				;isolate just the least significant bit. That
				;bit is Receive Data. If it's a 1, then there
				;is some data and we move right into the next
				;bit of code. Otherwise, we jump back up to
				;the 'poll' label to check the keyboard buffer
				;again.


	mov dx,02f8h            ;Now, we read in from the serial port. 02F8h
	in al,dx                ;is the data register's location. We read
	mov ch,al               ;in since we already know there's been data
				;sent from the project. We then stick it in
				;CH for safekeeping.


	mov ah,02h              ;This section is for formatting purposes.
	mov dl,09h              ;09h is the ASCII for a tab. We print out
	int 21h                 ;three tabs so the data sent from the project
	int 21h                 ;(as opposed to from the keyboard) will print
	int 21h                 ;out several tabs to the right on the screen.
				;This will differentiate it from the keys
				;pressed on the keyboard.


	mov al,ch               ;We then stick the data back into AL and jump
	jmp prnt                ;down to the shared print section.

outp:
	mov ah,07h              ;Since if we're here, we know a key was
	int 21h                 ;pressed, we have to get said key. Int 21h
	mov ch,al               ;used with 07h will read the keyboard but not
				;print it to the screen. We then store it in
				;CH again for safekeeping purposes.


	mov dx,02fdh            ;We read in from the line status register,
	in al,dx                ;located at 02FDh, to see if the serial port
				;is ready to send data.

	and al,60h              ;We 'and' AL with 60h to isolate just bit 5
	cmp al,60h              ;and bit 6, and then check to see if they're
	jnz outp                ;both a 1. Bit 5 is transmitter buffer empty
				;and bit 6 is transmission ready. To check,
				;we compare AL to 60h. If the zero flag is
				;set, we move on, since the port is ready to
				;send. Otherwise, we jump back up to the
				;'outp' label and try again.


	mov dx,02f8h            ;Then, we initialize the data register and
	mov al,ch               ;put our key's value back into AL. We send
	out dx,al               ;AL out the data register, displaying it on
				;the 7-segment displays on our project.


	cmp al,40h              ;Here, we check to see if the key entered was
	jnz prnt                ;an '@' symbol, the symbol to end our program.
	mov dh,01h              ;40h is the ASCII for an '@'. Since we want
				;to print the '@' before ending the program,
				;we don't quite quit yet; instead, we store
				;an 01h into DH so we can check it after the
				;print section.

prnt:
	mov ah,02h              ;These lines put the ASCII value into
	mov dl,al               ;DL and then print it to the screen. The ASCII
	int 21h                 ;value can come from the keyboard or the
				;project, since they use this shared print
				;section.


	mov dl,0ah              ;These lines print out a carriage return and a
	int 21h                 ;line feed to kick us down to the next line
	mov dl,0dh              ;on screen.
	int 21h

	cmp dh,01h              ;If the user pressed an '@' symbol earlier,
	jnz poll                ;then at this point, DH would have an 01h in
				;it. We compare DH to 01h to check. If it's
				;not 01h, then we jump back up to the 'poll'
				;label to start checking for pressed keys/sent
				;data again. If it is 01h, then we hit the end
				;of the code and the program ends.

;  ************  *********************************  **********


		mov ax ,4c00h   ;quit
		int 21h
	end
