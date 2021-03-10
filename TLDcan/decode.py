#-*-encoding:utf-8-*-

import glob
import time
from os.path import join,dirname,basename,isfile
import ctypes
import can
import canfox.canfox

#can.interfaces.BACKENDS["canfox"] = ('canfox.canfox',           'CanFoxBus')
#can.util.VALID_INTERFACES = frozenset(list(can.interfaces.BACKENDS.keys()))
can.rc= {}
avails = glob.glob(join(dirname(__file__), "*.py"))
availmodules = [ basename(f)[:-3] for f in avails if isfile(f) and not f.endswith('__init__.py')]

#availmodules.remove("CanID")
print("availmodules:",availmodules)
try:
    availmodules.remove("decode")
except:
    print("decode.py not in avail list")



parseData = { "NodeID" : 0,
                                "Type"   : ""}
# https://stackoverflow.com/questions/8718885/import-module-from-string-variable

def loadModule(moduleName):
    module = None
    try:
        import sys
        del sys.modules[moduleName]
    except BaseException as err:
        pass
    try:
        import importlib
        module = importlib.import_module(moduleName)
    except BaseException as err:
        serr = str(err)
        print("Error to load the module '" + moduleName + "': " + serr)
    return module


def reloadModule(moduleName):

    module = loadModule(moduleName)

    moduleName, modulePath = str(module).replace("' from '", "||").replace("<module '", '').replace("'>", '').split("||")
    if 0 and (modulePath.endswith(".pyc")):
        import os
        os.remove(modulePath)
        module = loadModule(moduleName)
    return module
def getInstance(moduleName, param1, param2, param3):
    #module = reloadModule(moduleName)
    #instance = eval("module." + moduleName + "(param1, param2, param3)")
    module = reloadModule(moduleName)
    #print("reloaded...")
    instance = eval("module.Parser")# + moduleName + "(param1, param2, param3)")
    return instance

#And everytime I want to reload a new instance I just have to call getInstance() like this:
#myInstance = getInstance("MyModule", myParam1, myParam2, myParam3)
#Finally I can call all the functions inside the new Instance:
#myInstance.aFunction()

"""
import FileSystemWatcher
fsw = FileSystemWatcher(pathtocheck.decode('utf-8'))
fsw.NotifyFilter = FileSystemWatcher.NotifyFilters.FileName
fsw.Created += your_callback
fsw.EnableRaisingEvents = True


try:
    from old import CanID

except Exception as e:
    print("Could not load CanID")
    print(e)
    exit()
"""
parser = None


def checkReload():

    global parser
    version = "0" #CanID.__version__
    try:
        pass
        #importlib.reload(CanID)
        #parser = CanID.TLDcan()
        #version = CanID.__version__
    except Exception as e:
        print('exception:',e)


    return version
def getBytes(dataString, pos, length):
    pos1 = pos * 3
    pos2 = pos1 + 3
    pos3 = pos1 + 6
    pos4 = pos1 + 9
    pos5 = pos1 + 12
    if length == 8:
        return int(dataString[pos1:pos2], 16)
    elif length == 16:
        return int(dataString[pos1:pos2], 16) + 256 * int(dataString[pos2:pos3], 16)
    elif length == 32:
        return          int(dataString[pos1:pos2], 16) + \
                (256 *  int(dataString[pos2:pos3], 16)) + \
                (256 *  256 * int(dataString[pos3:pos4], 16)) + \
                (256 *  256 * 256 * int(dataString[pos4:pos5], 16))
    elif length == -32:
        sign = int(dataString[0:3], 16) & 0x80
        value = 256*256*256*(   int(dataString[0:3], 16) & 0x7F) + \
                256 * 256 * (   int(dataString[pos2:pos3], 16)) +\
                256 *       (   int(dataString[pos3:pos4], 16))+\
                            (   int(dataString[pos4:pos5], 16))
        if not sign:
            value = 0x7FFFFFFF - value
        return value
    return 0
def msgType(IdString):
        msgId = int(IdString,16)
        msg = msgId>>7
        if   msg == 0:
            type = "NMT "+IdString
        elif msgId == 0x80:
            type = "Sync"
        elif msg == 1:
            type = "Emergency "+IdString
        elif msg == 2:
            type="TimeStamp"
        elif msg == 3 or msg == 5 or msg == 7 or msg == 9:
            type="TX PDO " + str(msgId>>8)
        elif msg == 4 or msg == 6 or msg == 8 or msg == 10:
            type="RX PDO " + str((msgId>>8 )-1)
        elif msg==5:
            type="2"
        elif msg==11:
            type="SDO ans"
        elif msg==12:
            type="SDO req"
        elif msg==14:
            type="HB"
        else:
            type="inconu"
        return type
def returnDevName(IdString):
    name = "unknown"
    for item in parsingList:
        if IdString.upper() in item:
            name=item[0]
    if name=="unknown":
        name = "CobID: 0x{:02X}".format((int(IdString,16) & 0x7F))
    return name
def asString(id,data):
    # older Approach using String based data

    if id.upper().startswith("0X"):
        id=id[2:]
    rez=parser.decode(id,data)
    if parseData["NodeID"] == 4:
                toRet = "CR0403<br>"
    elif parseData["NodeID"] == 16:
        toRet = "CR2032 BRIDGE 1<br>"
    elif parseData["NodeID"] == 17:
        toRet = "CR2032 BRIDGE 2<br>"
    elif parseData["NodeID"] == 20:
        toRet = "CR2032 Elevator 1<br>"
    elif parseData["NodeID"] == 21:
        toRet = "CR2032 Elevator 2<br>"
    elif parseData["NodeID"] == 24:
        toRet = "CR2032 Elevator 3<br>"
    elif parseData["NodeID"] == 80:
        toRet = "Joystick Drive<br>"
    elif parseData["NodeID"] == 81:
        toRet = "Joystick Elevator Lift<br>"
    elif parseData["NodeID"] == 85:
        toRet = "Joystick Bridge Lift<br>"
    elif parseData["NodeID"] == 72:
        toRet = "REAR ELEVATOR CARGO Joystick<br>"
    elif parseData["NodeID"] == 74:
        toRet = "Bridge Cargo Joystick<br>"
    elif parseData["NodeID"] == 76:
        toRet = "FRONT ELEVATOR CARGO Joystick<br>"
    elif parseData["NodeID"] == 96:
        toRet = "CARGO CONSOLE SWITCH MODULE SM-1<br>"
    elif parseData["NodeID"] == 94:
        toRet = "CARGO CONSOLE SWITCH MODULE SM-2<br>"
    elif parseData["NodeID"] == 91:
        toRet = "CR2016 Console Slave Module<br>"
    elif parseData["NodeID"] == 39:
        toRet = "CR1076 ASD Display<br>"
    elif parseData["NodeID"] == 19:
        toRet = "Orbitrol<br>"
    return rez

def asObj(IdString,DataString):
    # newer approach using JSON obj
    if IdString.upper().startswith("0X"):
        IdString=IdString[2:]
    Obj= { "NodeID" : (int(IdString,16) & 0x7F),
                "Type"   : msgType(IdString),
               "DevName" : returnDevName(IdString),
               "NBL"    : False,
               "Loader" : False,
               "Info"   : "New"}

    return Obj

class BusInfo():
    def __init__(self,msgArray):
        self.msgArray = msgArray
        self.devicesCache =[]
    def getDevices(self):
        data = self.msgArray.get()
        devices =[]
        newdevices={}
        #print("data",data)
        for elem in data:
            #devices.append(elem,[elem["name"]
            try:
                newdevices[int(elem,16)&0x7F]=data[elem]['decodeObj']["DevName"]
            except:
                pass

        for elem in devices:
            if not elem in self.devicesCache:
                pass
                #self.devicesCache.append((elem,self.msgArray[elem]["name"]))
                #newdevices.append((elem,self.msgArray[elem]["name"]))

        return newdevices

def processBus2(msgArray):
    msgArray.recv(0.001)

def txBus2(msgArray):
    msgArray.txmit()

class BusInterface():
    def __init__(self,interface=""):
        if interface!="":
            pass
            can.interfaces.BACKENDS["canfox"] = ('canfox.canfox',           'CanFoxBus')
            can.util.VALID_INTERFACES = frozenset(list(can.interfaces.BACKENDS.keys()))
        can.rc= {}
        can.rc = interface
        self.interface = interface
        try:
            pass
            #self.bus = can.Bus()
        except Exception as e:
            print('*******')
            print(e)
            print(interface)
            exit()

        self.socketio_refresh_timeout = time.time()
        self.ut =           self.socketio_refresh_timeout
        self.slowupdate=    self.socketio_refresh_timeout
        self.msgArray       = MessagesArray(self.interface)

        self.socketIO_refresh_period = 0.4
        self.bInfo =  BusInfo(self)

    def process(self):
        self.msgArray.recv(0.001)
        if time.time() > self.slowupdate:
            self.slowupdate = time.time() + 3
            mainArray =  self.msgArray.getDevices()
            #print(mainArray)
            return ({'interface': self.interface, 'type':'slow','dataArray': mainArray })

        if time.time()> self.socketio_refresh_timeout:
            self.socketio_refresh_timeout = time.time() + self.socketIO_refresh_period
            unsent = self.msgArray.getUnsent()

            if len(unsent):
                return ({'interface': self.interface, 'type':'fast', 'dataArray': unsent })

        return {'type':'None'}


class MessagesArray():
    def __init__(self,interface):
        self.msgArray = {}
        self.count = 0
        self.startTime = time.time()
        self.version = ""
        #can.interfaces.BACKENDS["canfox"] = ('canfox.canfox',           'CanFoxBus')
        #can.util.VALID_INTERFACES = frozenset(list(can.interfaces.BACKENDS.keys()))
        #can.rc= {}
        #can.rc = interface
        #can.rc={'interface':'pcan','channel':'PCAN_USBBUS1','bitrate':250000}
        self.bus = can.Bus()
        self.parsers={}
        #self.parsersFct={}
        self.parsersName={}
        self.devicesCache =[]
        self.decoders = {}


    def clear(self):
        self.msgArray = {}

    def recv(self,timeout):
        while True:
            msg = self.bus.recv(timeout=0.001)
            if msg:
                ID = hex(msg.arbitration_id)
                self.count +=1
                if ID in self.msgArray.keys():
                    lastTS = self.msgArray[ID]["times"]
                    cnt = self.msgArray[ID]["cnt"]
                    DevName = self.msgArray[ID]["DevName"]
                else:
                    lastTS = self.startTime
                    cnt=0
                    DevName = ""

                msgInfo = { "id"     : "{:03X}".format(msg.arbitration_id),
                               "data"   : ''.join('{:02X} '.format(x) for x in msg.data),
                               "len"    : msg.dlc,
                               "decode" : "",
                               "decodeObj" : {},
                               "ts"     : int((msg.timestamp - lastTS)/10),
                               "times"  : msg.timestamp,
                               "sent"   : False,
                               "cnt"    : cnt+1,
                            "DevName"   : DevName
                               }
                self.msgArray[ID] = msgInfo
            else:
                return None
        return self.msgArray

    def parseTX(self,msg):
        ID = hex(msg.arbitration_id)
        self.count +=1
        if ID in self.msgArray.keys():
            lastTS = self.msgArray[ID]["times"]
            cnt = self.msgArray[ID]["cnt"]
            DevName = self.msgArray[ID]["DevName"]
        else:
            lastTS = self.startTime
            cnt=0
            DevName = ""

        msgInfo = { "id"     : "{:03X}".format(msg.arbitration_id),
                       "data"   : ''.join('{:02X} '.format(x) for x in msg.data),
                       "len"    : msg.dlc,
                       "decode" : "",
                       "decodeObj" : {},
                       "ts"     : int((msg.timestamp - lastTS)/10),
                       "times"  : msg.timestamp,
                       "sent"   : False,
                       "cnt"    : cnt+1,
                    "DevName"   : DevName
                       }
        self.msgArray[ID] = msgInfo

    def txmit(self):
        msg= can.message.Message()
        maxCurrent=200
        readVoltage=0
        maxVoltage=94
        SOC=32


        if msg or "0x1aa" in self.msgArray.keys():
                self.decoders["act"].ChargeBAttery()

                msg.dlc = 8
                data = self.msgArray["0x1aa"]["data"]

                BattVolt = getBytes(data[0:5], 0, 16) * 10
                #print("msg:",data,hex(BattVolt)

                source=["0","14","0","0","0","0","6","7"]
                source[2]=hex(BattVolt & 0xFF)
                source[3]=hex((BattVolt>>8) & 0xFF)

                # *****************************
                MaxCurrent = 200 * 10
                # *****************************

                source[6]=hex(MaxCurrent &0xFF)
                source[7]=hex(MaxCurrent>>8 &0xFF)
                result = bytes()

                try:
                    result = bytes([int(x, 16) for x in source])
                except Exception as e:
                    print("result except:",result,e)

                try:
                    msg.data = (ctypes.c_ubyte * 8).from_buffer_copy(result)
                except Exception as e:
                    print(e)
                    print(result)

                msg.arbitration_id = 0x1AC
                self.parseTX(msg)
                self.bus.send(msg)

                MaxVolt = 94 * 1000

                #SOC=getBytes(data[21:23], 0, 8)
                #print("SOC:",data,"--",data[21:],int(data[21:],16))
                SOC=int(data[21:],16)
                source=["0","0","0","0","0","0","0","0"]
                source[1]=hex(SOC)
                source[4]=hex(MaxVolt & 0xFF)
                source[5]=hex((MaxVolt>>8) & 0xFF)
                source[6]=hex((MaxVolt>>16) & 0xFF)
                try:
                    result = bytes([int(x, 16) for x in source])
                except Exception as e:
                    print("result except:",result,e)

                try:
                    msg.data = (ctypes.c_ubyte * 8).from_buffer_copy(result)
                except Exception as e:
                    print(e)
                    print(result)


                msg.arbitration_id = 0x2AC
                self.parseTX(msg)
                self.bus.send(msg)

    def get(self):
        return self.msgArray

    def getDevices(self):
        data = self.get()
        devices =[]
        newdevices={}
        #print("data",data)
        for elem in data:
            #devices.append(elem,[elem["name"]
            try:
                #print("data",data[elem]["DevName"])
                newdevices[int(elem,16)&0x7F]=data[elem]["DevName"]
            except:
                pass

        for elem in devices:
            if not elem in self.devicesCache:
                pass
                #self.devicesCache.append((elem,self.msgArray[elem]["name"]))
                #newdevices.append((elem,self.msgArray[elem]["name"]))

        return newdevices

    def getUnsent(self):
        unsent = {}
        try:
            self.version = checkReload()
            #self.version += "-"+parser.version
        except Exception as e:
            print("checkreload:",e)
            exit()
            return unsent
        for elem in availmodules:

            try:
                pass
                arr = getInstance("TLDcan."+elem,None,None,None)

                try:
                    obj= arr(self.decoders)
                except:
                    obj= arr()
                self.decoders[elem] =obj
                for elem in obj.ids:
                    self.parsers[elem]={}

                    self.parsers[elem]["fct"]=obj.parse
                    self.parsers[elem]["name"]=obj.defines
                    #

            except Exception as e:
                print("getinstance except:",e)
                #exit()

            try:
                self.parsers[elem]["fctobj"]=obj.parseobj
                #print("has parseobj:",elem)
            except:
                pass
                #print("No parseobj:",elem)
                #
                #self.parsers[elem]["fctobj"]={}
                #self.parsersFct[elem]=obj.parse
                #self.parsersName[elem]=obj.defines

        for elem in self.msgArray:
            if not self.msgArray[elem]["sent"]:
                self.msgArray[elem]["sent"] = True

                unsent[elem]=self.msgArray[elem]
                IdString = unsent[elem]["id"]
                DataString = unsent[elem]["data"]
                parseData = { "NodeID" : (int(IdString,16) & 0x7F),
                                "Type"   : msgType(IdString)}

                unsent[elem]["decodeObj"]   =asObj(IdString,DataString)
                try:
                    if IdString in self.parsers:
                        #ar = self.parsersFct[IdString]
                        #unsent[elem]["decodeObj"]["DevName"]=self.parsersName[IdString]
                        ar = self.parsers[IdString]["fct"]
                        unsent[elem]["decodeObj"]["DevName"]=self.parsers[IdString]["name"]
                        self.msgArray[elem]["DevName"]=unsent[elem]["decodeObj"]["DevName"]
                        #print("DevName:",self.msgArray[elem]["DevName"],elem)
                        data=ar(IdString,DataString)
                        unsent[elem]["decode"]      = data
                        if "fctobj" in self.parsers[IdString].keys():
                            print("has parse OBJ:",IdString)
                        #arObj = self.parsers[IdString]["fctobj"]
                        #unsent[elem]["decodeObj"]      = arObj(IdString,DataString)
                    else:
                        unsent[elem]["decode"]      = "unparsed" #asString(IdString,DataString)

                except Exception as e:
                    unsent[elem]["decode"]      = "in parsers array Exceptiondecode: "+IdString+"--"+str(e)+"<br>"  #+\
                    #str(len(self.parsersFct))+"="
                unsent[elem]["decodeObj"]["Info"]=unsent[elem]["decode"]



        return unsent

    def getParsers(self):
        return availmodules

ACTCharger=     ["ACT",             "22C","72C"]
AcuityIDs=      ["Acuity",          "1AA","2AA","4AA","72A"]
GreenCube=      ["GreenC_Loader",   "19C","29C","39C","71C"]
GreenCubeNBL=   ["GreenC_NBL",      "28C","38C","48C"]
ACTctrl  =      ["ACTctrl",         "1AC","2AC"]
IBS       =     ["IBS",             "2F0","2F1","2F2","2F3","326"]
TLDlink  =      ["TLDlink",         "1C427003","1C427103","1C427203","1C427303"]
PLC     =       ["PLC",             "703","0","80","83","303","203","403","503","603"]
DCDC =          ["DCDC",            "071D","9D","19D","21D","29D","31D"]
Pump    =       ["Pump",            "70B","8B","18B","28B","20B","30B"]
Traction   =    ["Traction",        "70C","8C","18C","28C","20C","30C"]
Regen    =      ["Regen",           "70D","8D","18D","28D","20D","30D"]
Diagnostic =    ["Diagnostic",      "110","120","121","122"]
NBLPLC =        ["NBL PLC",         "226"]
NBLDrive =      ["NBL Drive",       "1A6","2A6","3A6","4A6","227"]
NBLPUMP =       ["NBL Pump",        "2A8","1A8","3A8","4A8","1A7"]
CurrentSensor = ["CurrentSensor",   "3C2"]

parsingList = [
    ACTCharger,
    AcuityIDs,
    GreenCube,
    GreenCubeNBL,
    ACTctrl  ,
    IBS       ,
    TLDlink  ,
    PLC     ,
    DCDC ,
    Pump    ,
    Traction   ,
    Regen    ,
    Diagnostic ,
    NBLPLC ,
    NBLDrive ,
    NBLPUMP ,
    CurrentSensor
]
