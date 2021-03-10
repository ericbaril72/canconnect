from TLDcan.decode import getBytes as getBytes

class Parser:
    def __init__(self):
        self.defines = ["Acuity"]
        self.ids=["72A","1AA","2AA","4AA"]
        self.emitids={"1AB":{"cycle":100,"vars":["battVolt","Current"]}}
        self.VBatt = 33.3

    def actuitymethod1(self):
        return 0

    def parseobj(self,IdString,DataString):
        if IdString=="72A":
            try:
                toRet={"Acuity HearthBeat":1}
            except Exception as e:
                toRet={"Acuity HearthBeat":str(e)}

        elif IdString=="1AA":
            BattVolt = getBytes(DataString, 0, 16) / 100
            V_measured = BattVolt
            Current = (getBytes(DataString, 2, 16)-65536) / 10
            Temperature = getBytes(DataString, 4, 16) / 100
            SOC = getBytes(DataString, 7, 8)


            toRet = "[0-1] {:3.3f}Volts<br>".format(BattVolt)
            toRet +="[2-3] I:{}Amps<br>".format(Current)
            toRet +="[4-5]T:{}C<br>".format(Temperature)
            toRet +="[7] SOC:{}%\n{:<80s}{:1.2f}V/cell   ".format(SOC, " ", BattVolt / 40)
            toRet = {"BattVolt"     : V_measured,
                      "Current"     : Current,
                      "Temperature" : Temperature,
                      "SOC"         : SOC
                      }

        elif IdString=="4AA":
            ss=getBytes(DataString, 0, 8)
            mm=getBytes(DataString, 1, 8)
            hh=getBytes(DataString, 2, 8)
            Tstr="{}:{}:{}".format(hh,mm,ss)
            return {"Real-Time-Clock ":Tstr}
        elif IdString=="2AA":
            return {"Acuity BAttery Stats":0}
        else:
            toRet={"?":0}
        return toRet

    def parse(self,IdString,DataString):
        if IdString=="72A":
            try:
                toRet="Acuity HearthBeat:"
            except Exception as e:
                toRet="Acuity HearthBeat "+str(e)

        elif IdString=="1AA":
            BattVolt = getBytes(DataString, 0, 16) / 100
            V_measured = BattVolt
            Current = (getBytes(DataString, 2, 16)-65536) / 10
            Temperature = getBytes(DataString, 4, 16) / 100
            SOC = getBytes(DataString, 7, 8)


            toRet = "[0-1] {:3.3f}Volts<br>".format(BattVolt)
            toRet +="[2-3] I:{}Amps<br>".format(Current)
            toRet +="[4-5]T:{}C<br>".format(Temperature)
            toRet +="[7] SOC:{}%\n{:<80s}{:1.2f}V/cell   ".format(SOC, " ", BattVolt / 40)
            return toRet

        elif IdString=="4AA":
            ss=getBytes(DataString, 0, 8)
            mm=getBytes(DataString, 1, 8)
            hh=getBytes(DataString, 2, 8)
            Tstr="{}:{}:{}".format(hh,mm,ss)
            return "Real-Time-Clock "+Tstr
        elif IdString=="2AA":
            return "Acuity BAttery Stats"
        else:
            toRet="?"
        return toRet

