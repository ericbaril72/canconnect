import canopen

network = canopen.Network()
network.connect(bustype='pcan', channel='PCAN_USBBUS1', bitrate=250000)
node = network.add_node(0x26, '1239245_0.eds')
network.add_node(node)
for node_id in network:
    print(network[node_id])
objname=[]
for obj in node.object_dictionary.values():
    #print(obj.name)
    objname.append(obj.name.upper())

with open("./VCL/paramslist.txt") as infile:
    line=infile.readline()
    while line:
        addr=line.strip().split(" ")[-1]
        if addr.upper() in objname:
            print(addr,addr.upper() in objname,line.strip())
        else:
            print(addr)
        line=infile.readline()
exit()

exit()
for obj in node.object_dictionary.values():
    if obj.index>0x3330  or (1 and obj.index<0x3028):

        if not isinstance(obj, canopen.objectdictionary.Record):
            val=hex(node.sdo[obj.index].raw)
            type=node.object_dictionary[obj.index].data_type
            print('{:8}: {:40} -->{:10}    {}'.format(hex(obj.index), obj.name,val,type))
        else:
            print('{:8}: {:40} '.format(hex(obj.index), obj.name))
            for subobj in obj.values():
                try:
                    val=hex(node.sdo[obj.index][subobj.subindex].raw) #subobj) #subobj.raw)
                    #type=node.object_dictionary[obj.index][subobj].data_type
                    #print("---",subobj.subindex,val)
                    type=0
                    print('{:8}: {:40} -->{:10}    {}'.format(subobj.subindex, subobj.name,val,0))
                except:
                    print('{:8}: {:40} ***'.format(subobj.subindex, subobj.name))