import os
"""
NMT message
01h Enter the Operational state
02h Enter the Stopped stateXx
80h Enter the Pre-Operational stateXx
81h Reset Acuity (warm boot)Xx
82h Reset the CANbusXx

HB value
00h Initialization (or “boot-up”)
04h StoppedXx
05h OperationalXx
7Fh Pre-OperationalXx
"""
files = os.listdir("c:\\users\\eric.baril\\documents\\.")
print(files)
for file in files:
    if file.endswith(".trc"):
        print(file)
        with open("c:\\users\\eric.baril\\documents\\"+file) as infile:
            line=infile.readline()
            while line:
                if line[0] ==";":
                    line=infile.readline()
                else:
                    print("break!")
                    break
            while line:
                data= line.split()

                if 1 and data[3]=="0000" and data[2]!="Error":
                    try:
                        if  data[6]=="00" or data[6]=="2A":
                            print(line.replace("\r\n",""))
                    except:
                        print("except:",infile.name)
                        print("       ", line)
                if 0 and data[3].startswith("008") and data[4]!="0" and data[3][3]not in ["B","C","D"]:
                    print(line.replace("\r\n", ""))
                line = infile.readline()


