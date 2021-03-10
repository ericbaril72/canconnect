class Parser:
    def __init__(self):
        self.defines = ["Loader_Diagnostics"]
        self.ids=["110","120","121","122"]

    def parse(self,IdString,DataString):
        toRet="Diag   :"
        toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        return toRet

