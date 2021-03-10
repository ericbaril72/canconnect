import canopen
import logging
import time

logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)
logger = logging.getLogger(__name__)
import sys
import os
canInterface = {'interface':'pcan','channel':'PCAN_USBBUS1','bitrate':250000}

# Start with creating a network representing one CAN bus
network = canopen.Network()

# Connect to the CAN bus
network.connect(bustype='pcan', channel='PCAN_USBBUS1', bitrate=250000)

network.check()
# Add some nodes with corresponding Object Dictionaries
#masterNode = network.create_node(0x01)
#masterNode.nmt.state = 'OPERATIONAL'
#masterNode.nmt.start_heartbeat(100)

"""
EDS Details to remember
idx 100n    HB, SYNC, IDs ,etc
idx 1400    RX PDO parameters   COBid , /entries, type
idx 1600    RX PDO mapping
idx 1800    TX PDO parameters   COBid , /entries, type
idx 1A00    TX PDO mapping

for abtteries  Cia418
    idx 6000 to 67FF    Battery#1
        6800 to 68FF    Batt 2
        etc ...
        9800    9FFF    Batt 8
    6000 Battery status         ro
    6001 Charger status         rw
    6010 Temperature            multiples of 0,125 °C.   -320d to +680d -40.0 °C to +85.0 °C).
    6020 BAttery parameters
        01  Type
        02 Ah capacity
        03 Max Charge cuurernt
        04 Number of cell
    6030 Battery Seral Number
        01,02,03
    6031 Battery ID
    6040 Vehicle Serial Number ???
    6041 Vehicle ID
    6050 Cumulative total ah charge
    6051h: Ah expended since last charge
    6052h: Ah returned during last charge
    6053h: Ah since last equalization
    6054h: Date of last equalization
    6060h: Battery voltage          (1/1024) V.
    6070h: Charge current requested (1/16) A.
    6080h: Charger state of charge
    6081h: Battery state of charge
    6090h: Water level status

    cia419 : charger
    6000h VAR Battery status UNSIGNED8 rw M
    6001h VAR Charger status UNSIGNED8 ro M
    6010h VAR Temperature INTEGER16 rw M
    6052h VAR Ah returned during last charge UNSIGNED16 ro C
    6060h VAR Battery voltage UNSIGNED32 rw C
    6070h VAR Charge current requested UNSIGNED16 rw C
    6080h VAR Charger state of charge UNSIGNED8 ro C
    6081h VAR Battery state of charge UNSIGNED8 rw C

idx 2000
"""

node = canopen.BaseNode402(0x55, 'EDS/CR2016.eds')

network.add_node(node)

time.sleep(0.1)
node.nmt.state = 'RESET COMMUNICATION'
node.nmt.wait_for_bootup(15)
time.sleep(0.1)

node.nmt.state = 'RESET'
node.nmt.wait_for_bootup(15)
time.sleep(1)

def getnodestate():
    print("*** Get node State***")
    global node
    error_log = node.sdo[0x1003]
    for error in error_log.values():
        print("Error {0} was found in the log".format(hex(error.raw)))
    for node_id in network:
        print(network[node_id])

        print('node state 2) = {0}'.format(node.nmt.state))

    #node.sdo[0x1008]
    #node.load_configuration()
    sdoentries=[0x1005,0x1006,0x100c,0x100d,0x1014,0x1003,0x1017]
    #device_name = node.sdo[0x1008].raw
    #vendor_id = node.sdo[0x1018][1].raw

    #print(device_name)
    #print(hex(vendor_id))
    #network.start_node_guarding(0.1)
    for elem in sdoentries:
        if elem !=0x1003:
            val = node.sdo[elem].raw
            print("{:6} {:40} {:6} {}".format(hex(elem),node.sdo[elem].name,hex(val),val))
        else:
            print("{:6} {:40} {:6} {}".format(hex(elem),node.sdo[elem][0].name,hex(val),val))


    val = node.sdo[0x1016][0].raw
    elem=0x1016
    print("{:6} {:6} {:40} {}".format(hex(elem),hex(val),"Consumer heartbeat time of first Node",val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),hex(val),"Consumer heartbeat time of first Node",val))

    elem=0x1600
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1.1",hex(val),val))
    val = node.sdoval = node.sdo[elem][2].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1,2",hex(val),val))
    elem=0x1601
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 2",hex(val),val))
    elem=0x1602
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 3",hex(val),val))

    elem=0x1400
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    val = node.sdoval = node.sdo[elem][2].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    elem=0x1401
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 2",hex(val),val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 2",hex(val),val))
    val = node.sdoval = node.sdo[elem][2].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 2",hex(val),val))
    elem=0x1402
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 3",hex(val),val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 3",hex(val),val))
    val = node.sdoval = node.sdo[elem][2].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 3",hex(val),val))


    print('node state 1) = {0}'.format(node.nmt.state))
    print()

def setnodestate():
    print("*** Set node State***")
    """
    node.sdo[0x1006].raw
    node.sdo[0x1006].raw
    node.sdo[0x100c].raw
    node.sdo[0x100d].raw
    node.sdo[0x1014].raw
    node.sdo[0x1003][0].raw

    node.sdo[0x1006].raw
    node.sdo[0x100c].raw
    node.sdo[0x100d].raw
    node.sdo[0x1014].raw
    node.sdo[0x1003][0].raw

    node.sdo[0x1006].raw = 1        #communication cycle period
    node.sdo[0x100c].raw = 0      #guard time
    node.sdo[0x100d].raw = 3        #life time factor
    node.sdo[0x1014].raw = 163      #module generates EMCY messages
    node.sdo[0x1003][0].raw = 0
    node.sdo[0x1006].raw = 1000
    """
    val=node.sdo[0x1006].raw = 1        #communication cycle period
    print("val:",val)
    node.sdo[0x100c].raw = 1000      #guard time
    node.sdo[0x100d].raw = 3        #life time factor
    node.sdo[0x1014].raw = 0xD5      #module generates EMCY messages
    node.sdo[0x1017].raw = 1000      #module generates EMCY messages

    node.sdo[0x1003][0].raw = 0

    node.sdo[0x1600][0].raw = 1
    node.sdo[0x1601][0].raw = 0
    node.sdo[0x1602][0].raw = 0
    node.sdo[0x1006].raw = 90000


#getnodestate()

setnodestate()


getnodestate()
node.load_configuration()
network.sync.start(0.05)
node.nmt.state = 'OPERATIONAL'

print('node state 3) = {0}'.format(node.nmt.state))

#node.setup_402_state_machine()

device_name = node.sdo[0x1008].raw
vendor_id = node.sdo[0x1018][1].raw

print(device_name," device ID:",hex(vendor_id))

#node.state = 'SWITCH ON DISABLED'

#print('node state 4) = {0}'.format(node.nmt.state))
#print("TPDO setup...")
# Read PDO configuration from node
#node.tpdo.read()


# Re-map TxPDO1
"""
node.tpdo[1].clear()
node.tpdo[1].add_variable('Binary inputs','binary inputs 1')
node.tpdo[1].add_variable('Binary inputs','binary inputs 2')
node.tpdo[1].trans_type = 1
node.tpdo[1].event_timer = 0
node.tpdo[1].enabled = True
# Save new PDO configuration to node
node.tpdo.save()"""

# Change state to operational (NMT start)
node.nmt.state = 'OPERATIONAL'
print('node state 3) = {0}'.format(node.nmt.state))
# Read a value from TPDO[1]
#node.tpdo[1].wait_for_reception()
#speed = node.tpdo[1][0x6000,0x01]
#val = node.tpdo[0x6000,0x02].raw
#print("speed:",speed)
#print("val:",val)
# Disconnect from CAN bus
print("looping")
data=1

# init idx 2000 sub 19 to 20
datamsg=[0xAA,0x55]

for i in range(0x19,0x21):
    print("-",hex(i))
    node.sdo[0x2000][i].raw = 0x02
while 1:

    node.sdo[0x6200][2].raw = data & 0xFF
    #node.sdo[0x6200][2].raw = data & 0xFF
    elem=0x1400
    """
    val = node.sdoval = node.sdo[elem][0].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    val = node.sdoval = node.sdo[elem][1].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))
    val = node.sdoval = node.sdo[elem][2].raw
    print("{:6} {:6} {:40} {}".format(hex(elem),"rx pdo 1",hex(val),val))"""
    data =data*2
    if data>512:
        data=1
    tmp=datamsg[1]
    datamsg[1]=datamsg[0]
    datamsg[0]=tmp
    pass
    network.send_message(0x255,datamsg)
    time.sleep(0.5)
network.sync.stop()
network.disconnect()
