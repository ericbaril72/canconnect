#  canfox.py
#
#  ~~~~~~~~~~~~
#
#  MT-Basic API
#
#  ~~~~~~~~~~~~
#
#  ------------------------------------------------------------------
#  Author : Eric BAril
#  Last change:
#  Language: 3.8
#  ------------------------------------------------------------------
#
#

# Module Imports
#
from ctypes import *
from string import *
import os,time
os.environ['PATH'] = os.path.dirname(__file__) + ';' + os.environ['PATH']



#///////////////////////////////////////////////////////////
# Type definitions
#///////////////////////////////////////////////////////////
TPCANStatus                   = int         # Represents a PCAN status/error code


#///////////////////////////////////////////////////////////
# Value definitions
#///////////////////////////////////////////////////////////

# Canfox Classes
class canDEVLIST(Structure):
    _fields_ = [("Net", c_uint),
                ("Name", c_char * 20),
                ("ul_Status", c_ulong),
                ("ul_Features", c_ulong),
                ("Reserved", c_long * 18)]
    def __repr__(self):
        return "'Net': {}, 'Name': {}".format(self.Net, c_char_p(self.Name).value)

class devlist(Structure):
    _fields_ = [('elements', c_short),
                ("STRUCT_ARRAY", POINTER(canDEVLIST))]

class canMSG(Structure):        # canFOX version of canmsgs
    _fields_ = [
        ("id", c_long),
        ("len", c_ubyte),
        ("msg_lost", c_char),
        ("extended", c_char),
        ("remote", c_char),
        ("data", c_ubyte * 8),
        ("timestamp", c_ulong)
    ]
    def __repr__(self):
        return "    id:0x{:03x}, len: {}     {}".format(self.id, self.len,[hex(self.data[i]) for i in range(0,self.len)])

#///////////////////////////////////////////////////////////
# MT-API function declarations
#///////////////////////////////////////////////////////////

class CanFoxBasic:
    """
      canfox-MT-API class implementation
    """      
    def __init__(self):
        # Loads the MT-api.dll
        #
        dllpath = "C:\\Program Files (x86)\\Sontheim\\MT_Api\\SIECA132.dll"
        self.__m_dllBasic = windll.LoadLibrary(dllpath)


    # Initializes a canfox Channel
    #
    def Initialize(self):
        """
          Initializes a canfox Channel
        Returns:
          A CANStatus error code
        """
        func = self.__m_dllBasic.canGetNumberOfConnectedDevices
        func.argtypes = [POINTER(c_long)]
        func.restype = c_long

        a=0
        cntval = c_int(a)
        rez2 = func(cntval)

        totalDevice = cntval.value
        print("Found:", totalDevice)

        if totalDevice > 0:
            canFoxDevlist = (canDEVLIST * totalDevice)()
            DLLfunc_canGetDeviceList = self.__m_dllBasic.canGetDeviceList
            DLLfunc_canGetDeviceList.argtypes = [POINTER(canDEVLIST)]
            DLLfunc_canGetDeviceList.restype = c_long

            execResult = DLLfunc_canGetDeviceList(canFoxDevlist)
            for devnum in range(0,totalDevice):
                print("\t", canFoxDevlist[devnum])

            # Connect to device0 == number 105
            DLLfunc_canOpen = self.__m_dllBasic.canOpen
            DLLfunc_canOpen.argtypes = [c_long, c_long, c_long, c_long, c_long, c_char_p, c_char_p, c_char_p, POINTER(c_void_p)]
            DLLfunc_canOpen.restype = c_long



            #handle = c_void_p
            my_handle = c_void_p(0)
            self.my_handle = my_handle
            t_stat = c_int(4)
            net_num=c_long(105)
            rezC = DLLfunc_canOpen(net_num, 0, 0, 100, 100, b"", b"", b"", byref(my_handle))
            print("zC:",rezC)
            self.my_handle = my_handle

            # Connect to device0
            func_canEnableAllIds = self.__m_dllBasic.canEnableAllIds
            func_canEnableAllIds.argtypes = [c_void_p, c_bool]
            func_canEnableAllIds.restype = c_long
            t_bool = c_bool(1)
            rezD = func_canEnableAllIds(my_handle,1)
            print("All ID:",rezD)


            rezg = self.__m_dllBasic.canGetFilterMode(my_handle, byref(t_stat))
            print("rezg get filter", rezg, t_stat)
            t_stat = c_int(4)
            #rezg = self.__m_dllBasic.canSetFilterMode(my_handle, t_stat)
            #print("rezg SetFilter ", rezg, t_stat)
            t_stat = c_int(0)
            rezg = self.__m_dllBasic.canGetFilterMode(my_handle, byref(t_stat))
            print("rezg get filter", rezg, t_stat)
            self.my_handle = my_handle


            # setbaudrate Force
            #baudrate = c_long(4)    ## = 125

            baudrate = c_long(3)    ## = 250
            rezg = self.__m_dllBasic.canSetBaudrate(my_handle, baudrate)
            print("rezg SetBaudrate ", baudrate,rezg, t_stat)

            #rezg = self.__m_dllBasic.canClose(my_handle)
            #print("Closed", rezg)


            return TPCANStatus(rezC)

        


    # Reads a CAN message from the receive queue of a PCAN Channel
    #
    def Read(self):

        """
          Reads a CAN message from the receive queue of a PCAN Channel

        Remarks:
          The return value of this method is a 3-touple, where 
          the first value is the result (TPCANStatus) of the method.
          The order of the values are:
          [0]: A TPCANStatus error code
          [1]: A TPCANMsg structure with the CAN message read
          [2]: A TPCANTimestamp structure with the time when a message was read

        Returns:
          A touple with three values
        """
        try:
            msg = canMSG()
            len = c_int(1)
            res = self.__m_dllBasic.canReadNoWait(self.my_handle, byref(msg), byref(len))
            return TPCANStatus(res),msg,len

        except Exception as e:
            print ("Exception on PCANBasic.Read:",e)
            raise           


    # Transmits a CAN message 
    #
    def Write(self):

        """
          Transmits a CAN message 
          
        Parameters:
          Channel      : A TPCANHandle representing a PCAN Channel
          MessageBuffer: A TPCANMsg representing the CAN message to be sent
        
        Returns:
          A TPCANStatus error code
        """
        try:

            canMsg          = canMSG()
            canMsg.len      = 8
            canMsg.id       = 0x33
            canMsg.data[0]  = 0x11
            len             = c_byte(1)

            print("Sending: ",canMsg)

            DLLfunc_canConfirmedTransmit            = self.__m_dllBasic.canConfirmedTransmit
            #DLLfunc_canConfirmedTransmit.argtypes   = [c_void_p, c_void_p, c_void_p]
            #DLLfunc_canConfirmedTransmit.restype    = c_long

            execResult = DLLfunc_canConfirmedTransmit(self.my_handle ,byref(canMsg),byref(len))
            print(" exec Result:",execResult,"    len sent:",len)
            return TPCANStatus(execResult)

        except:
            print ("Exception on canfoxBasic.Write")
            raise




if __name__ == '__main__':

    canFox = CanFoxBasic()
    ifstatus = canFox.Initialize()
    idRX={}
    while True:
        result = canFox.Read()
        while result[0]==0:
            idRX[result[1].id]=result[1].timestamp
            result = canFox.Read()
        for id in idRX:
            print("{:03x}   {}".format(id,idRX[id]))
        res=canFox.Write()
        time.sleep(0.5)


