class Parser:
    def __init__(self):
        self.defines = ["Loader_DCDC"]
        self.ids=["071D","9D","19D","21D","29D","31D"]

    def parse(self,IdString,DataString):
        toRet="DCDC   :"
        toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)


        if IdString == "70D":
            toRet = toRet + "HearthBeat"


        return toRet

