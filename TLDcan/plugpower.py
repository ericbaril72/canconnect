from TLDcan.decode import getBytes as getBytes

class Parser:
    def __init__(self):
        self.defines = ["PlugPower"]
        self.ids=["770","1F0"]
        self.emitids={"1AB":{"cycle":100,"vars":["battVolt","Current"]}}
        self.VBatt = 33.3

    def actuitymethod1(self):
        return 0

    def parseobj(self,IdString,DataString):
        if IdString=="770":
            try:
                toRet={"PlugPower HearthBeat":1}
            except Exception as e:
                toRet={"PlugPower HearthBeat":str(e)}

        elif IdString=="1F0":
            BattVolt = getBytes(DataString, 0, 16) / 100
            V_measured = BattVolt
            Current = (getBytes(DataString, 2, 16)-65536) / 10
            Temperature = getBytes(DataString, 4, 16) / 100
            SOC = getBytes(DataString, 1, 8)


            toRet = "[0-1] {:3.3f}Volts<br>".format(SOC)
            toRet +="[2-3] I:{}Amps<br>".format(Current)
            toRet +="[4-5]T:{}C<br>".format(Temperature)
            toRet +="[7] SOC:{}%\n{:<80s}{:1.2f}V/cell   ".format(SOC, " ", BattVolt / 40)
            toRet2 = {"BattVolt"     : V_measured,
                      "Current"     : Current,
                      "Temperature" : Temperature,
                      "SOC"         : SOC
                      }
        """
        TIME_226:=T#50ms;
	DATA_226[0].0 := gq_NoTouchStop;		 	 (*Force trottle = 0, brake = 100 to Curtis controller. Active engine brake only, not hydraulic, ignored if ASD off or if error*)
	DATA_226[0].1 := gq_Opt_NoTouch;			 (*If Option if Off, Controller will react to OUT_medium speed and OUT_low speed. Same behaviour as old ASD *)
	DATA_226[0].2 := gat_Inputs[e_I_BpActivation].q_Value; (*ASD Active - Used to limit speed in case of errors and modify response to other bits *)
	DATA_226[0].3 := (gu16_AircraftDiastance < 3500) OR (gs16_ActualSpeedmh > gs16_ActualVmax*1.1);(*Alternate_control - switch gains and ramps to tighter values for better slow speed control, Ignored if ASD off or if error *)
	DATA_226[0].4 := (NOT gq_AliveLidLeft); 	(*Left sensor error, message displayed and speed reduced if TRUE*) (*TODO - obstruction detection and other errors *)
	DATA_226[0].5:=  (NOT gq_AliveLidRight); 	(*Right sensor error, message displayed and speed reduced if TRUE*) (*TODO - obstruction detection and other errors *)
	DATA_226[0].6:=TRUE;						(*Reserved, set to TRUE for CRC*)
	DATA_226[0].7:=TRUE;						(*Reserved, set to TRUE for CRC*)

	DATA_226[1]:= 16#FF;						(*Reserved, set to TRUE for CRC*)
	DATA_226[2]:= INT_TO_BYTE(gs16_ActualVmax);
	DATA_226[3]:= INT_TO_BYTE(SHR(gs16_ActualVmax,8));
	DATA_226[4]:= 16#FF; 						(*Reserved, set to TRUE for CRC*)
	DATA_226[5]:= 16#FF;						(*Reserved, set to TRUE for CRC*)

	(*Calculate CRC for message 226*)
	u16_CRCresult:=0;
	FOR I:=0 TO 5 DO
		u16_CRCresult:= u16_CRCresult XOR (SHL(BYTE_TO_WORD(DATA_226[I] ) , 8));
		FOR J:=0 TO 7 DO
			IF (u16_CRCresult AND 16#8000) <> 16#0000 THEN
				u16_CRCresult:=SHL(u16_CRCresult,1) XOR u16_CRC_KEY;
			ELSE
				u16_CRCresult:=SHL(u16_CRCresult,1);
			END_IF
		END_FOR
	END_FOR

	(*Add CRC result at end of message 226 *)
	DATA_226[6]:= WORD_TO_BYTE(u16_CRCresult);
	DATA_226[7]:= WORD_TO_BYTE(SHR(u16_CRCresult,8));
END_IF

CAN_TX_226(
	ENABLE:= gu16_VehicleType = eType_RBL OR gu16_VehicleType = eType_NBL ,
	CHANNEL:= 1,
	ID:= 16#226 ,
	Extended:= FALSE ,
	DataLengthCode:=8 ,
	DATA:=DATA_226 ,
	PERIOD:=T#100ms ,
	RESULT=> );

        """
def crc():
    Crc_key = 0xe36c

    Data = [1,0,0,0,0,0]
    u16_CRCresult = 0
    for i in range(0,6):
        u16_CRCresult = u16_CRCresult ^ Data[i]
        print(i,u16_CRCresult)
        for j in range(0,8):
            if (u16_CRCresult & 0x8000) != 0x0:
                u16_CRCresult = (u16_CRCresult <<1) ^ Crc_key
            else:
                u16_CRCresult = u16_CRCresult << 1
    return u16_CRCresult
        return toRet

    def parse(self,IdString,DataString):
        if IdString=="770":
            try:
                toRet="PlugPower HearthBeat:"
            except Exception as e:
                toRet="PlugPower HearthBeat "+str(e)

        elif IdString=="1F0":

            SOC = getBytes(DataString, 1, 8)
            decodeing=FCerror
            """FCfulltravel := FuelCell_RX.DATA[2].0;
            FClimptravel := FuelCell_RX.DATA[2].1;
            FCfullhydr := FuelCell_RX.DATA[2].2;
            FClimphydr := FuelCell_RX.DATA[2].3;

            FCerror :=			FuelCell_RX.DATA[0].0;
            FCenable	:=		FuelCell_RX.DATA[0].1;
            FCloadshed	:=	FuelCell_RX.DATA[0].2;
            FCrefuel	:=		FuelCell_RX.DATA[0].3;
            FChighwater	:=	FuelCell_RX.DATA[0].4;
            FCews	:=			FuelCell_RX.DATA[0].5;
            FClowfuel	:=		FuelCell_RX.DATA[0].6;

            """
            toRet = "[ 1 ] {} % SOC<br>".format(SOC)
            toRet +="[2-3] I:{}Amps<br>".format(Current)
            toRet +="[4-5]T:{}C<br>".format(Temperature)
            toRet +="[7] SOC:{}%\n{:<80s}{:1.2f}V/cell   ".format(SOC, " ", BattVolt / 40)
            return toRet

        else:
            toRet="?"
        return toRet

