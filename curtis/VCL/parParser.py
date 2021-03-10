import canopen

network = canopen.Network()
network.connect(bustype='pcan', channel='PCAN_USBBUS1', bitrate=250000)
node = network.add_node(0x26, '../1239245_0.eds')
network.add_node(node)


par_zone=False
par_obj={}

empty_one={'entry':None,'level': None}
new_topname=[]
currentLevel=0
default_val=""
addr=""
bitselect=""
paramslist=""

with open("TLD_Generic_E_Canada_PARs.vcl") as infile:
    line=infile.readline()
    while line:
        if line.startswith(";PARAMETERS:"):
            par_zone=True
            line=infile.readline()
        if par_zone:
            if line.find('PARAMETER_ENTRY')>=0:
                #print("param entry:",line)
                params_list={'name':line.split('"')[1]}
            elif line.find('LEVEL')>=0:
                params_list['level']=line.split('LEVEL')[1].strip()
                currentLevel=int(line.split('LEVEL')[1].strip())
            elif line.find('DEFAULT')>=0:
                default_val = line.split("DEFAULT")[1].strip()
            elif line.find('ADDRESS')>=0:
                addr = line.split("ADDRESS")[1].strip()
            elif line.find('BITSELECT')>=0:
                bitselect = line.split("BITSELECT")[1].strip()
            elif line.find('END')>=0:
                if 'level' in params_list.keys():
                    pass
                    #new_topname.append()
                    strspc=currentLevel*'  '
                    strspc+=str(currentLevel)+'- '
                    print('{:50} '.format(strspc+params_list['name']))
                else:
                    pass
                    strspc=currentLevel*'  '+'  - '
                    if addr.find("Bit")<0:
                        displaystr='{:50} {:10} {}'.format(strspc+params_list['name'],default_val,addr)

                    else:
                        displaystr='{:50} {:10} {}.{}'.format(strspc+params_list['name'],default_val,addr,bitselect)
                    try:
                            idx=print(node.object_dictionary[params_list['name']])
                    except:
                            idx="***"
                            #"print(Exception,params_list['name'])

                    print(displaystr,'--',idx)
                    paramslist+=displaystr+"\n"

            else:
                if line.find(';')>=0 and line.find('#################')<0 and line.find(';---')<0:
                    val=line.split(';')[1].strip().split('\t')
                    #print('key:',val[0],'++',val[-1])
                    params_list[val[0]]=val


        line=infile.readline()

print("***")
print(paramslist)
with open("paramslist.txt","w") as outfile:
    outfile.write(paramslist)