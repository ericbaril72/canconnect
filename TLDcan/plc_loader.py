class Parser:
    def __init__(self):
        self.defines = ["Loader_PLC"]
        self.ids=["703","000","080","083","303","203","403","503","603"]

    def parse(self,IdString,DataString):
        toRet=""
        if IdString == "703":
            self.isNBL = False
            self.isloader = True
            toRet = "PLC HearthBeat"
        elif IdString == "80":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + "SYNC"
        elif IdString == "0":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + "NMT"

        return toRet



