from PCANBasic import *


canbus = PCANBasic()


interface = TPCANHandle()




## Gets the formated text for a PCAN-Basic channel handle
##
def FormatChannelName( handle, isFD=False):
    if handle < 0x100:
        devDevice = TPCANDevice(handle >> 4)
        byChannel = handle & 0xF
    else:
        devDevice = TPCANDevice(handle >> 8)
        byChannel = handle & 0xFF

    toRet = ""
    if isFD:
        toRet=('%s: FD %s (%.2Xh)' % (GetDeviceName(devDevice.value), byChannel, handle))
    else:
        toRet=('%s: %s (%.2Xh)' % (GetDeviceName(devDevice.value), byChannel, handle))

    return toRet.get()
