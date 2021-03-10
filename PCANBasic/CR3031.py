#!/usr/bin/env python
import socket
import subprocess
import sys
from datetime import datetime
import time
# Clear the screen
#subprocess.call('clear', shell=True)

# Ask for input
remoteServer    = "CANwirelessSN1705005"
remoteServerIP  = "192.168.50.160" #socket.gethostbyname(remoteServer)
port=30000
# Print a nice banner with information on which host we are about to scan
print("-" * 60)
print("Please wait, scanning remote host", remoteServerIP)
print("-" * 60)

# Check what time the scan started
t1 = datetime.now()

# Using the range function to specify ports (here it will scans all ports between 1 and 1024)

# We also put in some error handling for catching errors

def crc(packet):
    checksum = 0
    for el in packet:
        checksum ^= ord(el)
    return checksum

def buildInstr(cmd,data):
    endString = str("C")+chr(len(cmd)+len(data))
    for i in range(0,len(cmd)):
        endString+=chr(cmd[i])
    if data:
        for i in range(0,len(data)):
            endString+=str(data[i])

    endString+=chr(crc(endString))+'\r'
    return bytes(endString,"utf-8")
import select

port=30000 #for port in range(30000,30002):
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.setblocking(0)
result = s.connect((remoteServerIP,port))
if result == 0:
    print("Port {}: 	 Open".format(port))
data=buildInstr([0x58],"")
print("len:",len(data))
print("data:",data)

s.setblocking(0)
buffer=''

s.sendall(data)
try:
    run_main_loop = True
    while run_main_loop:


        st=time.time()+0.1

        continue_recv = True

        while continue_recv:
            try:
                # Try to receive som data
                buffer += s.recv(1)
            except Exception as e:
                run_main_loop = False
                # If e.errno is errno.EWOULDBLOCK, then no more data
                if time.time()>st:
                    continue_recv = False

        # We now have all data we can in "buffer"
        print("rx:'{}'".format(buffer))

        #data=s.recv(16)
        cmds=[]
        for item in data:
            cmds.append(hex(item))
        print("Data:",data,"-",cmds)
        s.close()

except KeyboardInterrupt:
    print("You pressed Ctrl+C")
    sys.exit()

except socket.gaierror:
    print('Hostname could not be resolved. Exiting')
    sys.exit()

except socket.error:
    print("Couldn't connect to server")
    sys.exit()

except Exception as e:
    print("except:",e)
    sys.exit()
# Checking the time again
t2 = datetime.now()

# Calculates the difference of time, to see how long it took to run the script
total =  t2 - t1

# Printing the information to screen
print('Scanning Completed in: ', total)