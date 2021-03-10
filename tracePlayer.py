from PCANBasic.PCANBasic import *
import time
import ctypes,math,sys
print(sys.version)
PeakUSB = PCANBasic()
pcanhandle = PCAN_USBBUS1
PeakUSB.Initialize(pcanhandle, PCAN_BAUD_250K, PCAN_TYPE_ISA, 0x100, 3)
#PeakUSB.init()

msgObj={}
traceObj={}
error=0
def getMessages(msgObj):
    stsResult = [PCAN_ERROR_OK]
    while not (stsResult[0] & PCAN_ERROR_QRCVEMPTY):
        stsResult = PeakUSB.Read(pcanhandle)
        if stsResult[0] == PCAN_ERROR_OK:

            dataString = ""
            for i in range(0, stsResult[1].LEN):
                dataString += "{:02X} ".format(stsResult[1].DATA[i])
            msgObj[stsResult[1].ID] = [time.time(), stsResult[1].ID, dataString, ""]
    return stsResult[0]

def sendMessage(CanMsg,cnt):
    global error
    try:
        result = bytes([int(x, 16) for x in CanMsg[5:]])
    except:
        print("result except:",result)
    result = result + bytes([0,0,0,0,0,0,0,0])
    try:
        result2 = (ctypes.c_ubyte * 8).from_buffer_copy(result)
    except Exception as e:
        print(e)
        print(result)
    #print(CanMsg[5:],result)
    tpcan = TPCANMsg()
    tpcan.ID=int(CanMsg[3],16)
    tpcan.MSGTYPE = 0
    tpcan.LEN = int(CanMsg[4])
    thistime=time.time()
    if tpcan.ID not in traceObj.keys():
        traceObj[tpcan.ID]={'lasttime':thistime,'cycle':0,'cnt':0}
    traceObj[tpcan.ID]['cnt']+=1
    deltatime= thistime-traceObj[tpcan.ID]['lasttime']
    if deltatime==0:
        pass
    else:

        if traceObj[tpcan.ID]['cycle']!= 0:
            if abs(deltatime-traceObj[tpcan.ID]['cycle'])> traceObj[tpcan.ID]['cycle']/2:
                if tpcan.ID not in [0,2,4,8]:
                    print("{}  skip {}    ID:{} {}       delta:{}      {}".format(cnt,thistime,tpcan.ID,hex(tpcan.ID),deltatime*1000,[int(x, 16) for x in CanMsg[5:]]))

            else:
                if abs(deltatime - traceObj[tpcan.ID]['cycle']) < traceObj[tpcan.ID]['cycle'] / 2:
                    traceObj[tpcan.ID]['cycle']=deltatime

        else:
            traceObj[tpcan.ID]['cycle']=deltatime

    traceObj[tpcan.ID]['lasttime']=thistime




    """
    [("ID", c_uint),  # 11/29-bit message identifier
     ("MSGTYPE", TPCANMessageType),  # Type of the message
     ("LEN", c_ubyte),  # Data Length Code of the message (0..8)
     ("DATA", c_ubyte * 8)]"""
    if hex(tpcan.ID).endswith("227"):
        return
    if hex(tpcan.ID).upper().endswith("A6"):
        # print(hex(tpcan.ID))
        return

    if hex(tpcan.ID).upper().endswith("C"):
        print(hex(tpcan.ID))
        #return

    try:
        tpcan.DATA = result2
        rez=PeakUSB.Write(pcanhandle, tpcan)
        if rez != PCAN_ERROR_OK:
            error +=1
            print("tx error:",hex(rez))
        else:
            print("ok")

    except Exception as e:
        print(e)
        print("tpcan.len",tpcan.LEN)
        print("Data len",len(CanMsg[5:]))

#traceFile = open("cantraces/UPSregen_rpt2.trc")
#traceFile = open("cantraces/UPSregen_rpt1.trc")
traceFile = open("cantraces/UPSregen_CAN1_125k.trc")
#traceFile = open("cantraces/UPSregen_CAN2_J1939.trc")
traceFile = open("cantraces/AcuityStandbytrace.trc")#traceFile = open("cantraces/838regenCAN3acuity_DrivesOnly.trc")
#traceFile = open("cantraces/NBL-e_greencubecurrent.trc")
traceFile=open("cantraces/838regenCAN3acuity.trc")


print("Trace file source:",traceFile.name)

cnt=0
while 1:
    traceFile.seek(0)
    line = traceFile.readline()


    while line[0]==";" :
        line = traceFile.readline()

    line=line.split()
    nextmsg = int(line[1].split(".")[0])
    starttime=time.time()
    while line or cnt<500:
        thistime = time.time()
        cnt+=1
        timeoffset = (1000*(thistime-starttime))
        if timeoffset>=nextmsg:
                sendMessage(line,cnt)
                if error>0 and error%2==0:
                    print("Error:",error,nextmsg,line)
                #print(timeoffset,nextmsg,line)
                line = traceFile.readline().split()

                # getMessages(msgObj)
                if line:
                    if not line[2].startswith("Error"):
                        try:
                            nextmsg = float(line[1])
                        except:
                            print("exception:",line)
        else:
            pass
            time.sleep(.0001)
        if cnt%500==0:
            print(cnt)
    print("Sent")
    time.sleep(1)

for item in sorted(traceObj.keys()):
    print("0x{:03X}\t{}".format(item,int(traceObj[item]['cycle']*1000),10*round(traceObj[item]['cnt']/10)))
#print(traceObj)