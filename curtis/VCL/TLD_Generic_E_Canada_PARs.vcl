;=================================================================
;   Copyright © 2009, all rights reserved
;
;   Curtis PMC              			Curtis Balkan Ltd.               
;   235 East Airwary Blvd					Tsar Boris 3 N156
;   Livermore, CA  94551		 	 		 Sofia,Bulgaria         
;   (925)961-1088									+ 359 2 808 14 30
;===============================================================

;===============================================================
;
;									TLD NBL PARAMETERS SET 
;
;===============================================================
;	Because we have different parameters defaults for different 
;	vehicles type. Parameters will be separated from the main Program
; IN ORDER TO CREATE EXE RENAME THIS FILE AS TLD_Generic_PARs.VCL



;================================================================
;  										 Revision History 
;================================================================
;	25/Feb/2010 	- A.Stamenov Rev.A First Release 
;	12/Mar/2010 	- A.Stamenov Rev.B New Features added 
;							- Pump Hourmeter added 
;	20/Apr/2010 	- A.Stamenov Rev.C BeltHR changed to PumpHR 
;	30.Jan.2012 	- A.Stamenov Rev.D	Added Pedal Fault Delay
; 05/Jun/2013		- J.Kusseling Rev E Added Docking speed parameters
;									- Updated defaults according to existing previous Rev E
; 11/Jun/2013			- JK Set defaults for Docking speed FWD & Docking speed REV to 40rpm
; 12/Jun/2013			- JK BDI lockout level default = 5% 
; 05/Dec/2013		- J.Kusseling Rev F with new Aircraft Safe Docking (ASD) function
; 11/Apr/2014			- Added Metric units display parameter
;===============================================================
;											DECLARATION
; Variable and Constant Declarations - These are generally placed
; at the beginning of the program to allow easier management of
; VCL user variables.
;===============================================================
;****************************************
; 			 PARAMETER USER VARIABLES
;****************************************
	PAR_Total_Maint_interval			alias P_user1
	PAR_Trac_Maint_interval				alias P_user2
	;----------- MULTIMODE ----------------
	PAR_Max_speed_Normal_FWD			alias P_user3
	PAR_Max_speed_Normal_REV			alias P_user4
	PAR_Max_speed_LOW_FWD					alias P_user5
	PAR_Max_speed_LOW_REV					alias P_user6
	PAR_Max_speed_inching					alias P_user7
	PAR_Max_speed_BDI_LOW					alias P_user8
	PAR_Inching_Timeout						alias P_user9
	PAR_Max_speed_dock_FWD				alias P_user33
	PAR_Max_speed_dock_REV				alias P_user34
	PAR_release_brake_speed_after_high	alias P_user35
	PAR_release_brake_speed_after_low		alias P_user40
	;PAR_Normal_Full_Brake_Rate_LS	alias P_user36
	PAR_ASD_Full_Brake_Rate_LS		alias P_user37
	PAR_ASD_high_delta						alias P_user38
	PAR_ASD_low_delta							alias P_user39						
	;--------- OUTPUT PARAMETERS -----------
	PAR_Power_Steering_DLY				alias P_user10
	PAR_Power_sreering_PWM				alias P_user11	
	PAR_Brake_light_PWM						alias P_user12	
	PAR_load_enable_voltage				alias	P_User13
	PAR_load_disable_delay				alias	P_User14
	PAR_current_load_PWM					alias P_user15
	PAR_EVY1_PWM									alias P_user16
	;---------------------------------------
	PAR_Offset_Throttle						alias P_user17
	PAR_Vehicle_type							alias P_user18
	PAR_Vehicle_NAME							alias P_User19	
	;---------------------------------------
	PAR_BDI_Driver_PWM						alias P_user22
	PAR_BDI_Warning_Level					alias	P_User23
	PAR_BDI_Pre_Warning_Level			alias	P_User24
	;---------------------------------------
	PAR_Pump_Maint_interval				alias P_user25
	
	;--------------------------------------
	PAR_BDI_LOW_level							alias P_User30
	PAR_inching_Distance					alias P_user31
	PAR_Pedal_fault_DLY						alias P_User32
	
	PAR_DEF_Kp										alias P_User43
	PAR_DEF_Ki_LS 								alias P_User44
	PAR_DEF_Full_Accel_Rate_LS		alias P_User45
	PAR_DEF_Low_Accel_Rate				alias P_User46
	PAR_DEF_Neutral_Decel_Rate_LS	alias P_User47
	PAR_DEF_Full_Brake_Rate_LS		alias P_User48
	PAR_DEF_Low_Brake_Rate				alias P_User49
	PAR_DEF_Partial_Decel_Rate		alias P_User50
	
	PAR_ALT_Kp										alias P_User53
	PAR_ALT_Ki_LS 								alias P_User54
	PAR_ALT_Full_Accel_Rate_LS		alias P_User55
	PAR_ALT_Low_Accel_Rate				alias P_User56
	PAR_ALT_Neutral_Decel_Rate_LS	alias P_User57
	PAR_ALT_Full_Brake_Rate_LS		alias P_User58
	PAR_ALT_Low_Brake_Rate				alias P_User59
	PAR_ALT_Partial_Decel_Rate		alias P_User60

;****************************************
; 			 PARAMETER USER BIT VARIABLES
;****************************************
Total_Maintenance_enable			bit P_user_bit1.1
Trac_Maintenance_enable				bit P_user_bit1.2
PAR_enable_VCL_HPD						bit P_user_bit1.4
PAR_Blinking_BDI_output				bit P_user_bit1.8

PAR_REV_creep_spd_enable			bit	P_user_bit1.32
PAR_Display_show_speed				bit P_user_bit1.64
PAR_Change_direction_enable 	bit P_user_bit1.128
;-------------------------------------------------
PAR_Current_load_fcn_enable 	bit P_user_bit2.1
PAR_BDI_LED_enable 						bit P_user_bit2.2
PAR_Pump_Maintenance_enable		bit P_user_bit2.4
PAR_Metric_Units_Display			bit P_user_bit2.8
PAR_Proximity_Sensor					bit P_user_bit2.16


;PARAMETERS:
;################################################
;	PARAMETER_ENTRY	"TLD NBL"
;		TYPE		PROGRAM
;		LEVEL		1
;		END

;################################################

		;-------------------------------------
		;	PARAMETER_ENTRY "Vehicle Configuration"
		;		TYPE	PROGRAM
		;		LEVEL	2
		;	END				
			;--- JET16 is selected ---------
			;	PARAMETER_ENTRY	"Vehicle Type"
			;		TYPE		PROGRAM
			;		WIDTH		16BIT
			;		ADDRESS		P_User18
			;		MINRAW		0
			;		MINDSP		0
			;		MAXRAW		4
			;		MAXDSP		4
			;		LAL_READ	6
			;		LAL_WRITE	6
			;		DEFAULT		0
			;	END
			
			;--- JET16 is selected ---------
			;	PARAMETER_ENTRY	"Vehicle index"
			;		TYPE		PROGRAM
			;		WIDTH		16BIT
			;		ADDRESS		P_User19
			;		MINRAW		0
			;		MINDSP		0
			;		MAXRAW		6
			;		MAXDSP		6
			;		LAL_READ	6
			;		LAL_WRITE	6
			;		DEFAULT		2
			;	END			
			
			;PARAMETER_ENTRY	"Sequenced Driving Autorization"
			;   	TYPE			Program
			;		ADDRESS			P_User_Bit1
			;		WIDTH				8Bit
			;		BITSELECT		2
			;		BITACTIVELOW	NO
			;   LAL_READ		4
			;		LAL_WRITE		4
			; 	DEFAULT			OFF
			;		END
			
			;PARAMETER_ENTRY	"Allow Change Direction Enable"
			;   	TYPE			Program
			;		ADDRESS			P_User_Bit1
			;		WIDTH				8Bit
			;		BITSELECT		7
			;		BITACTIVELOW	NO
			;   LAL_READ		4
			;		LAL_WRITE		4
			; 	DEFAULT			ON
			;		END

			;PARAMETER_ENTRY	"Show speed in Display"
			;   	TYPE			Program
			;		ADDRESS			P_User_Bit1
			;		WIDTH				8Bit
			;		BITSELECT		6
			;		BITACTIVELOW	NO
			;   LAL_READ		4
			;		LAL_WRITE		4
			; 	DEFAULT			ON
			;		END
			
			;PARAMETER_ENTRY	"Display speed in Metric Units"
			;   	TYPE			Program
			;		ADDRESS			P_User_Bit2
			;		WIDTH				8Bit
			;		BITSELECT		3
			;		BITACTIVELOW	NO
			;   LAL_READ		4
			;		LAL_WRITE		4
			; 	DEFAULT			ON
			;		END
			
			
			;PARAMETER_ENTRY	"Proximity sensor"
			;   	TYPE			Program
			;		ADDRESS			P_User_Bit2
			;		WIDTH				8Bit
			;		BITSELECT		4
			;		BITACTIVELOW	NO
			;   LAL_READ		4
			;		LAL_WRITE		4
			; 	DEFAULT			ON
			;		END
		;-------------------------------------
			;	PARAMETER_ENTRY "BDI led Option"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END
			
				;PARAMETER_ENTRY	"BDI led Function Enable"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit2
				;		WIDTH				8Bit
				;		BITSELECT		1
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END
				
				;PARAMETER_ENTRY	"Blinking BDI output"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit1
				;		WIDTH				8Bit
				;		BITSELECT		3
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END			
				
				;	PARAMETER_ENTRY	"BDI Driver PWM"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User22
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		32767
				;		MAXDSP		100
				;		DECIMALPOS	0
				;		LAL_READ	5
				;		LAL_WRITE	5
				;		DEFAULT		35
				;		UNITS			%
				;	END
								
				;	PARAMETER_ENTRY	"BDI pre warning level"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User24
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		60
				;		MAXDSP		60
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	1
				;		DEFAULT		35
				;		UNITS		%
				;	END
				
				;	PARAMETER_ENTRY	"BDI warning level"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User23
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		60
				;		MAXDSP		60
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	1
				;		DEFAULT		20
				;		UNITS		%
				;	END				
	
		;-------------------------------------
			;	PARAMETER_ENTRY "Current Load Option"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END
			
				;PARAMETER_ENTRY	"Current Load Function Enable"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit2
				;		WIDTH				8Bit
				;		BITSELECT		0
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END
			
				;	PARAMETER_ENTRY	"Current load enable Voltage"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User13
				;		MINRAW		800
				;		MINDSP		800
				;		MAXRAW		10500
				;		MAXDSP		10500
				;		DECIMALPOS	2
				;		LAL_READ	5
				;		LAL_WRITE	5
				;		DEFAULT		8000
				;		UNITS		volt
				;	END
				
				;	PARAMETER_ENTRY	"Current load disable Delay"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User14
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		360
				;		MAXDSP		360
				;		DECIMALPOS	0
				;		LAL_READ	5
				;		LAL_WRITE	5
				;		DEFAULT		120
				;		UNITS		second
				;	END

				;	PARAMETER_ENTRY	"Current Load PWM"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User15
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		32767
				;		MAXDSP		100
				;		DECIMALPOS	0
				;		LAL_READ	5
				;		LAL_WRITE	5
				;		DEFAULT		100
				;		UNITS			%
				;	END											

				
			;-------------------------------------
			;	PARAMETER_ENTRY "REV Creep Settings"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END		

						;PARAMETER_ENTRY	"Rev Creep Speed Enable"
						;   	TYPE			Program
						;		ADDRESS			P_User_Bit1
						;		WIDTH				8Bit
						;		BITSELECT		5
						;		BITACTIVELOW	NO
						;   LAL_READ		4
						;		LAL_WRITE		4
						; 	DEFAULT			OFF
						;		END
															
						;	PARAMETER_ENTRY	"Rev Creep Speed"
						;		TYPE		PROGRAM
						;		WIDTH		16BIT
						;		ADDRESS		P_User17
						;		MINRAW		0
						;		MINDSP		0
						;		MAXRAW		16384
						;		MAXDSP		50
						;		DECIMALPOS	0
						;		LAL_READ	1
						;		LAL_WRITE	1
						;		DEFAULT		7
						;		UNITS		%
						;	END				
	;------------------------------------
	;	PARAMETER_ENTRY	"Parameter Settings"
	;		TYPE		PROGRAM
	;		LEVEL		2
	;		END

					;	PARAMETER_ENTRY	"BDI low max speed"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User8
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		3000
					;		MAXDSP		3000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		278
					;	END					
     	
					;	PARAMETER_ENTRY	"ASD speed FWD"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User33
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		3000
					;		MAXDSP		3000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		35
					;	END				
					
					;	PARAMETER_ENTRY	"ASD speed REV"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User34
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		3000
					;		MAXDSP		3000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		140
					;	END	
     	
					;	PARAMETER_ENTRY	"High speed FWD"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User3
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		6000
					;		MAXDSP		6000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		1300
					;	END				
					
					;	PARAMETER_ENTRY	"High speed REV"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User4
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		6000
					;		MAXDSP		6000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		278
					;	END				
					
					;;	PARAMETER_ENTRY	"Default Full Brake Rate LS"
					;;		TYPE		PROGRAM
					;;		WIDTH		16BIT
					;;		ADDRESS		P_User36
					;;		MINRAW		100
					;;		MINDSP		1
					;;		MAXRAW		30000
					;;		MAXDSP		300
					;;		DECIMALPOS	1
					;;		SIGNED		NO
					;;		STEP_SIZE	1
					;;		UNITS			second
					;;   LAL_READ		4	
					;;		LAL_WRITE		4
					;;		DEFAULT		60
					;;	END		
     	
					;	PARAMETER_ENTRY	"Low speed FWD"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User5
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		6000
					;		MAXDSP		6000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		278
					;	END				
					
					;	PARAMETER_ENTRY	"Low speed REV"
					;		TYPE		PROGRAM
					;		WIDTH		16BIT
					;		ADDRESS		P_User6
					;		MINRAW		0
					;		MINDSP		0
					;		MAXRAW		6000
					;		MAXDSP		6000
					;		DECIMALPOS	0
					;		SIGNED		NO
					;		UNITS			RPM
					;   LAL_READ		4	
					;		LAL_WRITE		4
					;		DEFAULT		278
					;	END							

					;------------------------------------
					;	PARAMETER_ENTRY	"ASD Settings"
					;		TYPE		PROGRAM
					;		LEVEL		3
					;		END

								;	PARAMETER_ENTRY	"Release brake speed after high"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User35
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		40
								;		MAXDSP		40
								;		DECIMALPOS	0
								;		SIGNED		NO
								;		UNITS			RPM
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		10
								;	END		
      					
								;	PARAMETER_ENTRY	"Release brake speed after low"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User40
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		40
								;		MAXDSP		40
								;		DECIMALPOS	0
								;		SIGNED		NO
								;		UNITS			RPM
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		30
								;	END		
      					
								;	PARAMETER_ENTRY	"ASD Full Brake Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User37
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		1
								;	END		
      					
								;	PARAMETER_ENTRY	"Dock speed high delta"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User38
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		40
								;		MAXDSP		40
								;		DECIMALPOS	0
								;		SIGNED		NO
								;		UNITS			RPM
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		30
								;	END		
      					
								;	PARAMETER_ENTRY	"Dock speed low delta"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User39
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		40
								;		MAXDSP		40
								;		DECIMALPOS	0
								;		SIGNED		NO
								;		UNITS			RPM
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		15
								;	END		
					;-------------------------------------
					;	PARAMETER_ENTRY "Inching Settings"
					;		TYPE	PROGRAM
					;		LEVEL	3
					;	END
		
			
								;	PARAMETER_ENTRY	"Inching MAX SPEED"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User7
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		6000
								;		MAXDSP		6000
								;		DECIMALPOS	0
								;		SIGNED		NO
								;		UNITS			RPM
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		200
								;	END						
								
								;	PARAMETER_ENTRY	"Inching Timeout"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User9
								;		MINRAW		0
								;		MINDSP		0
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		LAL_READ	1
								;		LAL_WRITE	1
								;		DEFAULT		10
								;		UNITS		second
								;	END
     	
								;	PARAMETER_ENTRY	"Inching Distance"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS			P_User31
								;		MINRAW			0
								;		MINDSP			0
								;		MAXRAW			500
								;		MAXDSP			500
								;		DECIMALPOS	0
								;		SIGNED			NO
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		10
								;	END										
			
					;-------------------------------------
					;	PARAMETER_ENTRY "Default gains & rates"
					;		TYPE	PROGRAM
					;		LEVEL	3
					;	END
									;	PARAMETER_ENTRY	"Default Kp"
									;		TYPE		PROGRAM
									;		WIDTH		16BIT
									;		ADDRESS			P_User43
									;		MINRAW			0
									;		MINDSP			0
									;		MAXRAW			8192
									;		MAXDSP			100
									;		DECIMALPOS	0
									;		SIGNED			NO
									;   LAL_READ		4	
									;		LAL_WRITE		4
									;		DEFAULT		70
									;	END			
									
									;	PARAMETER_ENTRY	"Default Ki LS"
									;		TYPE		PROGRAM
									;		WIDTH		16BIT
									;		ADDRESS			P_User44
									;		MINRAW			50
									;		MINDSP			5
									;		MAXRAW			1000
									;		MAXDSP			100
									;		DECIMALPOS	0
									;		SIGNED			NO
									;   LAL_READ		4	
									;		LAL_WRITE		4
									;		DEFAULT		70
									;	END		
									
								;	PARAMETER_ENTRY	"Default Full Accel Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User45
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		120
								;	END		
      					
 								;	PARAMETER_ENTRY	"Default Low Accel Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User46
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		60
								;	END			
      					
 								;	PARAMETER_ENTRY	"Default Neutral Decel Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User47
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		20
								;	END			
      					
 								;	PARAMETER_ENTRY	"Default Full Brake Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User48
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		60
								;	END			
      					
 								;	PARAMETER_ENTRY	"Default Low Brake Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User49
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		50
								;	END			
      					
 								;	PARAMETER_ENTRY	"Default Partial Decel Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User50
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		DEFAULT		200
								;	END				
					
					
					;-------------------------------------
					;	PARAMETER_ENTRY "Alternative gains & rates"
					;		TYPE	PROGRAM
					;		LEVEL	3
					;	END
									;	PARAMETER_ENTRY	"Alt Kp"
									;		TYPE		PROGRAM
									;		WIDTH		16BIT
									;		ADDRESS			P_User53
									;		MINRAW			0
									;		MINDSP			0
									;		MAXRAW			8192
									;		MAXDSP			100
									;		DECIMALPOS	0
									;		SIGNED			NO
									;   LAL_READ		4	
									;		LAL_WRITE		4
									;		Default		75
									;	END			
									
									;	PARAMETER_ENTRY	"Alt Ki LS"
									;		TYPE		PROGRAM
									;		WIDTH		16BIT
									;		ADDRESS			P_User54
									;		MINRAW			50
									;		MINDSP			5
									;		MAXRAW			1000
									;		MAXDSP			100
									;		DECIMALPOS	0
									;		SIGNED			NO
									;   LAL_READ		4	
									;		LAL_WRITE		4
									;		Default		45
									;	END		
									
								;	PARAMETER_ENTRY	"Alt Full Accel Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User55
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		150
								;	END		
      					
 								;	PARAMETER_ENTRY	"Alt Low Accel Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User56
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		80
								;	END			
      					
 								;	PARAMETER_ENTRY	"Alt Neutral Decel Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User57
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		15
								;	END			
      					
 								;	PARAMETER_ENTRY	"Alt Full Brake Rate LS"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User58
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		1
								;	END			
      					
 								;	PARAMETER_ENTRY	"Alt Low Brake Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User59
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		5
								;	END			
      					
 								;	PARAMETER_ENTRY	"Alt Partial Decel Rate"
								;		TYPE		PROGRAM
								;		WIDTH		16BIT
								;		ADDRESS		P_User60
								;		MINRAW		100
								;		MINDSP		1
								;		MAXRAW		30000
								;		MAXDSP		300
								;		DECIMALPOS	1
								;		SIGNED		NO
								;		STEP_SIZE	1
								;		UNITS			second
								;   LAL_READ		4	
								;		LAL_WRITE		4
								;		Default		120
								;	END
		
					
		;-------------------------------------
		;	PARAMETER_ENTRY "Output Settings"
		;		TYPE	PROGRAM
		;		LEVEL	2
		;	END
				
			;	PARAMETER_ENTRY	"Brake Light PWM"
			;		TYPE		PROGRAM
			;		WIDTH		16BIT
			;		ADDRESS		P_User12
			;		MINRAW		0
			;		MINDSP		0
			;		MAXRAW		32767
			;		MAXDSP		100
			;		DECIMALPOS	0
			;		LAL_READ	5
			;		LAL_WRITE	5
			;		DEFAULT		30
			;		UNITS			%
			;	END								

			;	PARAMETER_ENTRY	"EVY1 Driver PWM"
			;		TYPE		PROGRAM
			;		WIDTH		16BIT
			;		ADDRESS		P_User16
			;		MINRAW		0
			;		MINDSP		0
			;		MAXRAW		32767
			;		MAXDSP		100
			;		DECIMALPOS	0
			;		LAL_READ	5
			;		LAL_WRITE	5
			;		DEFAULT		15
			;		UNITS			%
			;	END								
		
			;-------------------------------------
			;	PARAMETER_ENTRY "Power steering Settings"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END

				;	PARAMETER_ENTRY	"Power Steering PWM"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User11
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		32767
				;		MAXDSP		100
				;		DECIMALPOS	0
				;		LAL_READ	5
				;		LAL_WRITE	5
				;		DEFAULT		25
				;		UNITS			%
				;	END			
				
				;	PARAMETER_ENTRY	"Power Steer Delay"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User10
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		60
				;		MAXDSP		60
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	1
				;		DEFAULT		1
				;		UNITS		minute
				;	END				
								
	
		;-------------------------------------
		;	PARAMETER_ENTRY "Other Settings"
		;		TYPE	PROGRAM
		;		LEVEL	2
		;	END				
				;	PARAMETER_ENTRY	"BDI Lockout Level"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User30
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		100
				;		MAXDSP		100
				;		DECIMALPOS	0
				;		LAL_READ	4
				;		LAL_WRITE	4
				;		DEFAULT	5
				;		UNITS		%
				;	END					
				
				;	PARAMETER_ENTRY	"Pedal Fault Delay"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User32
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		30000
				;		MAXDSP		300
				;		DECIMALPOS	1
				;		LAL_READ	4
				;		LAL_WRITE	4
				;		DEFAULT	20
				;		UNITS		SECOND
				;	END		
		;-------------------------------------
		;	PARAMETER_ENTRY "Hourmeter Settings"
		;		TYPE	PROGRAM
		;		LEVEL	2
		;	END
			;-------------------------------------
			;	PARAMETER_ENTRY "Maintenance Setting"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END

				;PARAMETER_ENTRY	"Total Maintenance enable"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit1
				;		WIDTH				8Bit
				;		BITSELECT		0
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END
							
				;	PARAMETER_ENTRY	"Total Maintenance Interval"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User1
				;		UNITS		hour
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		30000
				;		MAXDSP		30000
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	5
				;		DEFAULT		30000
				;	END
					
				;PARAMETER_ENTRY	"Traction Maintenance enable"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit1
				;		WIDTH				8Bit
				;		BITSELECT		1
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END					
				
				;	PARAMETER_ENTRY	"Trac Maintenance Interval"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User2
				;		UNITS		hour
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		30000
				;		MAXDSP		30000
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	5
				;		DEFAULT		400
				;	END		
				
				;PARAMETER_ENTRY	"Pump Maintenance enable"
				;   	TYPE			Program
				;		ADDRESS			P_User_Bit2
				;		WIDTH				8Bit
				;		BITSELECT		2
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				; 	DEFAULT			OFF
				;		END					
				
				;	PARAMETER_ENTRY	"Pump Maintenance Interval"
				;		TYPE		PROGRAM
				;		WIDTH		16BIT
				;		ADDRESS		P_User25
				;		UNITS		hour
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		30000
				;		MAXDSP		30000
				;		DECIMALPOS	0
				;		LAL_READ	1
				;		LAL_WRITE	5
				;		DEFAULT		400
				;	END		
				
				;PARAMETER_ENTRY	"Reset Total Maintenance"
				;   TYPE			Program
				;		ADDRESS			User_Bit1
				;		WIDTH			8Bit
				;		BITSELECT		1
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				;		END
				
					;PARAMETER_ENTRY	"Reset Traction Maintenance"
				;   TYPE			Program
				;		ADDRESS			User_Bit1
				;		WIDTH			8Bit
				;		BITSELECT		4
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				;		END					

				;PARAMETER_ENTRY	"Pump Belt Maintenance"
				;   TYPE			Program
				;		ADDRESS			User_Bit2
				;		WIDTH			8Bit
				;		BITSELECT		6
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				;		END							
			;-------------------------------------
			;	PARAMETER_ENTRY "Preset Hourmeters"
			;		TYPE	PROGRAM
			;		LEVEL	3
			;	END		
			
				;PARAMETER_ENTRY "Set New Hours"
				;		TYPE			PROGRAM
				;		ADDRESS			User1
				;		WIDTH			16Bit
				;		MINRAW			0
				;		MAXRAW			20000
				;		MINDSP			0
				;		MAXDSP			20000
				;		SIGNED			No
				;   LAL_READ		5
				;		LAL_WRITE		5
				;		END
				 
				;PARAMETER_ENTRY "Set new Mins"
				;		TYPE			PROGRAM
				;		ADDRESS			User2
				;		WIDTH			16Bit
				;		MINRAW			0
				;		MAXRAW			600
				;		MINDSP			0
				;		MAXDSP			600
				;		SIGNED			No
				;   LAL_READ		5
				;		LAL_WRITE		5
				;		END
				
				;PARAMETER_ENTRY	"Preset Total Hourmeter"
				;   	TYPE			Program
				;		ADDRESS			User_Bit1
				;		WIDTH			8Bit
				;		BITSELECT		0
				;		BITACTIVELOW	NO
				;   LAL_READ		6
				;		LAL_WRITE		6
				;		END
				
				;PARAMETER_ENTRY	"Preset Traction Hourmeter"
				;   	TYPE			Program
				;		ADDRESS			User_Bit1
				;		WIDTH			8Bit
				;		BITSELECT		3
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				;		END
				
				;PARAMETER_ENTRY	"Pump Belt Hourmeter"
				;   	TYPE			Program
				;		ADDRESS			User_Bit2
				;		WIDTH			8Bit
				;		BITSELECT		5
				;		BITACTIVELOW	NO
				;   LAL_READ		4
				;		LAL_WRITE		4
				;		END
				