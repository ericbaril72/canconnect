import json
from frozendict import frozendict

blocks={
    "Bridge":{},
    "Elevator":{},


    "Traction":{},"Pump":{},"Chassis":{},"Lamps":{},"Battery":{}
}
with open("838_929_signalsTOpins - Sheet1.csv") as infile:
    line=infile.readline()
    while line:
        id,iotype,sensor,signal,io_config,tags = line.strip().split(",")

        tags = tags.split(".")
        maintype = tags[0]
        if maintype=="cargo":
            maintype="Elevator"
            tags.append("cargo")
        if len(maintype)>0:
            maintype=maintype[0].upper()+maintype[1:]
            if maintype=="cargo":
                maintype="Elevator"
            if maintype=="Bridge":
                print(id,iotype,sensor,signal,io_config,tags)
            if not maintype in blocks.keys():
                blocks[maintype]={}
            if blocks[maintype]=={}:
                blocks[maintype]={
                            "Inputs": {
                                "G_InputsA":   {},
                                "G_InputsD":   {}
                            },
                            "fcts": [],
                            "Outputs": {
                                "G_OutputsA": {},
                                "G_OutputsD": {}
                            }
                }
            if iotype.find("InputsA")>=0:
                blocks[maintype]["Inputs"]["G_InputsA"][signal]=sensor+","+io_config
            elif iotype.find("InputsD")>=0:
                blocks[maintype]["Inputs"]["G_InputsD"][signal]=sensor+","+io_config
            elif iotype.find("OutputsA")>=0:
                blocks[maintype]["Outputs"]["G_OutputsA"][signal]=io_config+","+sensor
            elif iotype.find("OutputsD")>=0:
                blocks[maintype]["Outputs"]["G_OutputsD"][signal]=io_config+","+sensor

            if len(tags)>1:
                thisfctlist= blocks[maintype]["fcts"]
                if not tags[1] in thisfctlist:


                    thisfctlist.append(tags[1])
                    blocks[maintype]["fcts"]=thisfctlist
        line=infile.readline()


print(blocks.keys())
with open("blocks2.json","w") as outfile:
    outfile.write(json.dumps(blocks))
values={
    "Traction": {
                    "Inputs": {
                        "Inputs":   {"Elevator UP":True,"RPM>100":True,"Badge Accepted":True,"Stab DOWN":False},
                        'LimitsSwitch': {"At Frame":True,"at Max":True},
                        'G_Variables' : {"RPM min demand":1200},
                        "Parameters":{"OPT_has Elevator":True,"has limits":True}
                    },
                    "fcts": ["FWD","REV","Brake","Stab_UP","Stab_Down"],
                    "Outputs": {
                        'Outs':{"RPM":"1200","Cylinder-UP":True,"Redundant":True},
                        'Global':{"vclRPM":1200},
                    }
                },
    "Elevator": {
                    "Inputs": {
                        "Inputs":   {"Elevator UP":True,"RPM>100":True,"Badge Accepted":True,"Stab DOWN":False},
                        'LimitsSwitch': {"At Frame":True,"at Max":True,'Straddle Interlock':True},
                        'G_Variables' : {"CInRearElevManifoldPressure":1200,"CInRearElevTransferPressure":4000},
                        "Parameters":{"OPT_has Elevator":True,"has limits":True}
                    },
                    "fcts": ["Elev_Up","Elev_Down",'Elev_Rear_Transfer_FWD','Elev_Rear_Transfer_REV','Elev_Front_Transfer_FWD','Elev_Front_Transfer_REV','Rotagte-Left'],
                    "Outputs": {
                        'Outs':{"RPM":"1200","Cylinder-UP":False,"Redundant":False,"CInLeftSideGuideDownSensor":True},
                        'Global':{"vclRPM":1200},
                    }
                },
    "Bridge": {
                    "Inputs": {
                        "Inputs":   {"Bridge UP":True,"RPM>100":True,"Badge Accepted":True,"Stab DOWN":False},
                        'LimitsSwitch': {"At Frame":True,"at Max":True},
                        'G_Variables' : {"RPM min demand":1200},
                        "Parameters":{"OPT_has Elevator":True,"has limits":True}
                    },"fcts": ["Bridge_Up","Bridge_Down",'Bridge_Transfer_FWD','Bridge_Transfer_REV'],
                    "Outputs": {
                        'Outs':{"RPM":"1200","Cylinder-UP":False,"Redundant":False},
                        'Global':{"vclRPM":1200},
                    }
                },
    "PUMP/REGEN": {
                    "Inputs": {
                        "Inputs":   {"RPM>100":True,"Badge Accepted":False,"PSI in":1200},
                        'LimitsSwitch': {"Oil Cold":True,"Oil Full":True},
                        'G_Variables' : {"SOC > 20% ":True},
                        "Parameters":{"OPT_has Pump":True}
                    },"fcts": ["Pump","Regen"],
                    "Outputs": {
                        'Outs':{"PSI out":"1200"},
                        'Global':{"vclRPM":1200},
                    }
                }
}