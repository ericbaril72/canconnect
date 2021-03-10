from TLDcan.decode import getBytes

class Parser:
    def __init__(self):
        self.defines = ["IBS"]
        self.ids=["2F0","2F1","2F2","2F3","326","189","289","389","489","20A","20B","2F4","2F5"]
        """
        CAN communication normal (Data: 0xAA)
        Data: 0xA5: Start Heater Manually.
        2nd Byte Charger AC Current Limit
        3rd Byte SOC Protect Value
        """

    def parse(self,IdString,DataString):
        toRet =""
        if IdString == "2F0":
            Voltage=getBytes(DataString,0,16)/10
            Current=getBytes(DataString,2,16)

            if Current & 0x8000:
                Current = (0xFFFF-Current)/10
            else:
                Current = Current/10

            SOC=getBytes(DataString,4,8)
            Capacity=getBytes(DataString,5,8)
            StatusFlag=getBytes(DataString,6,8)
            StatFlag2=getBytes(DataString,7,8)

            toRet += "2f0   {}V \t{}Amps \tSOC:{}%\tCapacity:{}\tStatus: {} {}".format(Voltage,Current,SOC,Capacity,StatusFlag,StatFlag2)

        elif IdString == "2F1":
            CellMaxVolt=getBytes(DataString,0,16)/1000
            CellMaxPos=getBytes(DataString,2,16)
            CellMinVolt=getBytes(DataString,4,16)/1000
            CellMinPos=getBytes(DataString,6,16)

            toRet += "2f1   CellMax:{}V  idx:{:08b}\t\t\nCellMin:{}V idx:{:08b}".format(CellMaxVolt,CellMaxPos,CellMinVolt,CellMinPos)
        elif IdString == "2F2":
            CellMaxTemp=getBytes(DataString,0,16)/10
            CellMaxPos=getBytes(DataString,2,16)
            CellMinTemp=getBytes(DataString,4,16)/10
            CellMinPos=getBytes(DataString,6,16)

            toRet += "2f2   CellMax:{}C   idx:{:08b}\t\t CellMin{}C idx:{:08b}".format(CellMaxTemp,CellMaxPos,CellMinTemp,CellMinPos)

        elif IdString == "2F3":
            DischargeHours=getBytes(DataString,0,16)
            ChargeHours=getBytes(DataString,2,16)
            RelayFlags=getBytes(DataString,4,8)
            PackSafetyFlag=getBytes(DataString,5,8)
            PackStatusFlag=getBytes(DataString,6,8)
            PLCFaultCode=getBytes(DataString,7,8)
            toRet += "2f3   DiscHrs:{}\tChargeHrs:{}  RelayFlags:{}\tSafetyFlags:{}   PLC_Fault:{}".format(DischargeHours,ChargeHours,RelayFlags,PackSafetyFlag,PackStatusFlag,PLCFaultCode)

        elif IdString == "326":
            MaxDiscCurrent = (0x7FFF & getBytes(DataString,0,16))/10
            MaxChargeCurrent=getBytes(DataString,2,16)/10

            ChargeVoltageRequires = getBytes(DataString,4,16)
            ChargerCurrentRequires= getBytes(DataString,6,16)
            toRet += "326   MaxDisCurrent:{}\t\tMaxFeedBackCurrent:{}<br>" \
                     "ChargeVoltageRequires:{}   ChargeCurrentRequires:{}".format(MaxDiscCurrent,MaxChargeCurrent,ChargeVoltageRequires,ChargerCurrentRequires)

        elif IdString== "189":
            toRet += "189 Charger ACInput Current, DOD, SOH, Pack status"
        elif IdString== "289":
            toRet += "289 sub packs status"
        elif IdString== "389":
            toRet += "389 System fault code"
        elif IdString== "489":
            ChargerCurrentDC = getBytes(DataString,4,16)
            ChargingRemainingTime = getBytes(DataString,6,16)
            toRet += "489"
        elif IdString== "2F4":
            toRet += "2F4 Heating Status"
        elif IdString== "2F5":

            toRet += "2F5 software Rev:"+getBytes(DataString,0,8)+'.'+getBytes(DataString,1,8)+'.'+getBytes(DataString,2,8)
        elif IdString== "20A":

            toRet += "20A "+getBytes(DataString,0,8)+'.'+getBytes(DataString,1,8)+'.'+getBytes(DataString,2,8)
        elif IdString== "20B":

            toRet += "20B "+getBytes(DataString,0,8)+'.'+getBytes(DataString,1,8)+'.'+getBytes(DataString,2,8)
        return toRet


