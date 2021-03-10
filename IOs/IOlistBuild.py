import json
iolist={}

with open("IOlist") as infile:
    line=infile.readline()
    keylist=line.split('\t')
    print(len(keylist),keylist)

    line=infile.readline()
    while line:
        thisio={}
        datain= line.strip("\r\n").split('\t')
        #print(len(datain),datain)
        cnt=0
        for key in keylist:
            thisio[key]=datain[cnt]

            #print("{:20}   {}".format(key,datain[cnt]))
            cnt+=1
        iolist[datain[0]]=thisio

        line=infile.readline()

for io in iolist:
    pass
    #print("{:5}:{:10}:{:40}:{}".format(io,iolist[io]["Signal NAme"],iolist[io]["Details"],iolist[io]["Group"]))

def showInput():
    for io in iolist:
        if iolist[io]["INOUT"]=="INPUT" and iolist[io]["Signal NAme"]!="":
            print("INPUT:  {:5}:{:10}:{:40}:{}".format(io,iolist[io]["Signal NAme"],iolist[io]["Details"],iolist[io]["Group"]))
def showOutput():
    for io in iolist:
        if iolist[io]["INOUT"]=="OUTPUT" and iolist[io]["Signal NAme"]!="":
            print("OUTPUT: {:5}:{:10}:{:40}:{}".format(io,iolist[io]["Signal NAme"],iolist[io]["Details"],iolist[io]["Group"]))

#showInput()
#showOutput()

def getTags():
    taglist=[]
    for io in iolist:
        if not iolist[io]["Group"] in taglist:
            taglist.append(iolist[io]["Group"])
    print(taglist)

def showTag(tags):
    for io in iolist:
        if iolist[io]["Signal NAme"]!="":
            GroupInfo=iolist[io]["Group"]
            if tags in GroupInfo:
                print("{}:{}: {:5}:{:10}:{:40}:{}".format(iolist[io]["INOUT"],iolist[io]["Module"],io,iolist[io]["Signal NAme"],iolist[io]["Details"],iolist[io]["Group"]))

getTags()
showTag("Pump")
with open("io_map_list.json","w") as outfile:
    outfile.write(json.dumps(iolist))