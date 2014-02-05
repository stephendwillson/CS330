;Stephen Willson
;Program 5 - Due November 19, 2010
;This program will let the user type a key and will print out
;both the character and its corresponding ASCII value on the screen.
;It will also store the key's ASCII value, the ASCII value for its
;high ASCII digit, and the ASCII for its low ASCII digit in the 0300,
;0400, and 0500 pages in memory, respectively. It then bubble sorts
;based on the ASCII value in the 0300 page, also sorting the corresponding
;values in the 0400 and 0500 page. Then it prints out the same characters,
;only after sorting.

	.model tiny
	.stack
	.code
	.startup

;  *****  put program instructions here *******************

	mov bp,0300h            ;BP and SI are set here so later, we can
	mov si,0000h            ;use them for indexing, or jumping to the
				;correct page of memory as well as the
				;correct location. By the time the key
				;press section is done, SI will be equal
				;to the number of keys to be sorted. It's
				;started at 0000h because at first, no
				;keys will have been pressed. BP is
				;set at 0300h because that's the page in
				;memory where I'm storing the actual ASCII
				;value of the pressed keys.

	mov cl,04h              ;If you want to shift more than one place,
				;you need to store the number of places you
				;want to shift in CL and then use it as the
				;source. Here, we put 04h into CL so later
				;we can shift by 4, essentially isolating
				;a single digit to be able to print
				;it to the screen.

Begin:
	mov ah,01h              ;DOS interrupt 21h works by looking at the
	int 21h                 ;value in AH and acts accordingly. 01h waits
				;for key to be pressed and loads its ASCII
				;value into AL. Then it prints the char to
				;screen.



	mov [bp+si],al          ;Right after the key is pressed, its ASCII
				;value is stored in the 300 page of memory
				;in the appropriate position. First, it will
				;go to 0300, and then as SI increases by 1,
				;it will go to 0301, then 0302, etc. It goes
				;to that memory location because we move to
				;a number surrounded by brackets, []. This
				;moves to/from a memory location rather than
				;as an immediate (we can't move TO an
				;immediate, anyways).

	mov ch,al               ;Stores the ASCII value of the key that was
	mov ah,02h              ;pressed in CH so it's not overwritten.
	mov dl,3Dh              ;When int 21h sees 02 in AH, it will print
	int 21h                 ;the ASCII value of whatever's in DL. In
				;this case, we put a 3D in DL because 3D is
				;the ASCII code for '='.


	mov al,ch               ;Puts ASCII for pressed key back into AL.
	shr al,cl               ;Here, we shift by 4 to the right, moving
				;the most significant hex digit to the
				;right. This lets us focus on just the most
				;significant hex digit for now until it's
				;printed to the screen.


	add al,30h              ;We add 30h because 30h is the ASCII code
				;for a zero. So, for example, if they type a
				;4, the ASCII for a 4 is 34h. 04 + 30 = 34,
				;the ASCII value for a 4.


	cmp al,3Ah              ;Compares to see if hex value in AL is
	jc RST                  ;greater than ASCII value of 9 (39h). If it
	add al,07h              ;is bigger, the carry flag will not be set
				;and the jump is skipped, meaning we add 07h
				;for difference between numerical characters
				;(0-9) and characters with ASCII codes higher
				;than that. If not, the jump with carry
				;fires and we skip ahead to the RST section,
				;not adding the 07h and leaving the digit
				;with just the 30h added.

RST:

	mov [bp+si+100],al      ;Right before the ASCII for the most
				;significant hex digit is printed, it's
				;stored in the next page up in memory,
				;the 400's, because we add BP (300)
				;with 100. SI is still added for the same
				;reason as above, making it so we move to
				;400 first, then 401, 402, etc.

	mov dl,al               ;Puts the ASCII value of the most
	mov ah,02h              ;significant hex digit into DL, which is
	int 21h                 ;printed to the screen.


	mov al,ch               ;Puts ASCII value for the key pressed
	and al,0Fh              ;into AL. Then, we 'and' the 2 hex digits
				;with 0Fh so the most significant digit
				;becomes a 0 and the least significant digit
				;remains the same. This way, we can mess
				;with a single digit at a time.


	add al,30h              ;This addition is done for the same reason
				;as the add above. We add to get the correct
				;ASCII value for the typed key.


	cmp al,3Ah              ;Same comparison as above when we looked at
	jc ND                   ;the most significant hex digit. The jump
	add al,07h              ;with carry and add commands will also fire
				;under the same circumstances. The jump
				;still will make the add line not fire, only
				;this time, we jump to the section labeled
				;ND.

ND:

	mov [bp+si+200],al      ;Same as moves above, only this time, it's
	inc si                  ;moving the pressed key's low ASCII digit's
				;ASCII into the 500 page of memory (BP = 300,
				;+ 200 = 500, + whatever SI is at). Then I
				;increment SI, so the next time through it
				;will place the data in question into the
				;next memory location. If it would have moved
				;to the 300 page the first time around, the
				;next key's values would be moved to 301, 401,
				;and 501 instead, increasing for every key.

	mov dl,al               ;Puts the ASCII value of the least
	mov ah,02h              ;significant hex digit in DL, which is
	int 21h                 ;then printed to the screen.


	mov dl,0Dh              ;Then we do a line feed and a carriage
	int 21h                 ;return to jump down to the next line in the
	mov dl,0Ah              ;command prompt where all the pressed keys
	int 21h                 ;and their ASCII values are being printed.


	mov al,ch               ;Lastly, the ASCII value for the pressed
	cmp al,40h              ;key is stuck in AL. It's compared to 40h,
	jnz Begin               ;the ASCII value for the @ sign. If the zero
				;flag is set after the compare, that means
				;the pressed key was @, and we skip the
				;jump, ending the program. If the zero flag
				;isn't set, then they pressed some other key
				;and the jump line fires, going back to the
				;section of code labeled 'Begin', starting
				;the whole process over.

	mov cx,si               ;We copy SI's value (essentially the number
				;of items we need to sort and then print)
				;into CX so it's not trashed at any point
				;during the sorting and printing.

walk:
	dec cx                  ;Here, CX is decremented to represent that
	jz done                 ;an item has been sorted. When CX hits 0, that
				;means that all the items have been sorted.
				;If all the items are sorted, we jump down to
				;the 'done' label, which isn't the end of the
				;program, but rather the end of the sort
				;section. We start to print out all the sorted
				;values at that point.

	mov di,0000h            ;DI is set to 0000h to be used as a counter,
				;in essence. At first, we'll be looking at
				;memory location BP+DI, or 300+0, and
				;comparing it to one higher (301). The next
				;time through, though, we don't want to
				;compare the exact same memory locations again,
				;so we increase DI to instead compare 301 to
				;302, then 302 to 303, etc. This continues
				;until any particular data value has 'bubbled'
				;all the way through the list, and then we
				;come back here to reset DI to 0000h and go
				;through the whole bubbling process again.

step:
	mov al,[bp+di]          ;In this sort, we're sorting by the pressed
	cmp al,[bp+di+1]        ;key's ASCII, so we move the key's actual
	jc ok                   ;(not the ASCII representing its ASCII) ASCII
	call switch             ;into AL and then compare it to the ASCII
				;value sitting in the next memory location
				;up. Then, if the ASCII is less than the
				;value in the next memory location, we jump
				;to the 'ok' label, since that means the item
				;doesn't need to be sorted. If it's greater
				;than the one above it, though, that means it
				;needs to be sorted, so we call the 'switch'
				;subroutine that does the actual sorting.


ok:
	inc di                  ;DI is incremented; this is explained above.

	cmp di,cx               ;Basically, CX acts as a counter for how many
	jnz step                ;items need to be sorted. If CX = DI, then an
	jmp walk                ;item has been fully 'bubbled' to the bottom
				;of the list, and the program skips the jnz
				;and instead goes back to 'walk', decrementing
				;CX and resetting DI to 0000h to start bubbling
				;the next item. If DI does NOT equal CX, that
				;means an item still needs to be swapped more,
				;so we only go back to the 'step' section and
				;continue comparing it to the item one memory
				;location above it.

switch:
	mov ah,[bp+di+1]        ;Here, the actual swapping of values occurs.
	mov [bp+di+1],al        ;As an example, say we have a 35 in position
	mov [bp+di],ah          ;300 in memory, and a 33 in position 301,
				;first, the 33 would be moved into AH. Then,
				;the 35 (which is copied in AL from the step
				;section above) is moved into position 301.
				;Lastly, the 33, which is still sitting in AH,
				;is moved where the 35 started at, position
				;300. This effectively swaps the two, putting
				;the lower value in the lower memory location
				;and the higher value in the higher location.

	mov al,[bp+di+100]      ;This swap functions the exact same as the
	mov ah,[bp+di+101]      ;swap above, only this one swaps the values
	mov [bp+di+101],al      ;stored in the 400 page, not the 300 page. It
	mov [bp+di+100],ah      ;also has to initially move the data value
				;into AL. For the 300 page, this step is done
				;in the 'step' section. For the 400 and 500
				;page, I do it here when I know that the value
				;does indeed have to be swapped.


	mov al,[bp+di+200]      ;Same swap as the above two, only with the 500
	mov ah,[bp+di+201]      ;page of memory.
	mov [bp+di+201],al
	mov [bp+di+200],ah

	ret                     ;This line returns us to the line right after
				;the initial 'call', popping us out of the
				;switch subroutine.

done:
	mov ah,02h              ;In this section, we use int 21h to print
	mov dl,0Ah              ;out two line feeds and a carriage return,
	int 21h                 ;which basically prints out two blank lines
				;and moves the cursor back to the left of
				;the screen. 0Ah is the line feed, and 0Dh
				;is the carriage return.

	mov dl,0Ah
	int 21h

	mov dl,0Dh
	int 21h

	mov di,0000h            ;DI is reset to 0000h so in the Prnt section,
				;I can count how many items I've printed out
				;and compare it to the total number of items.
				;When they're equal, everything's been printed
				;out and it's time to quit the program.

Prnt:
	mov ah,02h              ;First, the ASCII value stored in the 300
	mov dl,[bp+di]          ;page of memory (BP=300) is placed into DL
	int 21h                 ;and printed to the screen. DI functions as
				;a counter, increasing every time the data
				;in the 300, 400, and 500 page is printed, so
				;the next time we print, we instead print the
				;data one memory location up (first we print
				;300, 400, and 500, then 301, 401, and 501,
				;etc.).

	mov dl,3Dh              ;Then an equals sign (3Dh) is printed to the
	int 21h                 ;screen so instead of saying, for example, 
				;'131', it will print out '1=31'.

	mov dl,[bp+di+100]      ;Then the ASCII for the high ASCII digit is
	int 21h                 ;printed to the screen (the sorted value is
				;still sitting in the 400 page of memory).

	mov dl,[bp+di+200]      ;Lastly, the ASCII for the low ASCII digit
	int 21h                 ;is printed to the screen (the sorted values
				;for the low digits are still sitting in the
				;500 page of memory).

	mov dl,0Dh              ;A line feed and a carriage return are
	int 21h                 ;printed, popping the cursor down one line
	mov dl,0Ah              ;and back to the left of the screen so we
	int 21h                 ;can print out the next value on the next
				;line instead of the same line.

	inc di                  ;DI is increased after all the related data
	cmp di,si               ;for one key is printed, acting as a counter
	jnz Prnt                ;for how many keys' data have been printed.
				;It's compared to SI, which is the total
				;number of keys entered in the first half
				;of the program. If they're the same, that
				;means we've printed everything and we can
				;end the program. Otherwise, we jump back up
				;to the beginning of the Prnt section and
				;print out the next related values until
				;everything has been printed.


;  ************  *********************************  **********


		mov ax ,4c00h   ;quit
		int 21h
	end

