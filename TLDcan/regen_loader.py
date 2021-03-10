from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["Loader_Regen"]
        self.ids=["70D","8D","18D","28D","20D","30D"]

    def parse(self,IdString,DataString):
        parseData = {"fct": "Regen" }

        toRet="REGEN   :"
        #toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        ##########################
        if IdString == "70D":
            toRet = toRet + "HearthBeat"


        elif IdString == "20D":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " PLC CMD<br><br>" + \
                    lineDesc + "[2:3] 0x{:04X} throttle = {}<br>" + \
                    lineDesc + "[4,5] 0x{:04X} pump nominalspeed = {}<br> " + \
                    lineDesc + "[6,7] 0x{:04X} pump percent = {}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 2, 16)), getBytes(DataString, 2, 16),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
        elif IdString == "30D":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
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
        # print("toRet:",toRet)
        return toRet

