	org 0100H
;split default is 0, no split
val	equ	12345
val0	equ	123321
valt	equ	123456	;overflow?
valx	equ	123#321
	split	1
val2	equ	123321
valw	equ	123456	;overflow?
val3	equ	12345
valy	equ	123#321
	split	0
val4	equ	12345
val5	equ	123321
valz	equ	123#321

	DW	val,val0,valt,valx
	DW	val2,val2,val3,valy
	DW	val4,val5,valz
	end
			 