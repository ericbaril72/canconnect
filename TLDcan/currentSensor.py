def getBytes(a,b,c):
    return 0.1

try:
    from TLDcan.decode import getBytes
except:
    print("Could not init getbyte")

class Parser:
    def __init__(self):
        self.defines = ["CurrentSensor"]
        self.ids=["3C2"]

    def parse(self,IdString,DataString):
        value = getBytes(DataString, 0, -32)

        toRet = "CurrentSensor +++: {:>03.3f} Amps ".format(value / 1000)
        return toRet




"""
elif IdString in CurrentSensor:
    DataString3 = "81 00 00 00 C8 Ca B5 16"
    DataString1 = "80 10 00 00 C8 Ca B5 16"
    DataString2 = "7f FF FF 00 C8 Ca B5 16"
    DataString4 = "7f FF FF FE C8 Ca B5 16"
    toRet1  = ":"+DataString3 + self.parseCurrentSensor(IdString, DataString3)  + "<br>"
    toRet1 = DataString2+ self.parseCurrentSensor(IdString, DataString2) + "<br>"
    toRet1 = DataString4+ self.parseCurrentSensor(IdString, DataString4)  + "<br>"
    toRet = DataString + self.parseCurrentSensor(IdString, DataString) + "<br>"
"""

