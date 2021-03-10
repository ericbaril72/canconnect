from TLDcan.decode import getBytes

def CanDecode():
    pass

class Parser:
    def __init__(self):
        self.defines = ["Loader_Pump"]
        self.ids=["70B","8B","18B","28B","20B","30B"]
        self.IdString=""
        self.DataString=""
    def CanData(self,position,type):
        return getBytes(self.DataString, position, type)

    def parse(self,IdString,DataString):
        self.IdString=IdString
        self.DataString=DataString

        toRet="PUMP   :"
        #toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        ##########################

        if IdString == "70B":
            toRet = toRet + "HearthBeat"

        elif IdString == "8B":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + "Emergency"

        elif IdString == "20B":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " PLC CMD<br><br>"+\
                    lineDesc+"[2,3] 0x{:04X} throttle = {}<br>"+ \
                    lineDesc+"[4,5] 0x{:04X} pump nominalspeed = {}<br> "+ \
                    lineDesc+"[6,7] 0x{:04X} pump percent = {}<br>"
            toRet= toRet.format(
                        (getBytes(DataString, 2, 16)),getBytes(DataString, 2, 16),
                        (getBytes(DataString, 4, 16)),getBytes(DataString, 4, 16),
                        (getBytes(DataString, 6, 16)),getBytes(DataString, 6, 16))
            toRet  = toRet + " PLC CMD<br><br>"
            toRet += "[2,3] 0x{:04X} throttle = {}          <br>".format(self.CanData(2,16),self.CanData(2,16))
            toRet += "[4,5] 0x{:04X} pump nominalspeed = {} <br>".format(self.CanData(4,16),self.CanData(4,16))
            toRet += "[6,7] 0x{:04X} pump percent = {}      <br>".format(self.CanData(6,16),self.CanData(6,16))

        elif IdString == "30B":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
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
            toRet  = " PLC CMD<br><br>"
            toRet += "[0,1] 0x{:04X} R_Input = {}<br>       ".format(self.CanData(0,16),self.CanData(0,16))
            toRet += "[2,3] 0x{:04X} CurtisVoltage = {} V<br> ".format(self.CanData(2,16),self.CanData(2,16)/100)
            toRet += "[4,5] 0x{:04X} Motor Temp = {} C<br>    ".format(self.CanData(4,16),self.CanData(4,16)/10)
            toRet += "[6,7] 0x{:04X} Drive Temp = {} C<br>    ".format(self.CanData(6,16),self.CanData(6,16)/10)
        """
        From VCL
        (* PDO T1 *)
            PDO_T1.DATA[2] := WORD_TO_BYTE(INT_TO_WORD(INT_VCLThrottleCommand) AND 16#00FF);
            PDO_T1.DATA[3] := WORD_TO_BYTE(SHR(INT_TO_WORD(INT_VCLThrottleCommand) AND 16#FF00,8));

            PDO_T1.DATA[4] := WORD_TO_BYTE(W_RegenNominalSpeed AND 16#00FF);
            PDO_T1.DATA[5] := WORD_TO_BYTE(SHR(W_RegenNominalSpeed AND 16#FF00,8));

            PDO_T1.DATA[6] := WORD_TO_BYTE(W_RegenPercent AND 16#00FF);
            PDO_T1.DATA[7] := WORD_TO_BYTE(SHR(W_RegenPercent AND 16#FF00,8));

        (* PDO T2 *)
            (*PDO_T2.DATA[0] := WORD_TO_BYTE(INT_TO_WORD(G_BatteryCurrent) AND 16#00FF);*)
            PDO_T2.DATA[0] := WORD_TO_BYTE(G_BatteryLevel AND 16#00FF);
            (*PDO_T2.DATA[1] := WORD_TO_BYTE(SHR(INT_TO_WORD(G_BatteryCurrent) AND 16#FF00,8));*)
            PDO_T2.DATA[1] := WORD_TO_BYTE(SHR(G_BatteryLevel AND 16#FF00,8));
        """

        # print("toRet:",toRet)
        return toRet
