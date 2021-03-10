
try:
    from TLDcan.decode import getBytes
except:
    print("Could not init getbyte")

decodemapping = {


}


class Parser:
    def __init__(self,decoder):
        self.defines = ["ACT"]
        self.ids=["22C","72C","1AC","2AC"]
        self.decoder=decoder
        self.dm = decodemapping

    def ChargeBAttery(self):
        pass
        outputVoltage = self.decoders["acuity"].VBatt
        runActuityMethod = self.decoders["acuity"].actuitymethod1()
        print(outputVoltage)

    def parse(self,IdString,DataString):
        if IdString == "72C":
            toRet = "HearthBeat ACT "

        elif IdString == "22C":  # bytes 0&1 :tbd     bytes2,3,4,5:measured voltage       bytes 6&7:current
            Volts= getBytes(DataString, 2, 32)
            toRet  = "ACT msg<br>" \
                     "[0:1] {} -----------> Charger Status: {} <br>".format(DataString[0:6],DataString[0:6])
            toRet += "[2,3,4,5] {} -> Output Voltage: {:2.1f} Volts   <br>".format(DataString[6:18], Volts/ 1024)
            toRet += "[6,7] {} -----------> Output Current: {:3.1f} Amps".format(DataString[18:24],getBytes(DataString, 6, 16) / 16)

        elif IdString == "1AC":
            #VoltLimit
            Volts = int(getBytes(DataString, 2, 32))
            Current = getBytes(DataString, 6, 16)
            toRet = "ACT ctrl msg<br>" \
                    "[0-1] {} -------> ??? <br>" \
                    "[2-5] {} -> MeasuredVolts: {:2.1f} Volts - {:2.1f}V *** /1000 or /1024<br>" \
                    "[6-7] {} -------> Max_Current :  {} Amps".format( DataString[0:6],DataString[6:17],Volts/1000, Volts/1024, DataString[18:26],Current/10)


        elif IdString == "2AC":
            ChargeStatus = getBytes(DataString, 0, 8)
            SOC = getBytes(DataString, 1, 8)
            TemperatureH = getBytes(DataString, 2, 8)
            TemperatureL = getBytes(DataString, 3, 8)
            Voltage     = getBytes(DataString,4,32)
            toRet  = "ACT ctrl msg<br>" \
                     "[ 0 ] {} ----------> Charge_Mode: {}<br>".format(DataString[0:2],ChargeStatus)
            toRet += "[ 1 ] {} ----------> Battery_SOC: {}% <br>".format(DataString[3:5],SOC)
            toRet += "[4-7] {} -> Max_Voltage: {:2.1f}V - {:2.1f}V *** /1000 or /1024".format(DataString[12:24],float(Voltage/1000),float(Voltage/1024))
            #print("Voltage: {}".format(float(Voltage/1000)))return toRet

        return toRet


class testc():
    def __init__(self):
        self.a=0


class testd:
    def __init__(self):
        self.a=0

