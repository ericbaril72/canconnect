		;===============================================================
; OS Version 12.0  TLD Generic  VCL program
;=================================================================
;   Copyright © 2009, all rights reserved
;
;   Curtis PMC              			Curtis Balkan Ltd.               
;   235 East Airwary Blvd					Tsar Boris 3 N156
;   Livermore, CA  94551		 	 		 Sofia,Bulgaria         
;   (925)961-1088									+ 359 2 808 14 30
;===============================================================
;									PROJECT DESCRIPTION
;	TLD Europe produces GSE vehicles mainly 20/25T tow tractors, 
;	Belt loaders & hydraulic loader
;	The speed controller used is a 1238-6501 48/80V 550A
;	Display  840R015SBA 6 leds 
;	Pedal  FP-6 
;===============================================================

;###################################### README FIRST ####################################
; 
;====================== INCLUDES ALL PARAMETER DEFINITION ===============================
; VCL in the project root directory Every time you create an EXE file change the specific
; Parameter file with name. TLD_Generic_PARs.VCL. If you add new parameter has to be added
; in all Customer parameter files. For more information see TLD_Generic_PARs
;
	INCLUDE "TLD_Generic_E_Canada_PARs.vcl"
	
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!!!! 				WHEN YOU CHANGE VERSION OF THE PROGRAM YOU NEED TO CHANGE 							!!!!!!!!!
;	!!!!!!!!!!!!!!! VEHICLE NAME TO NEXT REVISION in Process Display routine .for example 7900196B  !!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;-------------------------------------------------------------------------------------
;   Revision History (reflected in the VCL App Version variable that is displayed on the 1311)
;-------------------------------------------------------------------------------------
;
;	22/Oct/2009 	- A.Stamenov V1.00 First Release 
;	16/Nov/2009		- A.Stamenov V1.01 Bug fixed in inching
;	26.Feb.2010		- A.Stamenov V1.02 Bug fixed new features added 
;									- Bug fixed in inching when Authorization is enabled Inching is not possible
;									- Parameter default changed
;									- Basic CAN messages are implemented 
;	12.Mar.2010		- A.Stamenov V1.03 Bug fixed new features added 
;									- Belt Loader functionality added 
;									- Pump Hourmeter added
; 10/Mar/2011		- A.Stamenov V104 Added Display Fault routine 
; 18/Apr/2011		- A.Stamenov V105 Pump Will be not activated in Case of Handbrake is off 
; 20/Apr/2011		- A.Stamenov V106 Hourmeter control and name changed as follow
;									- Total Hourmeter activated at startup
;									- Traction Hourmeter Activated at Vehicle Movement
;									- Belt Hourmeteter renamed to Pump Hourmeter and activated when pump is running 
; 08/Aug/2011		- A.Stamenov V107 ABS vehicle name display name changed
; 26/Sept/2011	- F.Le Gars V108  ABS vehicule name displayed changed  
; 08/Dec/2011		- A.Stamenov V109  New vehicle added including Special EM Brake type
; 30.01.2012		- A.Stamenov V110	Added Pedal faulted in Case both pedals are pressed.
; 20/08/2012		- F.Le Gars V111 add JET16 OS 12 name
; 03/Jan/2013		- A.Stamenov V112 Inching function safety issue bug fixed
; 05/Jun/2013		- J.Kusseling V113 Added a Docking_speed_sw on sw16, with a new docking speed in the multimode
;									- Reorganized the multimode process according to customer's specifications
;	11/Jun/2013			- Modified "BDI Low/Pump Fault" mode to be accessed by any pump faults.
;									- Updated defaults
;									- Updated displayed program number on spyglass
; 24/Jun/2013			- new ABS traction 1077220A / ABS hydraulic belt 1077222A
;								- J.Kusseling v114 is a special edition not to be used as a generic.
; 05/Dec/2013		- J.Kusseling V115 Aircraft Safe Docking (ASD) function
;									- Added Odometer on Display
;									- Added Total_HM_scaled on CAN
;	11/Apr/2014			- Added Metric units display parameter
;	07/Aug/2018   - GB - V116 -	For OS26 (Patch BDI + Vehicle name refresh)
; 27/May/2020		- MB - V122 based on V116 for TLD CANADA usage. 
; 11/Aou/2020		- MB - V123 With project specific for Canada according to specific need of TLD Canada
; 17/Aou/2020		- MB				Some ajustements asked by TLD related to last changes
; 01/Oct/2020 	- MB	V124	Changes on CAN setup to allow the usage of Can-open PDO (managed by SDO) as requested by TLD Canada. 1249565_B
VCL_App_Ver = 124 	;Set VCL software revision 

if ((BDI_percentage > 100) | (BDI_Percentage < 0)) {BDI_Percentage = 100}

;===============================================================
;											DECLARATION
; Variable and Constant Declarations - These are generally placed
; at the beginning of the program to allow easier management of
; VCL user variables.
;===============================================================
;****************************************
; 					 CONSTANTS 
;****************************************
	;------------ FAULT CONSTANTS ------------
	Shutdown_Motor          constant    0x0001
	Shutdown_Main_Contactor constant    0x0002
	Shutdown_EMBrake        constant    0x0004
	Shutdown_Throttle       constant    0x0008
	Shutdown_Interlock      constant    0x0010
	Shutdown_Driver1        constant    0x0020
	Shutdown_Driver2        constant    0x0040
	Shutdown_Driver3        constant    0x0080
	Shutdown_Driver4        constant    0x0100
	Shutdown_PD             constant    0x0200
	Full_Brake              constant    0x0400
	Shutdown_Pump           constant    0x0800
	Trim_Disable            constant    0x1000
	Severe_Dual             constant    0x2000
	Shutdown_Steer          constant    0x4000
	LOS_Dual                constant    0x8000
	;---------- PDO MESSAGE CONSTANTS	-----------
	Error_message								constant 1						
	PDO2_MISO 									constant 5
	PDO2_MOSI 									constant 6
	PDO3_MISO 									constant 7
	PDO3_MOSI 									constant 8
	PDO4_MISO 									constant 9
	PDO4_MOSI 									constant 10	
	;----------- DISPLAY constants ------------
	; Used to trigger all SPY messages 
	SPY_STATE_Service_DUE		constant	0
	SPY_STATE_Total_HM_N		constant	1
	SPY_STATE_Total_HM_V		constant	2
	SPY_STATE_INTERLOCK_ON	constant	3
	SPY_STATE_INTERLOCK_OFF	constant	4
	SPY_STATE_TRAC_HM_N			constant	5
	SPY_STATE_TRAC_HM_V			constant	6
	SPY_STATE_PUMP_HM_N			constant	7
	SPY_STATE_PUMP_HM_V			constant	8
	SPY_STATE_ODOMETER_N		constant	9
	SPY_STATE_ODOMETER_V		constant	10
	SPY_STATE_FAULT					constant	11
	SPY_STATE_BDI_LOW				constant	12
	SPY_STATE_CUSTOMER			constant	13
	SPY_STATE_TOTAL_M_N			constant	14
	SPY_STATE_TOTAL_M_V			constant	15
	SPY_STATE_TRAC_M_N			constant	16
	SPY_STATE_TRAC_M_V			constant	17
	SPY_STATE_VEH_NAME			constant	18
	SPY_STATE_VEH_TYPE			constant	19
	SPY_STATE_NBL_TYPE			constant	20
	SPY_STATE_PUMP_M_N			constant	21
	SPY_STATE_PUMP_M_V			constant	22
	;-------- 840 Display constants ---------
	LED_Red_6									constant 0x0100		
	LED_Red_Flashing_6				constant 0x0400		
	;------- MESSAGE Upadate delay -------
	Message_update_delay		constant	1500
	;---- SEQUENCE FAULT CONSTANTS ----
	INITIAL									constant	0
	DIRECTION_SELECTED			constant	1
	FINISHED								constant	2
	;----------------------------------
	SEQ_NOT_READY						constant	0
	SEQ_OK									constant	1
	SEQ_Faulted							constant	2
	;------------- DRIVE STATES ----------
	Drive_state_Autorized		constant	0
	Drive_state_Belt_Run		constant	1
	Drive_state_Faulted			constant	2
	Drive_state_Braking			constant	3
	
;****************************************
; 			 			USER VARIABLES
;****************************************
;----- HOUR METER VARIABLES--------------
	New_hours_value						alias	User1	;1311 params used in Preset of Hour Meters
	Minutes										alias	User2	;1311 params used in Preset of Hour Meters
	Six_Secs									alias	User3	;Variable used in Preset of Hour Meters
	Total_HM_maint_exp_time		alias User4
	Trac_HM_maint_exp_time		alias User5
	Total_HM_scaled						alias User6
	Trac_HM_scaled						alias User7
	;--------- DISPLAY VARIABLES ----------
	LED_Output								alias User8
	Display_State							alias	User9
	Fault_Code 								alias	User10		;intermediate fault code for display
	Fault_Pointer							alias	User11
	Fault_Flash_Code				 	alias	User12	;actual flash code for displa
	main_message_temp					alias User28
	;----------------------------------
	Sequence_state						alias User13
	Sequence_Status						alias User14
	Vehicle_speed_scaled			alias User15
	Display_state_interlock 	alias User16
	OS_throttle_TEMP					alias User17
	OS_Throttle_Reverse_limit	alias User18
	Drive_state								alias User19
	;----- PUMP HOURMETER VARIABLES -------
	Pump_HM_maint_exp_time		alias User20
	Pump_HM_scaled						alias User21

	Max_Speed_Temp						alias User22
  CAN_CRC										alias User23
	CAN_Max_Speed_MH					alias User24
	CAN_Fault_Flash_Code_Pump	alias User25
	Fault_display_state				alias User26
	Inching_fault_State				alias User27
	CAN_Max_Speed_Spdm				alias User28
;	ALREADY USED							alias User28
	;----- Aircraft Safe Docking -----
	Scaled_rpm_high_threshold	alias User29
	Scaled_rpm_low_threshold	alias User30
	CAN_Received_Empty1				alias User32
	CAN_Received_Empty2				alias User33
	CAN_Received_Empty3				alias User34

	;------ NV USER VARIABLES -------------
	Last_total_maintanance		alias nvuser2
	Last_trac_maintanance			alias nvuser3
	Last_Pump_maintanance			alias nvuser4	
;	Saved_Soft_Stop_Speed			alias nvuser5
;****************************************
; 					 I/O Requirements
;****************************************	 
	
;-------------- INPUTS ------------------
	Low_speed_sw				alias Sw_1
	Pedal_sw						alias Sw_3
	Inching_sw 					alias Sw_4
	Brake_sw						alias Sw_5
	HandBrake_sw				alias Sw_6
	Forward_sw					alias Sw_7
	Inching_FWD_sw_up		alias Sw_7_up
	Reverse_sw					alias Sw_8
	Inching_REV_sw_up		alias Sw_8_up
	Deadman_sw					alias Sw_15
	Docking_speed_sw		alias Sw_16
	;-------------- OUTPUTS -----------------
	Option2_Output			alias PWM2
	Brake_lights				alias PWM3
	Pump_driver					alias PWM4
	Pump_driver_output	alias PWM4_output
	EVY1_Driver					alias PWM5			
;****************************************         
; 						BIT DEFINITION
;****************************************
Hourmeter_flags				alias User_bit1
	;-------------- TOTAL TIMER ---------------
	Set_Total_HM					bit	Hourmeter_flags.1
	Reset_Total_HM_maint	bit	Hourmeter_flags.2
	Total_maint_expired		bit	Hourmeter_flags.4
	;------------- TRACTION TIMER -------------
	Set_Trac_HM						bit	Hourmeter_flags.8
	Reset_Trac_HM_maint		bit	Hourmeter_flags.16
	Trac_maint_expired		bit	Hourmeter_flags.32
	Traction_active_flag	bit Hourmeter_flags.64

;---------------------------------------------
Program_flags1					alias User_bit2
	Inching_active_flag			bit	Program_flags1.1
	Inching_intlk_state			bit Program_flags1.2
	BDI_drv_trigger_flag		bit Program_flags1.4
	Forward_sw_temp					bit	Program_flags1.8
	Reverse_sw_temp					bit	Program_flags1.16
	;---------------- PUMP HOURMETER FLAGS ------
	Set_Pump_HM							bit	Program_flags1.32
	Reset_Pump_HM_maint			bit	Program_flags1.64
	Pump_maint_expired			bit	Program_flags1.128
	;-------------- PUMP SLAVE STATUS ---------------------
CAN_Pump_status								alias User_bit3
	CAN_Pump_hourmeter_ON					bit	CAN_Pump_status.1
	CAN_Pump_Drive_disable				bit	CAN_Pump_status.2
	CAN_Pump_Ignition_protection	bit	CAN_Pump_status.4
	CAN_Belt_hourMeter_ON					bit	CAN_Pump_status.8
	CAN_Pump_faulted_flag					bit	CAN_Pump_status.16		
	;-------------- PUMP Commands From Master -----------
CAN_Pump_Commands							alias User_Bit4
	CAN_Start_pump_from_drive			bit	CAN_Pump_Commands.1
	CAN_Disable_Belt							bit	CAN_Pump_Commands.2
	CAN_Neutral_direction_flag		bit	CAN_Pump_Commands.4	
	;--------------- CONTROLLER OUTPUTS -------------------
CAN_Controller_outputs				alias User_bit6
		CAN_Driver1									bit	CAN_Controller_outputs.1
		CAN_Driver2									bit	CAN_Controller_outputs.2
		CAN_Driver3									bit	CAN_Controller_outputs.4
		CAN_Driver4									bit	CAN_Controller_outputs.8
		CAN_Driver5									bit	CAN_Controller_outputs.16	
		CAN_Status_Brake_Requested	bit	CAN_Controller_outputs.32	
		CAN_Status_PLC_Trame				bit CAN_Controller_outputs.64
	;------------- PROGRAM FLAGS 2 ------------------------
	Program_flags2								alias User_bit7
 		Fault_displayed_flag					bit	Program_flags2.1		
 		Type3_pump_startup_flag				bit	Program_flags2.2	
 		Inching_startup_fault_check_flag		bit	Program_flags2.4
 		ASD_set_brake_flag1						bit Program_flags2.8
 		ASD_set_brake_flag2						bit	Program_flags2.16
 		Saved_ASD_Active_bit					bit	Program_flags2.32
 		
 		
 		CAN_PLC_command							alias User_bit8
 			CAN_Brake_Requested					bit	CAN_PLC_command.1
 			CAN_Opt_no_touch_bit				bit CAN_PLC_command.2
 			CAN_ASD_Active_bit					bit CAN_PLC_command.4
 			CAN_Controle_Alternatif			bit CAN_PLC_command.8
 			CAN_Erreur_Left							bit CAN_PLC_command.16
 			CAN_Erreur_Right						bit CAN_PLC_command.32
;****************************************         
; 	AUTOMATIC FUNCTION DEFINITION
;****************************************
	ABS_OS_throttle				alias abs1_output
	ABS_Distance_fine			alias abs2_output	
	OS_Throttle_NBLAF			alias lim1_output
;****************************************         
; 						OTHER DEFINITION
;****************************************
;--------------- DELAYS -----------------
	Display_update_DLY								alias DLY1
	Display_update_DLY_output					alias DLY1_output
	Display_State_DLY									alias DLY2
	Display_State_DLY_output					alias DLY2_output
	BDI_DRV_Trigger_DLY								alias DLY3
	BDI_DRV_Trigger_DLY_output				alias DLY3_output
	Startup_DLY												alias DLY4
	Startup_DLY_output								alias DLY4_output
	Deadman_fault_DLY									alias DLY5
	Deadman_fault_DLY_output					alias DLY5_output
	Inching_Delay											alias DLY6	
	Inching_Delay_Output							alias DLY6_output
	Power_Steering_DLY								alias DLY7
	Power_Steering_DLY_output					alias DLY7_output
	Interlock_DLY											alias DLY8
	Interlock_DLY_output							alias DLY8_output
	Inching_inactive_DLY							alias DLY9
	Inching_inactive_DLY_output				alias DLY9_output
	Inching_startUP_DLY								alias DLY10
	Inching_startUP_DLY_output				alias DLY10_output
	Current_load_delay								alias DLY11
	Current_load_delay_Output					alias DLY11_Output
	Pump_Startup_DLY									alias DLY12
	Pump_Startup_DLY_output						alias DLY12_output
	PDO_Pump_check_DLY								alias DLY13	
	PDO_Pump_check_DLY_output					alias DLY13_output
	type3_Handbrake_fault_DLY					alias DLY14	
	type3_Handbrake_fault_DLY_output	alias DLY14_output
	type3_Brk_release_DLY							alias DLY15
	type3_Brk_release_DLY_output			alias DLY15_output
	Pedal_fault_DLY										alias DLY16
	Pedal_fault_DLY_output   					alias DLY16_output
	Inching_check_DLY									alias DLY17
	Inching_check_DLY_output					alias DLY17_output
	PDO_PLC_timeout_DLY								alias DLY18
	PDO_PLC_timeout_DLY_output				alias DLY18_output
	LoopTest													alias DLY19
	LoopTest_output										alias DLY19_output

Create	Data0_valid	variable
Create	Data1_valid variable
Create	Data2_valid variable
Create	Data3_valid variable
Create	Data4_valid variable
Create	Data5_valid variable
Create	CRC_In_valid variable
Create	CRC_Calc	variable
Create	Bit_Counter variable
Create	Fault_Counter variable
Create	CRC_Seed variable
Create	LoopDuration variable

Fault_Counter = 0
CRC_Seed = 0xE36C
		                                	
	;--------------- TIMER DEFINITION -----------------
	Total_hourmeter						alias TMR1
	Total_hourmeter_Hr				alias	TMR1_Hr_Output
	Total_hourmeter_Sec				alias	TMR1_Sec_Output
	Total_hourmeter_enable		alias TMR1_enable
	
	Traction_hourmeter				alias TMR2
	Trac_hourmeter_Hr					alias	TMR2_Hr_Output
	Trac_hourmeter_Sec				alias	TMR2_Sec_Output
	Pump_hourmeter						alias TMR3
	Pump_hourmeter_Hr					alias	TMR3_Hr_Output
	Pump_hourmeter_Sec				alias	TMR3_Sec_Output
	;-----------------------------------------------
	
	CAN_MB_To_IFM1							alias CAN1
	CAN_MB_To_IFM2              alias CAN2
	;CAN3 reserved for Can-Open DUAL DRIVE MISO/TX (not used in this project)
	;CAN4 reserved for Can-Open DUAL DRIVE MOSI/RX (not used in this project)
	;CAN5 reserved for CAN Open Emergency PROTOCOL
	;CAN6 reserved for CAN Open Emergency PROTOCOL
	;CAN7 reserved for CAN Open NMT
	;CAN8 reserved for CAN Open Heartbeat
	;CAN9  reserved for CAN-OPEN SDO-MISO/TX
	;CAN10 reserved for CAN-OPEN SDO-MOSI/RX
	;CAN11 reserved for CAN-OPEN PDO1 - MISO/TX
	;CAN12 reserved for CAN-OPEN PDO1 - MOSI/RX
	;CAN13 reserved for CAN-OPEN PDO2 - MISO/TX
	;CAN14 reserved for CAN-OPEN PDO2 - MOSI/RX
	CAN_MB_To_IFM3              alias CAN15
	CAN_MB_To_IFM4							alias CAN16
	CAN_MB_To_Pump              alias CAN17
	CAN_MB_From_Pump						alias CAN18
	CAN_MB_From_Pump_Received		alias CAN18_received
	CAN_MB_From_PLC							alias CAN19
	CAN_MB_From_PLC_Received		alias CAN19_received
;****************************************         
; 			USER FAULT DEFINITION
;****************************************
	Custom_HPD								bit UserFault1.1 ;  
	Custom_SRO								bit UserFault1.2 ; 
	Inching_Fault							bit	UserFault1.4
	Deadman_fault							bit	UserFault1.8
	PDO_Timeout_Pump					bit	UserFault1.16
	Wrong_Sequence_fault			bit UserFault1.32
	Handbrake_fault						bit	UserFault1.64
	Pump_faulted							bit	UserFault1.128
	;--------------------------------------------
	Pedal_faulted							bit	UserFault2.1
	Err_Capteur_Left					bit	UserFault2.2
	Err_Capteur_Right					bit	UserFault2.4
	PDO_PLC_timeout   				bit	UserFault2.8
	CAN_CRC_fault 						bit	UserFault2.16
	
	;--------- USER FAULT ACTIONS -----------
	User_Fault_Action_01	=	Shutdown_Throttle 	;Fault action for Custom HPD
	User_Fault_Action_02	=	Shutdown_Throttle 	;Fault action for Custom SRO
	User_Fault_Action_03 	= Shutdown_Throttle		;Fault action for Inching Fault
	User_Fault_Action_04	=	Shutdown_Throttle		;Fault action for Deadman Fault
	User_Fault_Action_05	= 0										;Fault action for Pump PDO timeout
	User_Fault_Action_06	=	Shutdown_Throttle		;Fault action for Sequencing Fault
	User_Fault_Action_07	= 0										;Fault action for HandBrake Fault
	User_Fault_Action_08	= 0										;Fault action for Pump in  Fault
	User_Fault_Action_09	=	Shutdown_Throttle		;Fault action for Pedal faulted
	
;========================================================================
;                    ONE TIME INITIALISATION
; RAM variables should be initialized to a known value before starting
; execution of VCL logic.  All other tasks that need to be performed at
; startup but not during main loop execution should be placed here.
; Signal chains should be set up here as well.
;========================================================================
;================================================================
;											ABS FUNCTIONS 
;================================================================
	Automate_ABS(ABS1,OS_throttle) 		; OS throtle is always positive
	Automate_ABS(ABS2,Distance_fine) ; Distance fine used for inching
	;-------------------- LIMIT THE OS THROTTLE TO 100% for NBL AF 
	OS_Throttle_Reverse_limit = 32767
	Setup_limit(LIM1,HARD_UPPER_UNSIGNED,0) ; Set the limit for the NBLAF option
	Automate_limit(LIM1,@OS_throttle_TEMP,@OS_Throttle_Reverse_limit)
	;------------------- START THE INTERLOCK AT THE BEGINING ---------------
	Set_interlock()
	Setup_Delay(Interlock_DLY,30000)
	;-------------------------------------------------------------------------
	SETUP_DELAY_PRESCALE(Current_load_delay,1000); set the timer to be one second tick
	SETUP_DELAY_PRESCALE(Power_Steering_DLY,60000)	
;	Full_Brake_Rate_LS_SpdM = PAR_Normal_Full_Brake_Rate_LS
	;---------------------------------------------
	Setup_Delay(Pump_Startup_DLY,1000); Give time for pump to start 
	Setup_Delay(PDO_PLC_timeout_DLY, 10000)
	
	Setup_Delay(Startup_DLY,800)
	while(Startup_DLY_output <> 0){}
	VCL_Throttle_Enable_Bit0  = On
	;---------- RESET INCHING UPS for next inching  -----------------	
	Inching_FWD_sw_up = Off
	Inching_REV_sw_up = Off
	;--------------------------
	Setup_Delay(Display_State_DLY,2500) ; Wait before sending messages for Spy to power up
	;================ SET THE HPD SRO FAULTS =============================
	;-------------- CUSTOM SRO --------------------
	if(Forward_sw = On)|(Reverse_sw = On) ; If the inching command is requested at startup 
		{
		Custom_SRO = On
		}
	;-------------- CUSTOM HPD --------------------
	if(Pedal_sw = On)&(Inching_sw = Off) ; If Throttle Pedal is pressed at startup
		{
		Custom_HPD = On
		}
		
		;if(Saved_Soft_Stop_Speed = 0){Saved_Soft_Stop_Speed = 100}

	call startup_CAN_System	
	;============== ACTIVATE TOTAL HOURMETER =======================
	Enable_Timer(Total_hourmeter)		

	Setup_Delay(type3_Handbrake_fault_DLY,10000)	
;========================================================================
;                       MAIN PROGRAM LOOP
; The continuously running portion of the program should be placed here
; It is important to structure the main loop such that there is no
; possibility for the program to get stuck in a loop that will prevent
; important vehicle functions from occuring regularly.  Be particularly
; careful with while loops.  Use of signal chains and automated functions
; as described in the VCL documentation can greatly reduce the complexity
; of the main loop.
;========================================================================
main:	
	call Process_multimode

	call Process_faults

	call Process_Drive
	
	call Process_outputs
		
	
	call Process_Hourmeters

	call Process_States	
	
	;-------------  SPY GLASS UPDATE ----------------
	; The speed of updtating the spy glass need to be reduced 
	;	to have better access to serial port. 
	if(Display_update_DLY_output = 0)	;information transfer every 100msec
		{
		call Process_Display
		Setup_Delay(Display_update_DLY,100)		
		}
	;-------------- PROCESS INTERLOCK ---------------------
	; Activate the interlock if the operator is in cabine or Inching is requested 
	if (deadman_sw = On)|(Inching_active_flag =  On)|(ABS_Motor_RPM <> 0)		
		{
		Set_interlock()
		Setup_Delay(Interlock_DLY,30000)
		}
	else
		{
		;----------------- CLEAR INTERLOCK ----------------
		; Clear interlock if the vehicle is not used for more than 3 second and not moving 
		; Also interlock will be not cleared if the pump group is running
		if(Interlock_DLY_output = 0)&(Motor_RPM = 0)&(Traction_active_flag = Off)
			{
			clear_interlock()
			Inching_intlk_state = Off	; Allow next delay for Inching startup
			} 
		}
		
	goto main

;========================================================================
;                          SUBROUTINES
; As with any programming language, the use of subroutines can allow
; easier re-use of code across multiple parts of a program, and across
; programs.  Function specific subroutines can also improve the
; Readability of the code in the main loop.
;========================================================================

;===================================================
;							PROCESS DRIVE
;===================================================
Process_Drive:
	;--------------- SET THE BRAKE ---------------
	; If a brake sw is pressed we stop imidiattely or if the Belt is active
	if(Brake_sw = On)|(CAN_Pump_Drive_disable = On)|((PAR_Proximity_Sensor = On)&&(CAN_Brake_Requested = On)&&(CAN_Opt_no_touch_bit = On)&&(CAN_ASD_Active_bit = On)&&(CAN_Status_PLC_Trame = On)&&(Err_Capteur_Left = Off)&&(Err_Capteur_Right = Off))
		{
		VCL_Brake = 32767
			if((PAR_Proximity_Sensor = On)&&(CAN_Brake_Requested = On)&&(CAN_Opt_no_touch_bit = On)&&(CAN_ASD_Active_bit = On)&&(CAN_Status_PLC_Trame = On)&&(Err_Capteur_Left = Off)&&(Err_Capteur_Right = Off))
			{
				CAN_Status_Brake_Requested = On
				Soft_Stop_Speed = 0
			}
		}
;=========================== Aircraft Safe Docking function ===========================
	else if(Inching_sw = Off)&(low_speed_sw = On) ;Speed < 5km/h because low_speed_sw = On
	{
	;Full_Brake_Rate_LS_SpdM = PAR_ASD_Full_Brake_Rate_LS
	Scaled_rpm_high_threshold = PAR_Max_speed_dock_FWD + PAR_ASD_high_delta
	Scaled_rpm_low_threshold = PAR_Max_speed_dock_FWD + PAR_ASD_low_delta
	;------ speed needs to be reduced with VCL Brake ------
	if((docking_speed_sw = on)&(motor_rpm > Scaled_rpm_high_threshold))|(ASD_set_brake_flag1 = on)
		{
		VCL_Brake = 32767
		if(motor_rpm <= PAR_release_brake_speed_after_high) ; speed went below threshold, exit reduced speed mode
			{
			ASD_set_brake_flag1 = off
			}
		else {ASD_set_brake_flag1 = on}
		}
	else if ((docking_speed_sw = on)&(motor_rpm > Scaled_rpm_low_threshold))|(ASD_set_brake_flag2 = on)
		{
		VCL_Brake = 32767
		if(motor_rpm <= PAR_release_brake_speed_after_low) ; speed went below threshold, exit reduced speed mode
			{
			ASD_set_brake_flag2 = off
			}
		else {ASD_set_brake_flag2 = on}
		}
	else 
		{
		ASD_set_brake_flag1 = off
		ASD_set_brake_flag2 = off
		VCL_Brake = 0
		}
	}
	;--------------- RELEASE THE BRAKE ------------
	else 
		{
		VCL_Brake = 0
		;Full_Brake_Rate_LS_SpdM = PAR_Normal_Full_Brake_Rate_LS
		}


	;========================= DRIVING =======================
	; If NBL AF or ABS is used creep speed will be available even if the pedal is not pressed 
	if(Deadman_sw = On)&(HandBrake_sw = On)&(VCL_Brake = 0)&(Inching_sw = Off)&
		((Pedal_sw = On)|(PAR_REV_creep_spd_enable = On))
		{
		Inching_active_flag = Off	
		;--------------- MOVE FORWARD -------------
		if(Forward_sw = On)&(Reverse_sw = Off)
			{
			VCL_Throttle = ABS_OS_throttle
			}
		;--------------- MOVE REVERSE --------------
		else if(Forward_sw = Off)&(Reverse_sw = On)
			{
			;----------------- NBL AF REVERSE SET --------------  
			; Cutomer requested to have creep speed for NBL AF to 
			if(PAR_REV_creep_spd_enable = On)
				{
				OS_throttle_TEMP = ABS_OS_throttle + PAR_Offset_Throttle
				VCL_Throttle = -OS_Throttle_NBLAF
				}
			;---------------- OTHER REVERSE SET -------------
			else
				{
				VCL_Throttle = - ABS_OS_throttle
				}
			}
		;-------------- NO DIRECTION ----------
		else
			{
			VCL_Throttle = 0
			}
			
		}
	;========================== INCHING =========================
	; Inching is allowed only if no operator is present in cabine and no cabine command is given
	else if (Deadman_sw = Off)&(HandBrake_sw = Off)&(Pedal_sw = Off)&(VCL_brake = 0)&(Inching_sw = On)&&(Inching_Fault = off)
		{
		;---------------- INCHING FORWARD --------------	
		; Vehicle will move until nessesary distance is reached. 
		; This control will give more accurate control for the inching which will be based on travelled distance
		if(Forward_sw = On)&(Reverse_sw  = Off)
			{	
			if(Inching_Delay_Output <> 0)&(Inching_startUP_DLY_output = 0)&(ABS_Distance_fine <=PAR_inching_Distance)
				{
				Reset_Distance_Fine_Bit0 = Off ; Reset distance fine so inching will move sertain time			
				VCL_Throttle = 32767
				}
			else
				{
				VCL_Throttle = 0
				}
			}		
		;---------------- INCHING REVERSE --------------	
		else if(Forward_sw = Off)&(Reverse_sw = On)
			{
			if(Inching_Delay_Output <> 0)&(Inching_startUP_DLY_output = 0)&(ABS_Distance_fine <=PAR_inching_Distance)
				{	
				Reset_Distance_Fine_Bit0 = Off ; Reset distance fine so inching will move sertain time	
				VCL_Throttle = - 32767
				}
			else
				{
				VCL_Throttle = 0
				}
			}
		;-------------- WAITING ------------------------		
		else
			{
			;--------- INACTIVE DELAY CHECK --------
			; If no inching is requested for more than 7 second interlock will be cleared  
			if(Inching_inactive_DLY_output = 0)
				{
				Inching_active_flag = Off
				}
			VCL_Throttle = 0
			}

		;-------------- INCHING INITIALISATION -------------------
		if(Inching_FWD_sw_up = On)|(Inching_REV_sw_up = On)
			{
			Reset_Distance_Fine_Bit0 = On ; Reset distance fine so inching will move sertain time
			Max_Speed_SpdM = PAR_Max_speed_inching ; Set the Inching speed immidiately
			Setup_Delay(Inching_inactive_DLY,30000); Set a inactive delay for 30 sec
			Inching_active_flag = On			
			Inching_FWD_sw_up = Off
			Inching_REV_sw_up = Off
			Setup_Delay(Inching_Delay, PAR_Inching_Timeout)
			;----------- INTERLOCK STATE DELAY  ------------
			;Make sure interlock is on 100 ms are expired before using Inhcing -> to avoid HPD sequening fault
			if(Inching_intlk_state = Off)
				{
				Inching_intlk_state = On
				Setup_Delay(Inching_startUP_DLY,150); Throttle command can be received when Interlock is on after  100ms 
				}
			}
		}
	;================== NO MOVEMENT ALLOWED ===============
	else
		{
		Inching_active_flag = Off	
		VCL_Throttle = 0			
		}
	return
;===================================================
;							PROCESS STATES
;===================================================
Process_States:	
	;================ DRIVE STATE SET ===============
	;-------------- MOVEMENT IS disabled because of Belt --
	if(CAN_Pump_Drive_disable = On)
		{
		Drive_state =Drive_state_Belt_Run
		}
	;------------- FAULT ACTIVE Movement is disabled ---
	else if (Fault_count <> 0)
		{
		Drive_state	= Drive_state_Faulted
		}
	else if (VCL_Brake <> 0)
		{
		Drive_state = Drive_state_Braking
		}
	;------------ Movement is autorized -------------
	else 
		{
		Drive_state	= Drive_state_Autorized
		}	

	;=============== SET BIT STATE OF OUTPUTS ============
	;-------------- SET DRIVER1 OUTPUT STATE --------------
	if(PWM1_output > 100)
		{
		CAN_Driver1 = On
		}
	else
		{
		CAN_Driver1 = Off
		}
	;-------------- SET DRIVER2 OUTPUT STATE --------------
	if(PWM2_output > 100)
		{
		CAN_Driver2 = On
		}
	else
		{
		CAN_Driver2 = Off
		}
	;-------------- SET DRIVER3 OUTPUT STATE --------------
	if(PWM3_output > 100)
		{
		CAN_Driver3 = On
		}
	else
		{
		CAN_Driver3 = Off
		}
	;-------------- SET DRIVER4 OUTPUT STATE --------------
	if(PWM4_output > 100)
		{
		CAN_Driver4 = On
		}
	else
		{
		CAN_Driver4 = Off
		}
	;-------------- SET DRIVER5 OUTPUT STATE --------------
	if(PD_output > 100)
		{
		CAN_Driver5 = On
		}
	else
		{
		CAN_Driver5 = Off
		}
	;=================== NEUTRAL STATE SET =============
	if(Forward_Sw = Off)&(Reverse_sw = Off)
		{
		CAN_Neutral_direction_flag = On	
		}
	else
		{
		CAN_Neutral_direction_flag = Off	
		}		
		
		if((PAR_Proximity_Sensor = Off)||(CAN_Brake_Requested = Off))
			{
				CAN_Status_Brake_Requested = Off
				Soft_Stop_Speed =50
			}
	;---------------- DISABLE BELT STATE ---------------	
	; Belt Will disabled in case of Handbrake is off or 
	; BD is low	
	if(BDI_Percentage <=PAR_BDI_LOW_level)|(Handbrake_sw = On)
		{
		CAN_Disable_Belt = On
		}
	else
		{
		CAN_Disable_Belt = Off
		}				
	return
;===================================================
;							PROCESS MULTIMODE
;===================================================
Process_multimode:
	;------------------- INCHING SPEED SET --------------------
	if(Inching_active_flag = On)
		{
		Max_Speed_Temp = PAR_Max_speed_inching 
		} 
	
	;------------------ BDI LOW MAX SPEED SET -----------------
	; If Docking speed is slower than BDI_LOW speed, it will be selected instead
	else if(BDI_percentage <= PAR_BDI_LOW_level )|(PDO_Timeout_Pump = On)|(Pump_faulted = On)
		{
			if(Docking_speed_sw = On)&(Forward_sw = On)&(Reverse_sw = Off)&(PAR_Max_speed_dock_FWD < PAR_Max_speed_BDI_LOW)
			{
			Max_Speed_Temp = PAR_Max_speed_dock_FWD
			}
			else if(Docking_speed_sw = On)&(Forward_sw = Off)&(Reverse_sw = On)&(PAR_Max_speed_dock_REV < PAR_Max_speed_BDI_LOW)
			{
			Max_Speed_Temp = PAR_Max_speed_dock_REV
			}
			else
			{
			Max_Speed_Temp = PAR_Max_speed_BDI_LOW
			}
		}
	;-------------------- FORWARD DOCKING MAX SPEED SET --------		
	else if(Forward_sw = On)&(Reverse_sw = Off)&(Docking_speed_sw = On)
		{
		Max_Speed_Temp = PAR_Max_speed_dock_FWD
		}
	;-------------------- REVERSE DOCKING MAX SPEED SET --------		
	else if(Forward_sw = Off)&(Reverse_sw = On)&(Docking_speed_sw = On)
		{
		Max_Speed_Temp = PAR_Max_speed_dock_REV
		}
	;-------------------- FORWARD LOW MAX SPEED SET -------- 
	else if(Forward_sw = On)&(Reverse_sw = Off)&(Low_speed_sw = On)
		{
		Max_Speed_Temp = PAR_Max_speed_LOW_FWD
		}
	;-------------------- REVERSE LOW MAX SPEED SET -------- 
	else if(Forward_sw = Off)&(Reverse_sw = On)&(Low_speed_sw = On)
		{
		Max_Speed_Temp = PAR_Max_speed_LOW_REV
		}
	;-------------------- FORWARD NORMAL MAX SPEED SET -------- 
	else if(Forward_sw = On)&(Reverse_sw = Off)&(Low_speed_sw = Off)
		{
		Max_Speed_Temp = PAR_Max_speed_Normal_FWD
		}
	;-------------------- REVERSE NORMAL MAX SPEED SET -------- 
	else if(Forward_sw = Off)&(Reverse_sw = On)&(Low_speed_sw = Off)
		{
		Max_Speed_Temp = PAR_Max_speed_Normal_REV
		}	
	;------------------- NO DIRECTION SELECTED -------------
	else 
		{
		Max_Speed_Temp = PAR_Max_speed_BDI_LOW	
		}	
	
	CAN_Max_Speed_SPDM = MULDIV(CAN_Max_Speed_MH, Speed_to_rpm,10000);
	
	if(CAN_Status_PLC_Trame = Off)||(Err_Capteur_Left = ON)||(Err_Capteur_Right = ON){
		if(Docking_speed_sw = Off)&&(CAN_Status_PLC_Trame = Off){Max_Speed_SpdM = PAR_Max_speed_LOW_FWD};&&(Docking_speed_sw = Off)
		else if(CAN_Status_PLC_Trame = On)&&((Err_Capteur_Left = ON)||(Err_Capteur_Right = ON))&&(CAN_ASD_Active_bit = Off)&&(Saved_ASD_Active_bit = Off){Max_Speed_SpdM = PAR_Max_speed_LOW_FWD}
		else{
					Max_Speed_SpdM = PAR_Max_speed_dock_FWD
					if(Saved_ASD_Active_bit = Off)&&(CAN_ASD_Active_bit = On){Saved_ASD_Active_bit = On}
				}
	}
	else if(CAN_Opt_no_touch_bit = On)&&(CAN_Status_PLC_Trame = On){
		if(CAN_Max_Speed_SPDM < 0){Max_Speed_SpdM = 0}
		else if(CAN_Max_Speed_SPDM < PAR_Max_speed_Normal_FWD){Max_Speed_SpdM = CAN_Max_Speed_SPDM}
		else{Max_Speed_SpdM = PAR_Max_speed_Normal_FWD}
	}
	else{
		Max_Speed_SpdM = Max_Speed_Temp
	}
	
	if(CAN_Controle_Alternatif = Off)||(CAN_Opt_no_touch_bit = Off)||(CAN_ASD_Active_bit = Off)||(CAN_Status_PLC_Trame = Off)||(Err_Capteur_Left = On)||(Err_Capteur_Right = On){
		Kp_Spdm = PAR_DEF_Kp
		Ki_Spdm = PAR_DEF_Ki_LS
		Full_Accel_Rate_LS_SPDM = PAR_DEF_Full_Accel_Rate_LS
		Low_Accel_Rate_SPDM = PAR_DEF_Low_Accel_Rate
		Neutral_Decel_Rate_LS_SPDM = PAR_Def_Neutral_Decel_Rate_LS
		Low_Brake_Rate_SPDM = PAR_DEF_Low_Brake_Rate
		Partial_Decel_Rate_SPDM = PAR_DEF_Partial_Decel_Rate
		if(Inching_sw = Off)&((low_speed_sw = On)||(Docking_speed_sw = On)){
		Full_Brake_Rate_LS_SPDM = PAR_ASD_Full_Brake_Rate_LS
		}
		else{
		Full_Brake_Rate_LS_SPDM = PAR_DEF_Full_Brake_Rate_LS
		}
		
	}
	else{
		Kp_Spdm = PAR_ALT_Kp
		Ki_Spdm = PAR_ALT_Ki_LS
		Full_Accel_Rate_LS_SPDM = PAR_ALT_Full_Accel_Rate_LS
		Low_Accel_Rate_SPDM = PAR_ALT_Low_Accel_Rate
		Neutral_Decel_Rate_LS_SPDM = PAR_ALT_Neutral_Decel_Rate_LS
		Full_Brake_Rate_LS_SPDM = PAR_ALT_Full_Brake_Rate_LS
		Low_Brake_Rate_SPDM = PAR_ALT_Low_Brake_Rate
		Partial_Decel_Rate_SPDM = PAR_ALT_Partial_Decel_Rate
	}
	return

;========================================================================
;												PROCESS DISPLAY
;				 send the model 840 spyglass serial command	
;========================================================================
Process_Display:
	;================== SPY GLASS LED SET ============================
		LED_Output = (BDI_Percentage*255)/100
		Put_Spy_LED(LED_Output)
		if(BDI_Percentage <= PAR_BDI_LOW_level)
			{	; Flash the Red LED if the battery is below 26%
			LED_Output = LED_Output || LED_Red_6
			Put_Spy_LED(LED_Output)
			}
		;----------- FAULT ACTIVE LED SET -----------
		if (Fault_count<>0)|(((Trac_maint_expired = On)&(Trac_Maintenance_enable = On))|
				((Total_maint_expired = On)&(Total_Maintenance_enable = On))|((Pump_maint_expired = On)&(PAR_Pump_Maintenance_enable = On)))
		{
		LED_Output = LED_Output | LED_Red_Flashing_6
		Put_Spy_LED(LED_Output)			
		}	;-------------------- SET THE FAULT LED IF ANY FAULT ARE PRESENT -----------------------
	
	;#####################	Display 840 text state machine #################################
	;======================== INITIAL MESSAGES ===============================
		;===================== SERVICE DUE DISPLAY SET ============
	if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_Service_DUE)	
		{
		;------------- SHOW THE SERVICE ------------------------
		if((Trac_maint_expired = On)&(Trac_Maintenance_enable = On))|((Total_maint_expired = On)&(Total_Maintenance_enable = On))|
			((Pump_maint_expired = On)&(PAR_Pump_Maintenance_enable = On))
			{
			Setup_Delay(Display_State_DLY,Message_update_delay)
			Put_Spy_text("SERVICE!") 
			}
		Display_State = SPY_STATE_CUSTOMER
		}
	;----------------------- CUSTOMER NAME MESSAGE ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_CUSTOMER)	
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_text("  TLD")	;Display Customer name			
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_VEH_TYPE			
			}	
		}
	;----------------------- CUSTOMER VEHICLE TYPE MESSAGE ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_VEH_TYPE)			
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		; Vehicle Type displaying will be optional so TLD can chose between different 
		; Types that are predefined
		;---------- SHOW VEHICLE TYPE ----------------
		if(PAR_Vehicle_type = 0)
			{
			Put_Spy_text("  NBL")	;Display VEHICLE TYPE
			}
		;------------------ JET16 ----------------------
		else if(PAR_Vehicle_type = 1)
			{
			Put_Spy_text("  JET16 ")	;Display VEHICLE TYPE			
			}
		;------------------ ABS ----------------------
		else if(PAR_Vehicle_type = 2)
			{
			Put_Spy_text("   ABS")	;Display VEHICLE TYPE			
			}
		;------------------ ABS ----------------------
		else if(PAR_Vehicle_type = 3)
			{
			Put_Spy_text(" BBS580")	;Display VEHICLE TYPE			
			}		
		
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_VEH_NAME			
			}	
		}		
		;----------------------- CUSTOMER VEHICLE NAME MESSAGE ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_VEH_NAME)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		; Vehicle Name displaying will be optional so TLD can chose between different 
		; names that are predefined
		;---------- SHOW VEHICLE NAME ----------------
		if(PAR_Vehicle_type = 0)
			{
			Put_Spy_text("1249565B")	;Display NBL  vehicle name
			}
		else if(PAR_Vehicle_type = 1)
			{
			Put_Spy_text("1188181A")	;Display JET 16 AIR FRANCE VEHICLE 			

			}
		;------------------ 3B2803C1 ----------------------
		else if(PAR_Vehicle_type = 2)
			{
			Put_Spy_text("1188166A")	;Display ABS Vehicle name			
			}
		;------------------ 3B2803C1 ----------------------
		else if(PAR_Vehicle_type = 3)
			{
			Put_Spy_text("1188170A")	;Display BBS Vehicle name			
			}
		
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			;----------- NBL is selected ------------------
			if(PAR_Vehicle_type = 0)||(PAR_Vehicle_type = 2)||(PAR_Vehicle_type = 3)
				{
				Display_State = SPY_STATE_NBL_TYPE
				}
			else
				{
				Display_State = SPY_STATE_TOTAL_M_N			
				}	
			}	
		}		
		;----------------------- CUSTOMER NBL NAME MESSAGE ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_NBL_TYPE)			;NBL Message
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		if(PAR_Vehicle_type = 0) ; Show NBL Name
			{				
			Put_Spy_text("1249565B"); SHOW NBL NAME 
			}
		else if	(PAR_Vehicle_type = 2); Show ABS name
			{
			Put_Spy_text("1188166A"); SHOW ABS NAME 
			}
		else if	(PAR_Vehicle_type = 3); Show BBS name
			{
			Put_Spy_text("1188170A"); SHOW BBS NAME 
			}
		
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_TOTAL_M_N			
			}	
		}		
			
	;------------------- TOTAL MAINTENANCE MESSAGE ------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TOTAL_M_N)			;Total Hours Label State
		{
		;---------------- SHOW TOTAL MAINTENANCE -----------
		if(Total_Maintenance_enable = On); Show total maintenance since is enabled
			{
			Setup_Delay(Display_State_DLY,Message_update_delay)
			Put_Spy_Text("TotalMM")	;840 Message
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_TOTAL_M_V			;Display Total Maintenance value next				
				}
			}
		;---------------- SHOW TRACTION MAINTENANCE NEXT 
		else ; total maintenance is disabled don't show 
			{
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
				Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_TRAC_M_N
				}
			}
		}		
	;---------------	TOTAL MAINTENANCE VALUE  --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TOTAL_M_V)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Message("", Total_HM_maint_exp_time, "h", PSM_DECIMAL)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_TRAC_M_N			;Display Total Hours value next
			}
		}		
	;------------------- TRACTION MAINTENANCE MESSAGE ------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TRAC_M_N)			;Total Hours Label State
		{
		;---------------- SHOW TRACTION MAINTENANCE -----------
		if(Trac_Maintenance_enable = On); Show total maintenance since is enabled
			{
			Setup_Delay(Display_State_DLY,Message_update_delay)
			Put_Spy_Text("DriveMM")	;840 Message
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
				Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_TRAC_M_V			;Display trac Maintenance value next				
				}
			}
		;---------------- SHOW TOTAL HM  NEXT ----------
		else ; total maintenance is disabled don't show 
			{
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
				Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_PUMP_M_N			;Display Total Hours value next
				}
			}
		}		
	;---------------	TRACTION MAINTENANCE VALUE  --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TRAC_M_V)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Message("", Trac_HM_maint_exp_time, "h", PSM_DECIMAL)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_PUMP_M_N			;Display Pump MM value next
			}
		}		
	;------------------- PUMP MAINTENANCE MESSAGE ------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_PUMP_M_N)			;Total Hours Label State
		{
		;---------------- SHOW PUMP MAINTENANCE -----------
		if(PAR_Pump_Maintenance_enable = On); Show total maintenance since is enabled
			{
			Setup_Delay(Display_State_DLY,Message_update_delay)
			Put_Spy_Text("PumpMM")	;840 Message
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
				Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_PUMP_M_V			;Display trac Maintenance value next				
				}
			}
		;---------------- SHOW TOTAL HM  NEXT 
		else ; total maintenance is disabled don't show 
			{
			;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
			if (Fault_Count <>0)	
				{
				Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
				}
			else
				{
				Display_State = SPY_STATE_Total_HM_N
				}
			}
		}		
	;---------------	PUMP MAINTENANCE VALUE  --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_PUMP_M_V)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Message("", Pump_HM_maint_exp_time, "h", PSM_DECIMAL)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_Total_HM_N			;Display Total Hours value next
			}
		}		
	;---------------	TOTAL HOUR METER DISPLAY THE NAME --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_Total_HM_N)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Text("TotalH")	;840 Message
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_Total_HM_V			;Display Total Hours value next
			}
		}
	;---------------	TOTAL HOUR METER DISPLAY  --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_Total_HM_V)		;Total Hours value State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Timer(Total_hourmeter)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_PUMP_HM_N	
			}
		}
	;---------------	Pump HOUR METER DISPLAY THE NAME --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_PUMP_HM_N)			;Pump Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Text("PumpH")	;840 Message
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_PUMP_HM_V			;Display Total Hours value next
			}
		}
	;---------------	PUMP HOUR METER DISPLAY  --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_PUMP_HM_V)		;Total Hours value State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Timer(Pump_hourmeter)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_TRAC_HM_N	
			}
		}		
	;---------------	TRACTION HOUR METER DISPLAY --------------------------------			
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TRAC_HM_N)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Text("DriveH")	;840 Message
		Display_State = SPY_STATE_TRAC_HM_V			;Display Total Hours value next
		}
	;------------------------- TRACTION HOURS OPERATION -----------------------	
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_TRAC_HM_V)		;Traction Hours value State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Timer(Traction_hourmeter)
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}
		else
			{
			Display_State = SPY_STATE_ODOMETER_N	
			}
		}
	;-------------------------- TOTAL ODOMETER NAME ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_ODOMETER_N)			;Total Hours Label State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
		Put_Spy_Text("TotalKM")	;840 Message
		Display_State = SPY_STATE_ODOMETER_V			;Display Odometer value (in KM)
		}
	;-------------------------- TOTAL ODOMETER VALUE --------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_ODOMETER_V)		;Traction Hours value State
		{
		Setup_Delay(Display_State_DLY,Message_update_delay)
			Main_message_temp = VCL_get_byte(Vehicle_Odometer,0)
			Put_Spy_Message("",Main_message_temp,"", PSM_DECIMAL_1)
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			}	
		else if(BDI_percentage <= PAR_BDI_LOW_level)
			{
			Display_State = SPY_STATE_BDI_LOW  			; BDI LOW Message next
			}				
		else if (Interlock_State = On)
			{
			Display_State = SPY_STATE_INTERLOCK_ON					;INTERLOCK ON MESSAGES next
			}			
		else
			{
			Display_State = SPY_STATE_INTERLOCK_OFF	;INTERLOCK OFF MESSAGES next 
			}		
		}
				
	;======================== MAIN MESSAGES ===============================	
	;--------------------- INTERLOCK ON OPERATION ---------------------------
	else if(Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_INTERLOCK_ON)		;Interlock ON messages 
		{
		;------------ Interlock ON messages -------------------------
		; Speed dispay is optional 
		if(ABS_vehicle_speed > 10)&(PAR_Display_show_speed = On)&(PAR_Metric_Units_display = on)
			{
			Vehicle_speed_scaled = ABS_Vehicle_speed /10 
			Put_Spy_Message("",Vehicle_speed_scaled, "km/h", PSM_DECIMAL)
			}
		else if (ABS_vehicle_speed > 10)&(PAR_Display_show_speed = On)&(PAR_Metric_Units_display = off)
			{
			Vehicle_speed_scaled = ABS_Vehicle_speed /10 
			Put_Spy_Message("",Vehicle_speed_scaled, "MPH", PSM_DECIMAL)
			}
		else
			{
			Put_Spy_Message("BAT ",BDI_Percentage,"%",PSM_DECIMAL)	
			}
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next
			Setup_Delay(Display_State_DLY,Message_update_delay)		
			}
		else if(BDI_percentage <= PAR_BDI_LOW_level)
			{
			Display_State = SPY_STATE_BDI_LOW  			; BDI LOW Message next
			}				
		else if (Interlock_State = On)
			{
			Display_State = SPY_STATE_INTERLOCK_ON					;INTERLOCK ON MESSAGES next
			Setup_Delay(Display_State_DLY,100)			
			}			
		else
			{
			Display_State = SPY_STATE_INTERLOCK_OFF	;INTERLOCK OFF MESSAGES next 
			Setup_Delay(Display_State_DLY,Message_update_delay)		
			}						
		}
;---------------------INTERLOCK OFF OPERATION ------------------
	else if((Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_INTERLOCK_OFF))		;BDI Label State
		{
		Display_state_interlock = Display_state_interlock + 1
		Put_Spy_Message("BAT ",BDI_Percentage,"%",PSM_DECIMAL)	
		Setup_Delay(Display_State_DLY,Message_update_delay)			
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------	
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next		
			}
		else if(BDI_percentage <= PAR_BDI_LOW_level)
			{
			Display_State = SPY_STATE_BDI_LOW  			; BDI LOW Message next
			}				
		else if (Interlock_State = On)
			{
			Display_State = SPY_STATE_INTERLOCK_ON					;INTERLOCK ON MESSAGES next

			}			
		else
			{
			Display_State = SPY_STATE_INTERLOCK_OFF
			}		
		}
;---------------------- FAULT MESSAGES ------------------------------
	else if((Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_FAULT))		;Fault Label State
		{
		if (Fault_Count <>0)		;check again to make sure fault has not been cleared
			{
			Fault_displayed_flag = off		; Clear for next display
			Fault_display_state = 0
			call Find_Fault_Code	;decode controller fault bits if any
			Setup_Delay(Display_State_DLY,Message_update_delay) 								
			Fault_Pointer = Fault_Pointer+1	;increment Fault_Pointer to get next fault on stack	
			if(Fault_Pointer >= Fault_Count)	;test to see if anoed
				{                                                                            
				Fault_Pointer = 0	;reset Fault_Pointer to retrieve the first fault next time
				} 			
			;================ MASTER CONTROLLER DISPLAY =======================	
			if(Fault_display_state = 0)&(Fault_displayed_flag = off)
				{
				Fault_display_state =1 ; Next FAULT display state	
				Fault_displayed_flag = on	
				;-------------- USER DEFINED MESSAGE TRIGGER ---------------
				; HERE you can change the standard user fault message with custom one 
				if(Fault_Flash_Code=58)			; Slave Fault active
					{
					Fault_displayed_flag = off		
					}
				else
					{
					;-------------- USER DEFINED MESSAGE TRIGGER ---------------
					; HERE you can change the standart user fault message with custom one 
					if(Fault_Flash_Code = 51) 			; FAULT 51
						{
						Put_Spy_text("  HPD") 	
						}
					else if(Fault_Flash_Code = 52)	; FAULT 52
						{
						Put_Spy_text("  SRO") 						
						}
					else if(Fault_Flash_Code = 53)	; FAULT 53
						{
						Put_Spy_text("INCHING") 						
						}	
					else if(Fault_Flash_Code = 54)	; FAULT 54
						{
						Put_Spy_text("DEADMAN") 						
						}
				
					else if(Fault_Flash_Code = 56)	; FAULT 56
						{
						Put_Spy_text("  SRO") 						
						}
					else if(Fault_Flash_Code = 57)	; FAULT 56
						{
						Put_Spy_text("HANDBRAK") 						
						}
					else if(Fault_Flash_Code = 61)	; FAULT 56
						{
						Put_Spy_text("ErrSensL") 						
						}
					else if(Fault_Flash_Code = 62)	; FAULT 56
						{
						Put_Spy_text("ErrSensR") 						
						}
					else if(Fault_Flash_Code = 63)	; FAULT 56
						{
						Put_Spy_text("ErrNoCom") 						
						}
					else if(Fault_Flash_Code = 64)	; FAULT 56
						{
						Put_Spy_text("ErrCRC") 						
						}
					;------------- NO CUSTOM FAULT ARE PRESENT -------
					else
						{
						Put_Spy_Message("Fault ",Fault_Flash_Code,"",PSM_DECIMAL)
						}		
					}			
				}
			;================ SLAVE CONTROLLER DISPLAY ===================
			if(Fault_display_state = 1)&(Fault_displayed_flag = off)
				{
				Fault_display_state =0 ; Next FAULT display state		
				if(CAN_Fault_Flash_Code_pump <>0)
					{			
					Fault_displayed_flag = on						
					Put_Spy_Message("P ERR",CAN_Fault_Flash_Code_pump,"",PSM_DECIMAL)					
					}
				}	
			}
		else
			{	
			if(BDI_percentage <= PAR_BDI_LOW_level)
				{
				Display_State = SPY_STATE_BDI_LOW  			; BDI LOW Message next
				}				
			else if (Interlock_State = On)
				{
				Display_State = SPY_STATE_INTERLOCK_ON					;INTERLOCK ON MESSAGES next
				}
			else
				{
				Display_State = SPY_STATE_INTERLOCK_OFF					;INTERLOCK ON MESSAGES next					
				}
			}			
		}
	;---------------------BDI LOW MESSAGE ------------------		
	else if ((Display_State_DLY_Output = 0)&(Display_State = SPY_STATE_BDI_LOW))		;BDI LOW LEVEL
		{
		Put_Spy_text("Low BDI ")	
		Setup_Delay(Display_State_DLY,Message_update_delay)		
		;------------ TRIGGER MESSAGES FOR NEXT DISPLAY -------------------	
		if (Fault_Count <>0)	
			{
			Display_State = SPY_STATE_FAULT					;FAULT - Display Fault Code next		
			}
		else if(BDI_percentage <= PAR_BDI_LOW_level)
			{
			Display_State = SPY_STATE_BDI_LOW  			; BDI LOW Message next
			}				
		else if (Interlock_State = On)
			{
			Display_State = SPY_STATE_INTERLOCK_ON					;INTERLOCK ON MESSAGES next

			}			
		else
			{
			Display_State = SPY_STATE_INTERLOCK_OFF	;INTERLOCK OFF MESSAGES next 
			}						
		}

	return

;========================================================================
;										FIND FAULT CODE 
;			 uses a Get_Fault_Code function to pop an active fault
;	code off the stack and then uses this info to translate into a Fault_Flash_Code,
;	which is returned for display on the spyglass (840).			
;========================================================================
Find_Fault_Code:
	Fault_Code = Get_Fault_Code(Fault_Pointer)	;The resultant Fault_Code is NOT the flash code
    if		(Fault_Code=	MAIN_CONTACTOR_WELDED   			) {Fault_Flash_Code=38}
    else if	(Fault_Code=	MAIN_CONTACTOR_DID_NOT_CLOSE   		) {Fault_Flash_Code=39}
    else if	(Fault_Code=	POT_LOW_OVERCURRENT   				) {Fault_Flash_Code=45}
    else if	(Fault_Code=	THROTTLE_WIPER_LOW   				) {Fault_Flash_Code=42}
    else if	(Fault_Code=	THROTTLE_WIPER_HIGH   				) {Fault_Flash_Code=41}
    else if	(Fault_Code=	POT2_WIPER_LOW       				) {Fault_Flash_Code=44}
    else if	(Fault_Code=	POT2_WIPER_HIGH      				) {Fault_Flash_Code=43}
    else if	(Fault_Code=	EEPROM_FAILURE       				) {Fault_Flash_Code=46}
    else if	(Fault_Code=	HPD_SEQUENCING       				) {Fault_Flash_Code=47}
    else if	(Fault_Code=	SEVERE_UNDERVOLTAGE   				) {Fault_Flash_Code=17}
    else if	(Fault_Code=	SEVERE_OVERVOLTAGE   				) {Fault_Flash_Code=18}
    else if	(Fault_Code=	UNDERVOLTAGE_CUTBACK   				) {Fault_Flash_Code=23}
    else if	(Fault_Code=	OVERVOLTAGE_CUTBACK   				) {Fault_Flash_Code=24}
   ; else if	(Fault_Code=	SIN_COS_MOTOR_FEEDBACK              ) {Fault_Flash_Code=36};Not present in OS26
    else if	(Fault_Code=	CONTROLLER_OVERTEMP_CUTBACK   		) {Fault_Flash_Code=22}
    else if	(Fault_Code=	CONTROLLER_SEVERE_UNDERTEMP   		) {Fault_Flash_Code=15}
    else if	(Fault_Code=	CONTROLLER_SEVERE_OVERTEMP   		) {Fault_Flash_Code=16}
    else if	(Fault_Code=	COIL1_DRIVER_OPEN_SHORT   			) {Fault_Flash_Code=31}
    else if	(Fault_Code=	COIL2_DRIVER_OPEN_SHORT   			) {Fault_Flash_Code=32}
    else if	(Fault_Code=	COIL3_DRIVER_OPEN_SHORT   			) {Fault_Flash_Code=33}
    else if	(Fault_Code=	COIL4_DRIVER_OPEN_SHORT   			) {Fault_Flash_Code=34}
    else if	(Fault_Code=	PD_OPEN_SHORT        				) {Fault_Flash_Code=35}
    else if	(Fault_Code=	MAIN_OPEN_SHORT      				) {Fault_Flash_Code=31}
    else if	(Fault_Code=	EMBRAKE_OPEN_SHORT   				) {Fault_Flash_Code=32}
    else if	(Fault_Code=	PRECHARGE_FAILED     				) {Fault_Flash_Code=14}
    else if	(Fault_Code=	DIGITAL_OUT_6_OPEN_SHORT   			) {Fault_Flash_Code=26}
    else if	(Fault_Code=	DIGITAL_OUT_7_OPEN_SHORT   			) {Fault_Flash_Code=27}
    else if	(Fault_Code=	CONTROLLER_OVERCURRENT   			) {Fault_Flash_Code=12}
    else if	(Fault_Code=	CURRENT_SENSOR       				) {Fault_Flash_Code=13}
    else if	(Fault_Code=	MOTOR_TEMP_HOT_CUTBACK   			) {Fault_Flash_Code=28}
    else if	(Fault_Code=	PARAMETER_CHANGE     				) {Fault_Flash_Code=49}
    else if	(Fault_Code=	MOTOR_OPEN           				) {Fault_Flash_Code=37}
    else if	(Fault_Code=	USER01                				) {Fault_Flash_Code=51}
    else if	(Fault_Code=	USER02                				) {Fault_Flash_Code=52}
    else if	(Fault_Code=	USER03                				) {Fault_Flash_Code=53}
    else if	(Fault_Code=	USER04                				) {Fault_Flash_Code=54}
    else if	(Fault_Code=	USER05                				) {Fault_Flash_Code=55}
    else if	(Fault_Code=	USER06                				) {Fault_Flash_Code=56}
    else if	(Fault_Code=	USER07                				) {Fault_Flash_Code=57}
    else if	(Fault_Code=	USER08                				) {Fault_Flash_Code=58}
    else if	(Fault_Code=	USER09                				) {Fault_Flash_Code=59}
    else if	(Fault_Code=	USER010               				) {Fault_Flash_Code=61}
    else if	(Fault_Code=	USER011               				) {Fault_Flash_Code=62}
    else if	(Fault_Code=	USER012               				) {Fault_Flash_Code=63}
    else if	(Fault_Code=	USER013               				) {Fault_Flash_Code=64}
    else if	(Fault_Code=	USER014               				) {Fault_Flash_Code=65}
    else if	(Fault_Code=	USER015               				) {Fault_Flash_Code=66}
    else if	(Fault_Code=	USER016               				) {Fault_Flash_Code=67}
    else if	(Fault_Code=	EXTERNAL_SUPPLY_OUT_OF_RANGE   		) {Fault_Flash_Code=69}
    else if	(Fault_Code=	MOTOR_TEMP_SENSOR    				) {Fault_Flash_Code=29}
    else if	(Fault_Code=	VCL_RUN_TIME_ERROR   				) {Fault_Flash_Code=68}
    else if	(Fault_Code=	FIVE_V_SUPPLY_FAILURE   			) {Fault_Flash_Code=25}
    else if	(Fault_Code=	OS_GENERAL           				) {Fault_Flash_Code=71}
    else if	(Fault_Code=	PDO_TIMEOUT          				) {Fault_Flash_Code=72}
    else if	(Fault_Code=	ENCODER              				) {Fault_Flash_Code=36}
    else if	(Fault_Code=	STALL_DETECTED       				) {Fault_Flash_Code=73}
    else if	(Fault_Code=	BAD_CALIBRATIONS     				) {Fault_Flash_Code=82}
    else if	(Fault_Code=	EMER_REV_HPD         				) {Fault_Flash_Code=47}
    else if	(Fault_Code=	MOTOR_TYPE_ERROR     				) {Fault_Flash_Code=89}
    else if	(Fault_Code=	SUPERVISON_ERROR     				) {Fault_Flash_Code=77}
    else if	(Fault_Code=	MOTOR_CHARACTERIZATION   			) {Fault_Flash_Code=87}
    else if	(Fault_Code=	PUMP_HARDWARE        				) {Fault_Flash_Code=97}
    else if	(Fault_Code=	VCL_OS_MISMATCH      				) {Fault_Flash_Code=91}
    else if	(Fault_Code=	EM_BRAKE_FAILED_TO_SET   			) {Fault_Flash_Code=92}
    else if	(Fault_Code=	ENCODER_LOS          				) {Fault_Flash_Code=93}
    else if	(Fault_Code=	EMER_REV_TIMEOUT     				) {Fault_Flash_Code=94}
    else if	(Fault_Code=	DUAL_SEVERE          				) {Fault_Flash_Code=75}
    else if	(Fault_Code=	FAULT_ON_OTHER_TRACTION_CONTROLLER	) {Fault_Flash_Code=74}
    else if	(Fault_Code=	ILLEGAL_MODEL_NUMBER   				) {Fault_Flash_Code=98}
    else if	(Fault_Code=	PUMP_OVERCURRENT     				) {Fault_Flash_Code=95}
    else if	(Fault_Code=	PUMP_BDI             				) {Fault_Flash_Code=96}
    else if	(Fault_Code=	PUMP_HPD             				) {Fault_Flash_Code=47}
   ; else if	(Fault_Code=	PARAMETER_MISMATCH   				) {Fault_Flash_Code=99};Not present in OS26
    else if	(Fault_Code=	LO_PWR_CKT_UNDERVOLTAGE   			) {Fault_Flash_Code=17}
   ; else if	(Fault_Code=	LO_PWR_CKT_OVERVOLTAGE   			) {Fault_Flash_Code=18};Not present in OS26
    else if	(Fault_Code=	ISOLATION_MONITOR_FAULT   			) {Fault_Flash_Code=76}
    else if	(Fault_Code=	ENCODER_PULSE_ERROR   				) {Fault_Flash_Code=88}
    else if	(Fault_Code=	SUPERVISOR_INCOMPATIBLE   			) {Fault_Flash_Code=78}
    else if	(Fault_Code=	PUMP_CURRENT_SENSOR   				) {Fault_Flash_Code=97}
  ;  else if	(Fault_Code=	SINCOS_MISALIGNMENT_ERROR   		) {Fault_Flash_Code=88};Not present in OS26
  ;  else if	(Fault_Code=	BMS_CUTBACK	        				) {Fault_Flash_Code=21};Not present in OS26
    else if	(Fault_Code=	DRIVER_SUPPLY        				) {Fault_Flash_Code=83}
  ;  else if	(Fault_Code=	FOLLOWING_ERROR						) {Fault_Flash_Code=48} ;Not present in OS26
    else   ;catch all condition in case there is another fault that is not in the list 
        {                                                                              
        Fault_Flash_Code=10  ;no such thing as a fault flash code 10
        }
	return	

;===================================================
;							PROCESS OUTPUTS
;===================================================
Process_outputs:
	;###################### PUMP CONTROL #############################
	;--------------- PUMP OUTPUT CONTROL FOR NBL -------------------
	if(PAR_Vehicle_type = 0)|(PAR_Vehicle_type = 2)|(PAR_Vehicle_type = 3)
		{
		; This output will control power steering and will be cleared after few minutes
		if(Deadman_sw = On)|(ABS_Motor_RPM > 3)
			{
			Traction_active_flag = On
			CAN_Start_pump_from_drive = On	; Used for Pump Controller in NBL	
			}
		else 
			{
			CAN_Start_pump_from_drive = Off		; Used for Pump Controller in NBL		
			;----------- Release interlock -----------------
			if(CAN_Pump_hourmeter_ON = Off)
				{
				Traction_active_flag = Off
				}	
			}
		;---------------- Mechanical Hourmeter set -------------
		; When NBL is selected The Power sterring output will be used for
		; Mechanical Hourmeter which will be set to on when the pump is running
		if(CAN_Pump_hourmeter_ON = On)
			{
			Type3_pump_startup_flag = On
			Put_PWM(Pump_driver,PAR_Power_sreering_PWM) 	
			}
		else
			{
			Put_PWM(Pump_driver,0)  
			}
		}
	;---------------PUMP OUTPUT CONTROL FOR NON NBL ------------------
	else
		{
		; This output will control power steering and will be cleared after few minutes
		if(Deadman_sw = On)|(ABS_Motor_RPM > 3)
			{
			Traction_active_flag = On
			Put_PWM(Pump_driver,PAR_Power_sreering_PWM) 
			Setup_Delay(Power_Steering_DLY,PAR_Power_Steering_DLY)
			}
		;---------- STOP THE POWER STEERING IN few minutes
		else if (Power_Steering_DLY_output = 0)
			{		
			Traction_active_flag = Off
			Put_PWM(Pump_driver,0) 
			}						
		}
	;==================== BRAKE LIGHT SET ======================================
	if(Brake_sw = On)|((Pedal_sw = Off)&(ABS_motor_RPM >= 50)&(Inching_sw = Off))
		{
		Put_PWM(Brake_lights,PAR_Brake_light_PWM)
		}
	else
		{
		Put_PWM(Brake_lights,0)		
		}	
	
	
	;================ VEHICLE TYPE 3 OUTPUT 2 USED AS EM BRAKE ============
	if(PAR_Vehicle_type == 3)
		{	
		;------------- EM BRAKE COMMAND REQUEST --------------
		if ((ABS_Motor_RPM > 50)||((Deadman_sw == On) &&((Forward_sw == On)||(Reverse_sw == On))))&&(Handbrake_fault == Off)
			{
			Setup_Delay(type3_Brk_release_DLY,1000); Release time 
			Put_PWM(EVY1_Driver,PAR_EVY1_PWM)				
			}
		;-------------- Disable EM Brake in case of no command
		else if (type3_Brk_release_DLY_output == 0)
			{
			Put_PWM(EVY1_Driver,0)				
			}
		}
	;------------- SET THE EVY1 DRIVER ---------
	; This output has to run as soon as the inching is requested 
	else if(Inching_active_flag = On)&(VCL_Throttle <> 0)
		{
		Put_PWM(EVY1_Driver,PAR_EVY1_PWM)
		}
	else
		{		
		Put_PWM(EVY1_Driver,0)
		}	
	
	;==================== BDI LED DRIVER ===========================
	; Output 2 is controlled depending on different need of the Sharlatte.
	; It can be configured as Power steering or current load enable 	
	;-------------- BDI DRIVER FUNCTION SET ----------
 	if(PAR_BDI_LED_enable = On)&(PAR_Current_load_fcn_enable = Off)
		{
		;------------- BDI DRIVER FOR NBL AF ----------
		; Air france requested to have the special warning light 
		; If  Above 35% we switch light off if  Below 20% we switch light on
		; If it is between 20 and 35% the output will blink
		;============= BLINKING BDI DRIVER ==================
		if(PAR_Blinking_BDI_output = On)
			{
			;--------------- BATTERY IS > 35% --------------	
			if(BDI_Percentage >= PAR_BDI_Pre_Warning_Level)
				{
				Put_PWM (Option2_Output,0)
				}
			;--------------- BATTERY IS < 20% --------------	
			else if(BDI_Percentage <= PAR_BDI_Warning_Level)		
				{
				Put_PWM (Option2_Output,PAR_BDI_Driver_PWM)
				}
			;--------------- BATTERY IS < 35% and > 20% --------------				
			; Output will blink
			else if(BDI_Percentage < PAR_BDI_Pre_Warning_Level)&(BDI_Percentage > PAR_BDI_Warning_Level)
				{
				if(BDI_DRV_Trigger_DLY_Output = 0)		; If timed out for 1 second then reset the timer and flip the output	
					{
					Setup_Delay(BDI_DRV_Trigger_DLY, 1000)	; Reset the timer 1000mS
					if(BDI_drv_trigger_flag = Off)									; If the light is out then turn it on else it must be on so turn it off
						{
						Put_PWM (Option2_Output,PAR_BDI_Driver_PWM)
						BDI_drv_trigger_flag = On
				 		}
				 	else
				 		{
						Put_PWM (Option2_Output,0)
						BDI_drv_trigger_flag = Off
				 		}
					}		
				}			
			}
		;================= BDI DRIVER FOR ALL OTHER VEHICLES =============
		else 
			{
			;--------------- BATTERY IS < 20% --------------	
			if(BDI_Percentage <= PAR_BDI_Warning_Level)		
				{
				Put_PWM (Option2_Output,PAR_BDI_Driver_PWM)
				}
			else
				{
				Put_PWM (Option2_Output,0)					
				}			
			}
		}
	;--------------- LOAD ENABLE FUNCTION ---------------------	
	else if(PAR_BDI_LED_enable = Off)&(PAR_Current_load_fcn_enable = On)
		{
		; This function allowes to activate an output if the keyswitch voltage increase more 
		;	than programmed treshold. After this state is sensed output will be active for programmed
		; delay then it will stop. The delay will be started after voltage drops bellow treshold.
		if(keyswitch_voltage >= PAR_load_enable_voltage)
			{
			Put_PWM(Option2_Output,PAR_current_load_PWM); Set the output
			Setup_Delay(Current_load_delay,PAR_load_disable_delay)
			}	
		else
			{
			;------------ TIMER EXPIRED ? --------------------------
			if(Current_load_delay_Output = 0); Count seconds
				{
				Put_PWM(Option2_Output,0)
				}
			}
		}
	;----------- OPTION IS DISABLED --------------
	else
		{
		Put_PWM(Option2_Output,0)				
		}
	return

;===================================================
;							PROCESS FAULTS
;===================================================
Process_faults:		
	;============== DEADMAN FAULT CHECK ===========
	; This fault will be active when the Pedal is pressed before 
	;	DEADMAN or When deadman is released during driving and No HPD Is active
	if(Deadman_sw = Off)&(Custom_HPD = Off)
		{
		;-------------- CLEAR FAULT ONLY FOR NON SEQUENCE CHECK
		if(Pedal_sw = Off)&(PAR_enable_VCL_HPD = Off)
			{
			Deadman_fault = Off	
			}	
		;--------------- CLEAR FAULT ---------------------------
		; Fault will be cleared when movement command are released
		else if(Pedal_sw = Off)&(Forward_sw = Off)&(Reverse_sw = Off)
			{
			Setup_Delay (Deadman_fault_DLY, 1000)
			Deadman_fault = Off ; Reset Deadman fault 						
			}
		;---------------- SET FAULT -------------
		; Fault will be activated when the Throttle pedal is pressed and the vehicle is not moving
		if(ABS_Motor_RPM = 0)&((Pedal_sw = On)|(Forward_sw = On)|(Reverse_sw = On))&(PAR_enable_VCL_HPD = On)&(Inching_sw = Off)
			{
			Deadman_fault = On						
			}
		;----- PEDAL IS PRESSED WHEN DEADMAN IS OFF ----
		; If the Deadman is released for more than 1 sec and movement
		; command is given vehicle will be on fault when Vehicle is moving
		;	if vehicle is stopped in the same case VCL HPD will be set or 5 second fault
		else if((Forward_sw = On)|(Reverse_sw = On))&(Deadman_fault_DLY_output = 0)&(ABS_Motor_RPM <>0 )&
			(Custom_HPD = Off)&(Custom_SRO = Off)&(Inching_sw = Off)
			{
			Deadman_fault = On			
			}
		}	
	;---------------- DEADMAN IS PRESSED ------------------
	else
		{	
		Setup_Delay (Deadman_fault_DLY, 1000)
		;------------------ CLEAR FAULT ------------------
		; Deadman fault will be cleared if the when no movment command is active
		if(Pedal_sw = Off)
			{
			Deadman_fault = Off ; Reset Deadman fault 			
			}	
		}
	;=================== VCL SRO FAULT CHECK ===========	
	; Special sequence need to be respected to start movement
	; This is optional for some vehicles
	;----------------- INITIAL STATE -------------------
	if(Deadman_Sw = Off)&(Forward_Sw = Off)&(Reverse_Sw = Off)&(Pedal_sw = Off)
		{
		Wrong_Sequence_fault = Off	
		Sequence_state	= INITIAL ; No command is requested 
		Sequence_Status = SEQ_NOT_READY
		}
	;------------------ DIRECTION SELECTED ---------------
	else if ((Sequence_state = INITIAL)&(Deadman_Sw = On)&(Pedal_sw = Off)&((Forward_Sw = On)|(Reverse_Sw = On)))
		{
		Wrong_Sequence_fault = Off	
		Sequence_state  = DIRECTION_SELECTED
		Sequence_Status = SEQ_NOT_READY	
		}
	;------------------- PEDAL IS PRESSED ---------------------
	else if((Sequence_state = DIRECTION_SELECTED)&(Deadman_Sw = On)&(Pedal_sw = ON)&((Forward_Sw = On)|(Reverse_Sw = On)))
		{
		Sequence_state 	= FINISHED	
		Sequence_Status = SEQ_OK	
		}
	;-----------------  FAULT CONDITION --------------------------------------
	else if (Sequence_Status = SEQ_NOT_READY)&(Deadman_Sw = On)&(Pedal_sw = On)&(PAR_enable_VCL_HPD = On)
		{
		Wrong_Sequence_fault = On	
		Sequence_Status = SEQ_Faulted
		}	
	
	;--------------- DIRECTION CHANGE FAULT SET  ----------
	; If the direction has been changed during driving and Parameter change is enabled 
	; then the vehicle will be forced to a stop because of SRO fault
	if(ABS_Motor_RPM >10)&(PAR_Change_direction_enable = Off)
		{
		;--------------- DIRECTION HAS BEEN RESELECTED DURING DRIVING ----------
		if((Forward_sw_temp = On)&(Forward_sw = Off))|((Reverse_sw_temp = On)&(Reverse_sw = Off))
			{
			Custom_SRO = On
			}
		}
	else
		{
		;--------------- Reset the fault only when the vehicle is stoped and direction is in neutral
		if(ABS_Motor_RPM = 0)&(Forward_sw = Off)&(Reverse_sw = Off)
			{
			Custom_SRO = Off
			}
		Forward_sw_temp = Forward_sw
		Reverse_sw_temp = Reverse_sw
		}
	;--------------------- RESET SRO FAULT --------------
	if(Reverse_sw = Off)&(Forward_sw = Off) ; If the inching command is requested at startup 
		{
		Custom_SRO = Off
		}

	;--------------------- RESET HPD FAULT --------------------
	if(Pedal_sw = Off)
		{
		Custom_HPD = Off
		}
		
	;============================ INCHING FAULT ================
	; Fault will be active if the operator tries to press deadman
	; while inching is active.To inform why vehicle is not moving 
	if((Inching_sw = On)&(Deadman_sw = On))||(Inching_fault_state = 2)||(Inching_fault_state = 3)||(Inching_startup_fault_check_flag = on)	{Inching_Fault = On}
	else{Inching_Fault = Off}
	
	
	;================== INCHING STARTUP CHECK =============
	if(Inching_sw = off)
		{
		Setup_Delay(Inching_check_DLY,200)
		Inching_startup_fault_check_flag = off
		}
	else if (Inching_check_DLY_output <> 0)&&((Forward_sw  = on)||(Reverse_sw = on)){Inching_startup_fault_check_flag = on}
	
	;=============== INCHING FAULT CHECK ==============
	; In case inching FWD REV switches are on 	
	if((Inching_sw = On)&&(Forward_sw  = on)&&(Reverse_sw = on)){Inching_fault_state = 3}
	else if(Inching_fault_state = 3)
		{
		if(Forward_sw  = off)&&(Reverse_sw = off){Inching_fault_state = 0}
		}
	else if((Forward_sw  = on)||(Reverse_sw = on)||(Deadman_sw = on)||(HandBrake_sw = on)||(Pedal_sw = on))&&(Inching_sw = off){	Inching_fault_state = 1	}
	else if (Inching_sw = on)
		{
		if(Inching_fault_state = 1){Inching_fault_state = 2}
		}
	else {Inching_fault_state = 0}


	;====================== HAND BRAKE FAULT SET ==========
	; If the operator forget to pull the handbrake during inching
	if(Inching_sw = On)&(Deadman_sw = Off)&(Handbrake_sw = On)
		{
		Handbrake_fault = On
		}
	;----------------- HANDBRAKE IS NOT RELEASED ---------------
	; If the operator forget to release the Handbrake set a fault
	else if(Inching_sw = Off)&(Deadman_sw = On)&(Handbrake_sw = Off)&(PAR_Vehicle_type <>3)
		{
		Handbrake_fault = On			
		}
	;------------------ VEHICLE TYPE 3 ----------------------
	else if ((PAR_Vehicle_type = 3)&(PD_output > 100) &&(HandBrake_sw == Off))
		{
		if(type3_Handbrake_fault_DLY_output == 0){Handbrake_fault = On}
		}
	;------------------ CLEAR THE FAULT ---------------
	else if (PAR_Vehicle_type = 3)
		{
		Setup_Delay(type3_Handbrake_fault_DLY,3000)	
		if((Handbrake_sw == On)||((Deadman_sw ==Off)&&(Forward_sw ==Off)&&(Reverse_sw ==Off)))
			{
			Handbrake_fault = Off
			}
		}
	;------------------- NO FAULT -----------------
	else
		{
		Handbrake_fault = Off
		}
	;==================== Pump Timeout Fault ===============================
	; Available only if NBL is selected
	if(CAN_MB_From_Pump_Received = On )  ;PDO1_MISO response from Pump for timeout
		{  
		if(PDO_Pump_check_DLY_output > 100)
			{
			PDO_Timeout_Pump = Off
			}
	  Setup_Delay(PDO_Pump_check_DLY,500);  second 
	  CAN_MB_From_Pump_Received = Off
		}
	else if (PDO_Pump_check_DLY_output < 100)& ((PAR_Vehicle_type = 0)|(PAR_Vehicle_type = 2)|(PAR_Vehicle_type = 3))	;PDO1_MISO response from Pump has timed out
		{
		PDO_Timeout_Pump = On
		}
	;====================== PUMP CONTROLLER IN FAULT ==========================		
	if(CAN_Pump_faulted_flag = On)
		{
		Pump_faulted = On	
		}
	else
		{
		Pump_faulted = Off	
		}	
		
		if(CAN_MB_From_PLC_Received = On){
			
			LoopDuration = 1000 - LoopTest_output
			setup_delay(LoopTest, 1000)
 	
			if (CAN_MB_From_PLC_Received = ON)
			{
			CAN_MB_From_PLC_Received = Off
			setup_delay(PDO_PLC_timeout_DLY, 200)
						
				Data0_valid = CAN_PLC_command	
				Data1_valid = (CAN_Received_Empty1  & 0xFF)
				Data2_valid = (CAN_Max_Speed_MH & 0xFF)
        Data3_valid = (CAN_Max_Speed_MH >> 8 ) & 0xFF 
				Data4_valid = (CAN_Received_Empty2 & 0xFF) 
				Data5_valid = (CAN_Received_Empty3 & 0xFF)
				CRC_In_valid = CAN_CRC 
 	
 	
				if (CAN_MB_From_PLC_Received = ON)
				{
					CAN_MB_From_PLC_Received = OFF
					Data0_valid = CAN_PLC_command	
					Data1_valid = 0xFF 
					Data2_valid = (CAN_Max_Speed_MH & 0xFF)
          Data3_valid = (CAN_Max_Speed_MH >> 8 ) & 0xFF
					Data4_valid = 0xFF 
					Data5_valid = 0xFF 
					CRC_In_valid = CAN_CRC 
				}
 	
				CRC_Calc = 0
				
				CRC_Calc = CRC_Calc ^ (Data0_valid << 8)
				call CRC_Process
				CRC_Calc = CRC_Calc ^ (Data1_valid << 8)
				call CRC_Process
				CRC_Calc = CRC_Calc ^ (Data2_valid << 8)
				call CRC_Process
				CRC_Calc = CRC_Calc ^ (Data3_valid << 8)
				call CRC_Process
				CRC_Calc = CRC_Calc ^ (Data4_valid << 8)
				call CRC_Process
				CRC_Calc = CRC_Calc ^ (Data5_valid << 8)
				call CRC_Process	
				
				if (CRC_Calc <> CRC_In_valid)
				{
					Fault_Counter = Fault_Counter + 1 
				}
			}
		}
		
		if(PDO_PLC_timeout_DLY_output = 0){
			PDO_PLC_timeout = On
		}
		
		if((PDO_PLC_timeout = On)||(CAN_CRC_fault = On)){
			CAN_Status_PLC_Trame = Off
		}
		else{
			CAN_Status_PLC_Trame = On
		}
	;================ PEDAL FAULT DELAY ========================
	; If both pedal are pressed and direction is selected 
	if(Pedal_sw = on)&&(Brake_sw == on)&&((Forward_sw = on)||(Reverse_sw == on))
		{
		if(Pedal_fault_DLY_output == 0)
			{
			Pedal_faulted = on
			}
		}
	;-------- no fault condition -------------
	else
		{
		Setup_delay(Pedal_fault_DLY,PAR_Pedal_fault_DLY)
		}
		
		
	;============ CLEAR THE FAULT IN CASE COMMAND IS RELEASED =============
	if(Forward_sw = off)&&(Reverse_sw == off)&&(Pedal_sw == Off)&&(Brake_sw == off)&&(ABS_Motor_RPM < 5)
		{
		Pedal_faulted = off
		}
		
		if(Fault_Counter > 0){CAN_CRC_Fault = On}
		else{CAN_CRC_Fault= Off}
		
		if(Err_Capteur_Left = Off)&&(CAN_Erreur_Left = On)&&(CAN_Opt_no_touch_bit = On)&&(CAN_Status_PLC_Trame = On){
			Err_Capteur_Left = On
			Saved_ASD_Active_bit = CAN_ASD_Active_bit
		}
		
		if(Err_Capteur_Right = Off)&&(CAN_Erreur_Right = On)&&(CAN_Opt_no_touch_bit = On)&&(CAN_Status_PLC_Trame = On){
			Err_Capteur_Right = On
			Saved_ASD_Active_bit = CAN_ASD_Active_bit
		}
		
	return
;================================================================
;											PROCESS HOURMETERS
;===============================================================
Process_Hourmeters:
	;===================== CALCULATE HOURMETERS ======================================================
	; In order to show hourmeters in hours instead of 10s of hours we will calculate the hours by 
	;	multiplying hours variable by 10. To improve resolution we add tmrX_sec variable /600, which 
	;	would be value from 1-10 hours. By this way hour new scaled variable cannot go beyond 60 000 hours. 
	Total_HM_scaled = (Total_hourmeter_Hr*10) + (Total_hourmeter_Sec/600)
	Trac_HM_scaled = (Trac_hourmeter_Hr*10) + (Trac_hourmeter_Sec/600)
	Pump_HM_scaled = (Pump_hourmeter_Hr*10) + (Pump_hourmeter_Sec/600)
	;---------------------------- Calculate Remaining Maintanence time ----------------------------------
	; Remaining time will be value Interval - hourmeter value. To do accurate calculation we shift hourmeter
	; value with stored in EEPROM (NVuser) last total maintanence, which is stored every time we reset maintanence   
	Total_HM_maint_exp_time	= (PAR_Total_Maint_interval - (Total_HM_scaled - Last_total_maintanance ))
	Trac_HM_maint_exp_time	= (PAR_Trac_Maint_interval - (Trac_HM_scaled - Last_trac_maintanance ))
	Pump_HM_maint_exp_time	= (PAR_Pump_Maint_interval - (Pump_HM_scaled - Last_Pump_maintanance ))
	;===================== SETTING HOURMETERS ====================
	;---------------------- SET THE TOTAL HOURMETER --------------
	if(Set_Total_HM = On) ;check if user wants to set Total KSI Hours HM
		{
		Set_Total_HM = Off
		Disable_Timer(Total_hourmeter)
		Six_Secs =  Minutes * 10				
   	Setup_Timer(Total_hourmeter,0,Six_Secs,New_hours_value /10)	;should be TMR_ID, msec, 6sec, hours
		Enable_Timer(Total_hourmeter)						;after preset startup the timer for Total KSI Hours
		}
	;---------------------- SET THE TRACTION HOURMETER --------------
	if(Set_Trac_HM = On) ;check if user wants to set Trac Hours HM
		{
		Set_Trac_HM = Off
		Disable_Timer(Traction_hourmeter)
		Six_Secs =  Minutes * 10				
   	Setup_Timer(Traction_hourmeter,0,Six_Secs,New_hours_value/10)	;should be TMR_ID, msec, 6sec, 10s of hours	
		}
	;---------------------- SET THE PUMP HOURMETER --------------
	if(Set_Pump_HM = On) ;check if user wants to set Trac Hours HM
		{
		Set_Pump_HM = Off
		Disable_Timer(Pump_hourmeter)
		Six_Secs =  Minutes * 10				
   	Setup_Timer(Pump_hourmeter,0,Six_Secs,New_hours_value/10)	;should be TMR_ID, msec, 6sec, 10s of hours	
		}
	;======================	ACTIVATE TIMERS ===============================
	; Here timers will be activated depending on Pump enabled or if vehicle is moving
	;----------------- TRACTION HOURMETER ACTIVATION ----------------------
	if(ABS_Motor_RPM > 0);  Traction hour activate
		{	
		Enable_Timer(Traction_hourmeter); If the motor is turning, enable the hourmeter 
		}	
	else; If the motor is stationary, then disable all timers
		{
		Disable_Timer(Traction_hourmeter)
		}
	;------------------ PUMP HOURMETER SET ---------------------
	; Total hourmeter will be started when the Pump is started 	
	if(CAN_Pump_hourmeter_ON = On)|(Pump_driver_output >200)
		{
		Enable_Timer(Pump_hourmeter)	
		}
	else 
		{
		Disable_Timer(Pump_hourmeter)	
		}
	;====================== MAINTENANCE SET ===============================
	; Each timer have maintanence counting. After counting expired corresponding
	;	bit Total_maint_expired,Trac_maint_expired  will be set. Customer will be able 
	;	to do any action like speed reduction or stop all movements
	;---------------------- TOTAL HM MAINTENANCE ---------------------------
	;----------------------- reset maintenance------------------------------
	; Maintanence couting can be reset from 1311 by seting Reset_Total_HM_maint to on 
	;	after that bit will be set to off automatically
	if(Reset_Total_HM_maint = On)
		{
		Reset_Total_HM_maint = Off
		Last_total_maintanance = Total_HM_scaled
		}
	;----------------------- maintenance interval check ------------------
	if(Total_HM_maint_exp_time <= 0)&(Total_Maintenance_enable = On) ; Check if the timer has expired negative or zero means expired
		{
		Total_maint_expired = On	
		}
	else
		{
		Total_maint_expired = Off	
		}
	;---------------------- TRAC HM MAINTENANCE ---------------------------	
	;----------------------- reset maintenance----------------------------
	if(Reset_Trac_HM_maint = On)
		{
		Reset_Trac_HM_maint = Off
		Last_trac_maintanance = Trac_HM_scaled ; Store the last Hourmeter caluie
		}
	;----------------------- maintenance interval check ------------------
	if(Trac_HM_maint_exp_time <= 0)&(Trac_Maintenance_enable = On)
		{
		Trac_maint_expired = On	
		}
	else
		{
		Trac_maint_expired = Off	
		}
	;---------------------- PUMP HM MAINTENANCE ---------------------------	
	;----------------------- reset maintenance----------------------------
	if(Reset_Pump_HM_maint = On)
		{
		Reset_Pump_HM_maint = Off
		Last_Pump_maintanance = Pump_HM_scaled ; Store the last Hourmeter caluie
		}
	;----------------------- maintenance interval check ------------------
	if(Pump_HM_maint_exp_time <= 0)&(PAR_Pump_Maintenance_enable = On)
		{
		Pump_maint_expired = On	
		}
	else
		{
		Pump_maint_expired = Off	
		}		
	;======================= RESET TIMER AT 30k hours =======================
	if(Total_hourmeter_Hr >=3000); Timer is bigger than 30k hours reset
		{
		Reset_Timer(Total_hourmeter, 1); Enable timer after reset
		Last_total_maintanance = 0 		 ; Reset maintanence 
		}
	if(Trac_hourmeter_Hr >=3000); Timer is bigger than 30k hours reset
		{
		Reset_Timer(Traction_hourmeter, 1); Enable timer after reset
		Last_trac_maintanance = 0 				; Reset maintanence 
		}
	if(Pump_hourmeter_Hr >=3000); Timer is bigger than 30k hours reset
		{
		Reset_Timer(Pump_hourmeter, 1); Enable timer after reset
		Last_Pump_maintanance = 0 				; Reset maintanence 
		}		
	return	
	
;===================================================================
; Startup_CAN_System  Setting up mailboxes and starting Messaging
;===================================================================
startup_CAN_System:
  Suppress_CANopen_Init = 0   	;first undo suppress, then startup CAN, then disable CANopen
  Setup_CAN(CAN_Baud_Rate,0,0,-1,0)	; Baudrate = 125 kb/s, no Sync, Not Used, Not Used, Auto Restart 
 ; Disable_CANOpen()
  
  ;------------- MESSAGE 1 ----------------------
  ; MAILBOX 1
  ; Purpose        	 Send Message to IFM Module.
  ; Type           	 PDO1_MISO
  ; Standard COB ID	- 0x1a6      
  Setup_Mailbox(CAN_MB_To_IFM1,PDO_MISO,0,38,C_CYCLIC,C_XMT,0,0)	 
  Setup_Mailbox_Data(CAN_MB_To_IFM1,8,
						@Switches,
						@Switches+USEHB,
						@CAN_Controller_outputs,
						@Drive_state,
						@Pump_HM_scaled,
						@Pump_HM_scaled+USEHB,
						@Trac_HM_scaled,
						@Trac_HM_scaled+USEHB)	
						
														
  ;------------- MESSAGE 2 ----------------------
  ; MAILBOX 2
  ; Purpose        	 Send Message to IFM Module.
  ; Type           	 PDO2_MISO
  ; Standard COB ID	- 0x2a6      
  Setup_Mailbox(CAN_MB_To_IFM2,PDO2_MISO,0,38,C_CYCLIC,C_XMT,0,0)	 
  Setup_Mailbox_Data(CAN_MB_To_IFM2,8,
						@Keyswitch_voltage,
						@Keyswitch_voltage+USEHB,
						@Current_RMS,
						@Current_RMS+USEHB,
						@Battery_current,
						@Battery_current+USEHB,
						@Motor_RPM,
						@Motor_RPM+USEHB)			
						
						
  ;------------- MESSAGE 3 ----------------------
  ; MAILBOX 3
  ; Purpose        	 Send Message to IFM Module.
  ; Type           	 PDO3_MISO
  ; Standard COB ID	- 0x3a6      
  Setup_Mailbox(CAN_MB_To_IFM3,PDO3_MISO,0,38,C_CYCLIC,C_XMT,0,0)	 
  Setup_Mailbox_Data(CAN_MB_To_IFM3,8,
						@Status1,
						@Status2,
						@Status3,
						@Status4,
						@Status5,
						@Status6,
						@Status7,
						@UserFault1)	
						
								
  ;------------- MESSAGE 4 ----------------------
  ; MAILBOX 4
  ; Purpose        	 Send Message to IFM Module.
  ; Type           	 PDO4_MISO
  ; Standard COB ID	- 0x4a6      
  Setup_Mailbox(CAN_MB_To_IFM4,PDO4_MISO,0,38,C_CYCLIC,C_XMT,0,0)	 
  Setup_Mailbox_Data(CAN_MB_To_IFM4,8,
						@Total_HM_scaled,
						@Total_HM_scaled+USEHB,
						@Program_number_LO,
						@Program_number_LO+USEHB,
						@Program_number_HI,
						@Program_number_HI+USEHB,
						@Program_Revision,
						@BDI_Percentage)	
						
						
  ;------------- MESSAGE 5 ----------------------
  ; MAILBOX 5
  ; Purpose        	 Send Message to Pump Controller.
  ; Type           	 PDO1_MOSI
  ; Standard COB ID	- 0x227      
  Setup_Mailbox(CAN_MB_To_Pump,PDO_MOSI,0,39,C_CYCLIC,C_XMT,0,0)	 
  Setup_Mailbox_Data(CAN_MB_To_Pump,8,
						@CAN_Pump_Commands,
						@Throttle_Command,
						@Throttle_Command+USEHB,
						0,
						0,
						0,
						0,
						0)	
						
						
  ;------------- MESSAGE 6 ----------------------
  ; MAILBOX 6
  ; Purpose        	 Receive Message From Pump Controller.
  ; Type           	 PDO3_MISO
  ; Standard COB ID	- 0x1a7      
  Setup_Mailbox(CAN_MB_From_Pump,PDO_MISO,0,39,C_EVENT,C_RCV,0,0)	 
  Setup_Mailbox_Data(CAN_MB_From_Pump,8,
						@CAN_Pump_status,
						@CAN_Fault_Flash_Code_Pump,
						0,
						0,
						0,
						0,
						0,
						0)
						
						
	;------------- MESSAGE 7 ----------------------
  ; MAILBOX 6
  ; Purpose        	 Receive Message From PLC.
  ; Type           	 PDO3_MISO
  ; Standard COB ID	- 0x226     
  Setup_Mailbox(CAN_MB_From_PLC,PDO_MOSi,0,38,C_EVENT,C_RCV,0,0)	 
  Setup_Mailbox_Data(CAN_MB_From_PLC,8,
						@CAN_PLC_command,
						@CAN_Received_Empty1,
						@CAN_Max_Speed_MH,	; max speed in meter/hour
						@CAN_Max_Speed_MH+USEHB,
						@CAN_Received_Empty2,
						@CAN_Received_Empty3,
						@CAN_CRC,
						@CAN_CRC+USEHB)
						
																	
 ;-------------- START UP CAN COMMUNICATION -----------------
  Startup_CAN()
	CAN_Set_Cyclic_Rate(5) 		;this sets the cyclic cycle to every 20 ms(4ms x 5 =20ms)
	Startup_CAN_Cyclic()
	return	
	
	
CRC_Process:
	Bit_Counter = 0
	
	while (Bit_Counter<8)
	{
		if (CRC_Calc.32768 = ON)
		{
			CRC_Calc = (CRC_Calc<<1)^CRC_Seed
		}
		else
		{
			CRC_Calc = (CRC_Calc<<1)
		}
		Bit_Counter = Bit_Counter + 1
	}
return


;========================================================================
;           1311/1314 Parameter, Monitor, and Fault Declarations
; These are generally placed at the end of the program, because they can
; be large, and hinder the general readability of the code when placed
; elsewhere.  Please note that Aliases and other declared variables
; cannot be used as addresses in parameter declarations, Only native
; OS variable names may be used.
;=======================================================================

;MONITOR:	
;################################################
;	PARAMETER_ENTRY	"TLD"
;		TYPE		MONITOR
;		LEVEL		1
;		END
;################################################
		;----------------------------------------------	
		;	PARAMETER_ENTRY	"Hourmeters"
		;		TYPE		MONITOR
		;		LEVEL		2
		;	END
	
			;----------------------------------------------	
			;	PARAMETER_ENTRY	"Total Hourmeter"
			;		TYPE		MONITOR
			;		LEVEL		3
			;	END
			
				;	PARAMETER_ENTRY	"Total Hourmeter Enabled"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		TMR1_enable
				;		SIGNED		NO
				;	END			
	
				;	PARAMETER_ENTRY	"Total Hourmeter"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		User6
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		20000
				;		MAXDSP		20000
				;		DECIMALPOS	0
				;		SIGNED		NO
				;		UNITS		hour
				;	END
				
				;	PARAMETER_ENTRY	"Total maintanence after"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		user4
				;		DECIMALPOS	0
				;		SIGNED		YES
				;		UNITS		hour
				;	END
		
				;	PARAMETER_ENTRY "Total Maintance expired"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT1
				;		BITSELECT	2
				;	END	
	
			;----------------------------------------------	
			;	PARAMETER_ENTRY	"Traction Hourmeter"
			;		TYPE		MONITOR
			;		LEVEL		3
			;	END		
			
				;	PARAMETER_ENTRY	"Traction Hourmeter Enabled"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		TMR2_enable
				;		SIGNED		YES
				;	END
				
				;	PARAMETER_ENTRY	"Traction Hourmeter"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		User7
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		20000
				;		MAXDSP		20000
				;		DECIMALPOS	0
				;		SIGNED		NO
				;		UNITS		hour
				;	END
				
				;	PARAMETER_ENTRY	"Traction maintanence after"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		user5
				;		DECIMALPOS	0
				;		SIGNED		YES
				;		UNITS		hour
				;	END
		
				;	PARAMETER_ENTRY "Traction Maintance expired"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT1
				;		BITSELECT	5
				;	END	
				
			;----------------------------------------------	
			;	PARAMETER_ENTRY	"Pump Hourmeter"
			;		TYPE		MONITOR
			;		LEVEL		3
			;	END		
			
				;	PARAMETER_ENTRY	"Pump Hourmeter Enabled"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		TMR3_enable
				;		SIGNED		YES
				;	END
				
				;	PARAMETER_ENTRY	"Pump Hourmeter"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		User21
				;		MINRAW		0
				;		MINDSP		0
				;		MAXRAW		20000
				;		MAXDSP		20000
				;		DECIMALPOS	0
				;		SIGNED		NO
				;		UNITS		hour
				;	END
				
				;	PARAMETER_ENTRY	"Pump maintanence after"
				;		TYPE		MONITOR
				;		WIDTH		16BIT
				;		ADDRESS		user20
				;		DECIMALPOS	0
				;		SIGNED		YES
				;		UNITS		hour
				;	END
		
				;	PARAMETER_ENTRY "Pump Maintance expired"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT2
				;		BITSELECT	7
				;	END	
				
			
			;----------------------------------------------	
			;	PARAMETER_ENTRY	"Options"
			;		TYPE		MONITOR
			;		LEVEL		2
			;	END			
				
				;	PARAMETER_ENTRY "Opt no touch"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT8
				;		BITSELECT	1
				;	END	
				
				;	PARAMETER_ENTRY "ASD Active"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT8
				;		BITSELECT	2
				;	END	

				;	PARAMETER_ENTRY "Alt Control"
				;		TYPE		MONITOR
				;		WIDTH		8BIT
				;		ADDRESS		USER_BIT8
				;		BITSELECT	3
				;	END	

;################################################
;PARAMETER FAULTS:	
;################################################

	;	PARAMETER_ENTRY	"HPD"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			0
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"SRO"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			1
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"Inching Fault"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			2
	;	BITACTIVELOW	NO
	;	END	
	
	;	PARAMETER_ENTRY	"Deadman Fault"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			3
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"Pump PDO Timeout"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			4
	;	BITACTIVELOW	NO
	;	END	
	
	;	PARAMETER_ENTRY	"SRO"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			5
	;	BITACTIVELOW	NO
	;	END	


	;	PARAMETER_ENTRY	"Handbrake fault"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			6
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"Pump in fault"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault1_History
	;	ADDRESS				UserFault1
	;	BITSELECT			7
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"Pedal Faulted"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault2_History
	;	ADDRESS				UserFault2
	;	BITSELECT			0
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"CAN PLC Error left sensor"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault2_History
	;	ADDRESS				UserFault2
	;	BITSELECT			1
	;	BITACTIVELOW	NO
	;	END	
	
	;	PARAMETER_ENTRY	"CAN PLC Error right sensor"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault2_History
	;	ADDRESS				UserFault2
	;	BITSELECT			2
	;	BITACTIVELOW	NO
	;	END	

	;	PARAMETER_ENTRY	"CAN PLC PDO Timeout"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault2_History
	;	ADDRESS				UserFault2
	;	BITSELECT			3
	;	BITACTIVELOW	NO
	;	END	
	
	;	PARAMETER_ENTRY	"CAN PLC CRC fault"
	;	TYPE					FAULTS
	;	WIDTH					8BIT
	;	ALT_ADDRESS		UserFault2_History
	;	ADDRESS				UserFault2
	;	BITSELECT			4
	;	BITACTIVELOW	NO
	;	END	

				