import json
iolist=[]
with open("io_map_list.json") as infile:
    iolist=json.load(infile)

outsignals={}
insignals={}
with open("inout links.json") as infile:
    outsignals=json.load(infile)

    for outsignal in outsignals.keys():
        insignals_per_out=outsignals[outsignal]
        for insignal in insignals_per_out:
            if insignal not in insignals.keys():
                insignals[insignal]=[]
            if not outsignal  in insignals[insignal]:
                insignals[insignal].append(outsignal)

    print(len(insignals))

if 1:
        with open("outin_list.json","w") as outfile:
            outfile.write(json.dumps(insignals))

def unknown():
    print(insignals.keys())
    print(len(outsignals))
    print(insignals.keys())
    for insignal in insignals.keys():
        print(insignal)
    maplist=[
        "CInElevatorNearFrame",206,
        "CInElevatorBelow60in",208,
        "CInInterfaceStraddleRight",160,
        "CInElevatorNearBridgeRight",153,
        "CInElevatorAtBridgeRight",154,
        "CInElevatorAtBridgeLeft",139,
        "CInInterfaceStraddleLeft",143,
        "CInElevatorNearBridgeLeft",144,
        "CInElevRearRotateJCW",117,
        "CInElevRearRotateJCCW",117,
        "CInManLiftUp",30,
        "CInBridgeSWDown",120,
        "CInBridgeRedundant",22,
        "CInDayLights",22,
        "CInManLiftRedundant",29,
        "CInChargerDoor",26,
        "CInHydLowOilLevel",20,
        "CInStairwayOverride",109,
        "CInIgnKeyStart",17,
        "CInManLiftActive",107,
        "CInChassisRearHorn",31,
        "CInDriveSpeed",35,
        "CInBridgeSafetySensor",18,
        "CInChassisRearUp",118,
        "CInChassisRearDown",118,
        "CInCargoHornButton",108,
        "CInBridgeAtFrame",83,
        "CInASDButton",104,
        "CInStabsDownSensor",82,
        "CInDriveFwd",52,
        "CInDriveRev",52,
        "CInAllGuidesDownEnable",77,
        "CInBrakePedalPressed",53,
        "CInAcceleratorPedal",54,
        "CInElevatorAtFrame",84,
        "CInLeftSideGuideUp",185,
        "CInLeftSideGuideDownSensor",188,
        "CInRightSideGuideUp",190,
        "CInRightSideGuideDownSensor",190,
    ]

    def showInput():
        cnt=0
        for io in iolist:
            if int(io) in maplist:
                print("in list:",io,maplist)
                maplist.find(int(io))
                cnt+=1
            else:
                print("not in list:",io)
            if iolist[io]["INOUT"]=="INPUT" and iolist[io]["Signal NAme"]!="":
                pass
                #print("INPUT:  {:5}:{:15}:{:40}:{}".format(io,iolist[io]["Signal NAme"],iolist[io]["Details"],iolist[io]["Group"]))
        print(cnt)

    showInput()

    if 0:
        with open("io_map_list.json","w") as outfile:
            outfile.write(json.dumps(iolist))