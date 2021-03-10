import time


traceFile = open("838regenCAN3acuity.trc")
outFileAcuityOnly = open("838regenCAN3acuity_AcuityOnly.trc","w")
outFileDrivesOnly = open("838regenCAN3acuity_DrivesOnly.trc","w")
outFilePLCOnly = open("838regenCAN3acuity_PLCOnly.trc","w")

wline=traceFile.readline()
line=wline.split()
print("Line:",line[0])
while line[0][0]==";":
    wline = traceFile.readline()
    line = wline.split()


print(line)
print("Start")
starttime=time.time()
idlist = []
cnt=0
while line:
    print(line[3][-1])
    if line[3][-1] in ["B","C","D"]:
        outFileDrivesOnly.write(wline)
    elif line[3][-1]=="A":
        outFileAcuityOnly
    else:
        outFilePLCOnly.write(wline)
    if line[3] not in idlist:
        idlist.append(line[3])
    wline=traceFile.readline()
    line=wline.split()
print(idlist)
outFileAcuityOnly.close()
outFileDrivesOnly.close()
outFilePLCOnly.close()