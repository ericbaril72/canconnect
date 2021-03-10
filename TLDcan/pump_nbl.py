from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["NBL_Pump"]
        self.ids=["2A8","1A8","3A8","4A8","1A7"]

    def parse(self,IdString,DataString):
        toRet = "NBL Pump   :"
        # toRet += " 0x{:02X}\t".format(int(IdString, 16) & 0x7F)
        lineDesc = toRet
        ##########################

        if IdString == "1A8":
            toRet = toRet + "unknown nbl"

        elif IdString == "3A8":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + "unknown nbl"
        elif IdString == "2A8":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            toRet = toRet + " NBL Pump<br>" + \
                    lineDesc + "[2,3] 0x{:04X}  = {}<br>" + \
                    lineDesc + "[4,5] 0x{:04X}  = {}<br> " + \
                    lineDesc + "[6,7] 0x{:04X} Pump Current = {}<br>"
            toRet = toRet.format(
                (getBytes(DataString, 2, 16)), getBytes(DataString, 2, 16),
                (getBytes(DataString, 4, 16)), getBytes(DataString, 4, 16),
                (getBytes(DataString, 6, 16)), getBytes(DataString, 6, 16))
        elif IdString == "1A7":
            toRet = toRet + " NBL Pump command to Drive<br>"
            toRet = toRet + " Pump Status    /  Fault Flash Code PUmp<br>" \
                            """CAN_Pump_hourmeter_ON					bit	CAN_Pump_status.1<br>
        CAN_Pump_Drive_disable				bit	CAN_Pump_status.2<br>
        CAN_Pump_Ignition_protection	bit	CAN_Pump_status.4<br>
        CAN_Belt_hourMeter_ON					bit	CAN_Pump_status.8<br>
        CAN_Pump_faulted_flag					bit	CAN_Pump_status.16		"""
        return toRet