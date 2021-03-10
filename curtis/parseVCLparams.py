Vars={}
thisparam=""
with open("TLD_Generic_E_Canada_PARs.vcl") as infile:
    line = infile.readline()

    while line:
        line = infile.readline()
        if line.find("PARAMETER_ENTRY")>-1:
            thisparam=line.split("\"")[1]

        if thisparam != "":
            if line.find("ADDRESS")>-1:
                #Vars[thisparam]=line.split("ADDRESS")[1].strip()
                Vars[line.split("ADDRESS")[1].strip().upper()]=thisparam
                thisparam=""

for item in Vars:
    pass
    print(item,Vars[item])

keylist=Vars.keys()
outfile=""
with open("curtis_info.txt") as infile:

    line = infile.readline()
    while line:





        if len(line.split(" "))>1:
            sw = line.split(" ")[2]
            #print("sw:",sw)
            if sw.startswith("p_user") or sw.startswith("user"):
                #print("sw",sw.upper(),len(sw))
                if sw.upper().strip() in keylist:
                    print("is IN:",line)
                    line= line[:10]+" "+Vars[sw.upper().strip()]+" "+sw
        outfile+=line
        line = infile.readline()

print(outfile)
with open("out_curtis_info.txt","w") as outfiletxt:
    outfiletxt.write(outfile)