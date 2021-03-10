from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["NBL_Traction"]
        self.ids=["1A6","2A6","3A6","4A6","227"]

    def parse(self,IdString,DataString):
        toRet = "NBL Drive   :"
        # toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        ##########################

        if IdString == "1A6":
            toRet = toRet + " NBL Drive<br><br>" + \
                    lineDesc + "[0,1] 0x{:04X}  = Switches{}<br>" + \
                    lineDesc + "[2,2] 0x{:04X}  = CAN_Controller_outputs {}<br>" + \
                    lineDesc + "[3,3] 0x{:04X}  = Drive_state{}<br> " + \
                    lineDesc + "[4,5] 0x{:04X}  = Pump_HM_scaled{}<br> " + \
                    lineDesc + "[6,7] 0x{:04X}  = Trac_HM_scaled{}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 0, 16)), getBytes(DataString, 0, 16),
                (getBytes(DataString, 2,  8)), getBytes(DataString, 2, 8),
                (getBytes(DataString, 3,  8)), getBytes(DataString, 3, 8),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
            """Purpose        	 Send Message to IFM Module.
                    ; Type           	 PDO1_MISO
                    ; Standard COB ID	- 0x1a6
                    Setup_Mailbox(CAN1,PDO_MISO,0,38,C_CYCLIC,C_XMT,0,0)
                    Setup_Mailbox_Data(CAN1,8,
                            @Switches,
                            @Switches+USEHB,
                            @CAN_Controller_outputs,
                            @Drive_state,
                            @Pump_HM_scaled,
                            @Pump_HM_scaled+USEHB,
                            @Trac_HM_scaled,
                            @Trac_HM_scaled+USEHB)			"""

        elif IdString == "3A6":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " NBL Drive<br><br>" + \
                    lineDesc + "[0,6] {}  = Status 1-7<br>" + \
                    lineDesc + "[7,7] {}  = UserFault <br>"
            toRet = toRet.format(
                DataString[:21],
                DataString[21:]
            )
            """
            ; MAILBOX 3
                    ; Purpose        	 Send Message to IFM Module.
                    ; Type           	 PDO3_MISO
                    ; Standard COB ID	- 0x3a6
                    Setup_Mailbox(CAN3,PDO3_MISO,0,38,C_CYCLIC,C_XMT,0,0)
                    Setup_Mailbox_Data(CAN3,8,
                            @Status1,
                            @Status2,
                            @Status3,
                            @Status4,
                            @Status5,
                            @Status6,
                            @Status7,
                            @UserFault1)
                """
        elif IdString == "2A6":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " NBL Drive<br><br>" + \
                    lineDesc + "[0,1] 0x{:04X} KSI = {}<br>" + \
                    lineDesc + "[2,3] 0x{:04X} Phas Current = {}<br>" + \
                    lineDesc + "[4,5] 0x{:04X} Batt Current = {}<br> " + \
                    lineDesc + "[6,7] 0x{:04X} Motor RPM = {}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 0, 16)), getBytes(DataString, 0, 16),
                (getBytes(DataString, 2, 16)), getBytes(DataString, 2, 16),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
            """
            ; MAILBOX 2
                    ; Purpose        	 Send Message to IFM Module.
                    ; Type           	 PDO2_MISO
                    ; Standard COB ID	- 0x2a6
                    Setup_Mailbox(CAN2,PDO2_MISO,0,38,C_CYCLIC,C_XMT,0,0)
                    Setup_Mailbox_Data(CAN2,8,
                            @Keyswitch_voltage,
                            @Keyswitch_voltage+USEHB,
                            @Current_RMS,
                            @Current_RMS+USEHB,
                            @Battery_current,
                            @Battery_current+USEHB,
                            @Motor_RPM,
                            @Motor_RPM+USEHB)
                            """
        elif IdString == "4A6":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " NBL Drive<br><br>" + \
                    lineDesc + "[0,1] 0x{:04X} Total HourMeter = {}<br>" + \
                    lineDesc + "[2,3] 0x{:04X} Program Num Low <br>" + \
                    lineDesc + "[4,5] 0x{:04X} Program Num High <br> " + \
                    lineDesc + "[6,7] 0x{:04X} Program Rev = {}<br>"     + \
                    lineDesc + "[6,7] 0x{:04X} BDI = {}%<br>"
            toRet = toRet.format(
                (getBytes(DataString, 0, 16)), getBytes(DataString, 0, 16),
                (getBytes(DataString, 2, 16)),
                (getBytes(DataString, 4, 16)),
                (getBytes(DataString, 6,  8)), getBytes(DataString, 6,  8),
                (getBytes(DataString, 7,  8)), getBytes(DataString, 7, 8))
            """
            ; MAILBOX 4
                    ; Purpose        	 Send Message to IFM Module.
                    ; Type           	 PDO4_MISO
                    ; Standard COB ID	- 0x4a6
                    Setup_Mailbox(CAN4,PDO4_MISO,0,38,C_CYCLIC,C_XMT,0,0)
                    Setup_Mailbox_Data(CAN4,8,
                            @Total_HM_scaled,
                            @Total_HM_scaled+USEHB,
                            @Program_number_LO,
                            @Program_number_LO+USEHB,
                            @Program_number_HI,
                            @Program_number_HI+USEHB,
                            @Program_Revision,
                            @BDI_Percentage)
                            """
        elif IdString == "227":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            """ CAN_Start_pump_from_drive			bit	CAN_Pump_Commands.1
                CAN_Disable_Belt							bit	CAN_Pump_Commands.2
                CAN_Neutral_direction_flag		bit	CAN_Pump_Commands.4	"""

            toRet = toRet + " NBL Drive command to PUMP<br><br>" + \
                    lineDesc + "[0,0] 0x{:02X} CAN_Pump_Commands    NeutralDir / Disable Belt / StartPumpFromDrive<br>" + \
                    lineDesc + "[1,2] 0x{:04X} Throttle Command <br>" + \
                    lineDesc + "[3,7] 0x{} Program Num High <br> "

            toRet = toRet.format(
                (getBytes(DataString, 0, 8)), getBytes(DataString, 0, 8),
                (getBytes(DataString, 1, 16)))


        return toRet
