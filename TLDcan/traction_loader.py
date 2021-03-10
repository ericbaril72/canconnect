from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["Loader_Traction"]
        self.ids=["70C","8C","18C","28C","20C","30C"]

    def parse(self,IdString,DataString):
        toRet="Traction   :"
        #toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        ##########################

        if IdString == "70C":
            toRet=""
            lineDesc=""
            toRet = toRet + "HB"
        elif IdString == "20C":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " PLC CMD<br><br>"+\
                    lineDesc+"[2:3] 0x{:04X} throttle = {}<br>"+ \
                    lineDesc+"[4,5] 0x{:04X} pump nominalspeed = {}<br> "+ \
                    lineDesc+"[6,7] 0x{:04X} pump percent = {}<br>"
            toRet= toRet.format(
                        (getBytes(DataString, 2, 16)),getBytes(DataString, 2, 16),
                        (getBytes(DataString, 4, 16)),getBytes(DataString, 4, 16),
                        (getBytes(DataString, 6, 16)),getBytes(DataString, 6, 16))
            toRet = toRet + " PLC CMD<br><br>"
        elif hex(int("0x"+IdString,16) & 0x7F0) == "0x180":
            toRet = lineDesc + "[0,1] 0x{:04X} inputCurrent = {}<br>" + \
                    lineDesc + "[4,5] 0x{:04X} motor RPM = {}<br> " + \
                    lineDesc + "[6,7] 0x{:04X} motorCurrent = {}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 2, 16)), getBytes(DataString, 2, 16),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
        elif hex(int("0x" + IdString, 16) & 0x7F0) == "0x280":
            toRet = lineDesc + "[0,1] 0x{:04X} R_Input = {}<br>" + \
                    lineDesc + "[2,3] 0x{:04X} CurtisVoltage = {}<br> " + \
                    lineDesc + "[4,5] 0x{:04X} Motor Temp = {}<br> " + \
                    lineDesc + "[6,7] 0x{:04X} Drive Temp = {}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 0, 16)), getBytes(DataString, 0, 16),
                (getBytes(DataString, 2, 16)), getBytes(DataString, 2, 16),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
        else:
            toRet += " 18C "+IdString+"--"+hex(int("0x"+IdString,16) & 0x7F0)+"<"+hex(int("0x"+IdString,16) & 0x7F8)+"<"
        """
        # 180
        F PDO_R1.AVAILABLE>0 THEN
        R_InputCurrent := (BYTE_TO_REAL(PDO_R1.DATA[0])+BYTE_TO_REAL(PDO_R1.DATA[1])*256)/10;
        IF R_InputCurrent > 3276.8 THEN
            R_InputCurrent := REAL_TO_INT(R_InputCurrent - 6553.6);
        END_IF
        INT_MotorRPM := BYTE_TO_INT(PDO_R1.DATA[4])+BYTE_TO_INT(PDO_R1.DATA[5])*256;
        INT_MotorCurrent := (BYTE_TO_INT(PDO_R1.DATA[6])+BYTE_TO_INT(PDO_R1.DATA[7])*256)/10;


        ID:280
        R_Input1:= (BYTE_TO_REAL(PDO_R2.DATA[0]) + BYTE_TO_REAL(PDO_R2.DATA[1]) * 256) / 9.2;
        CurtisVoltage:= (BYTE_TO_REAL(PDO_R2.DATA[2]) + BYTE_TO_REAL(PDO_R2.DATA[3]) * 256) / 100;
        I_MotorTemperature:= (BYTE_TO_INT(PDO_R2.DATA[4]) + BYTE_TO_INT(PDO_R2.DATA[5]) * 256) / 10;
        I_CurtisTemperature:= (BYTE_TO_INT(PDO_R2.DATA[6]) + BYTE_TO_INT(PDO_R2.DATA[7]) * 256) / 10;
        (*To
        be
        setup
        by
        curtis in PAR
        file *)"""
        # print("toRet:",toRet)
        return toRet