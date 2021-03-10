from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["GreenCube"]
        self.ids=["19C","29C","39C","71C","28C","38C","48C"]

    def parse(self,IdString,DataString):
        toRet = "GreenCube: "
        toRet += " id:0x{:02X}\t".format(int(IdString, 16) & 0x7F)

        if IdString in ["19C","38C"]:
            datastr = DataString
            SOC     = str(int(datastr[0:2], 16))
            Status  = bin(int(datastr[3:5], 16))[2:].zfill(8)
            Voltage = getBytes(DataString, 2, 32)

            Current = int(datastr[18:20], 16) + 256 * (int(datastr[21:23], 16))
            Current = getBytes(DataString,6,16)


            toRet = toRet + \
                "Batterie 19c   SOC(0):" + SOC + \
                "\tStatus(1):" + Status + \
                "\tVoltage(2-5):" + str(int(1000 * Voltage / 1024) / 1000) + \
                "\t\r\nI(6-7):" + str(0 + Current / 15)

        elif IdString in ["29C","48C"]:
            datastr = DataString
            DisVoltageLimit = int(datastr[6:8], 16) + 256 * int(datastr[9:11], 16) + 256 * 256 * int(datastr[12:14],
                                                                                                     16) + 256 * 256 * 256 * int(
                datastr[15:17], 16)
            MaxDisCurrent = int(datastr[0:2], 16) + 256 * (int(datastr[3:5], 16))
            Temperature = int(datastr[18:20], 16) + 256 * (int(datastr[21:23], 16))
            toRet = toRet + \
                    "Batterie 29c   VMin: " + str(int(1000 * DisVoltageLimit / 1024) / 1000) + \
                    "\tImax:" + str(MaxDisCurrent / 16) + \
                    "\tTemp:" + str(Temperature / 8) + \
                    "\t" + str(getBytes(datastr, 2, 32) / 1024)

        elif IdString in ["39C","28C"]:
            toRet = toRet + "Batterie 39c ?:" + str(getBytes(DataString, 0, 32)) + " == " + str(
            getBytes(DataString, 0, 16) / 16)
        elif IdString == "71C":
            toRet = "GreenCube HB"
        else:
            toRet+= IdString
        return toRet


