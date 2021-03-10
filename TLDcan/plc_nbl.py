from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["NBL_PLC"]
        self.ids=["226"]

    def parse(self,IdString,DataString):
        if IdString == "226":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            self.isNBL = True
            self.isloader = False
            lineDesc=""
            toRet =   " NBL PLC CMD<br><br>"
            toRet =   "[0:0] 0x{:04X} Command = {} bit1: brake<br>" + \
                    lineDesc + "[1,7] 0x{} <br> "

            toRet = toRet.format(
                (getBytes(DataString, 0, 8)), getBytes(DataString, 0, 8),0)


        return toRet


