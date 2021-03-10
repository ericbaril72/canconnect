	;=================== SET THE PROGRAM NUMBER =======================
	; that will be sent to CAN 
	
	Program_number_LO					alias User22
	Program_number_HI					alias User23
	Program_Revision					alias User24
	
	Program_Revision =	0x41 ; Send revision of vehicle = 'B'
	Program_number_LO = 0x111D ; Send the program Name = 0012 214F
	Program_number_HI = 0x0013 ; In decimal = 1188175
	
	;====================================================================
	;====================================================================
	;== Thinks to change also in the display block of the main program ==
	;====================================================================
	;====================================================================