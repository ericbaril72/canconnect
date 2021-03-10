# coding: utf-8

"""
Enable basic CAN over a PCAN USB device.
"""

from __future__ import absolute_import, print_function, division

import logging
import sys
import time

import can

from can import CanError, Message, BusABC
from can.bus import BusState

from can.util import len2dlc, dlc2len

from .CanFoxBasic import *

boottimeEpoch = 0
try:
    import uptime
    import datetime
    boottimeEpoch = (uptime.boottime() - datetime.datetime.utcfromtimestamp(0)).total_seconds()
except:
    boottimeEpoch = 0


try:
    # Try builtin Python 3 Windows API

    from _overlapped import CreateEvent
    from _winapi import WaitForSingleObject, WAIT_OBJECT_0, INFINITE
    HAS_EVENTS = True

except ImportError:
    try:
        # Try pywin32 package

        from win32event import CreateEvent
        from win32event import WaitForSingleObject, WAIT_OBJECT_0, INFINITE
        HAS_EVENTS = True

    except ImportError:
        # Use polling instead
        HAS_EVENTS = False

try:
    # new in 3.3
    timeout_clock = time.perf_counter
except AttributeError:
    # deprecated in 3.3
    timeout_clock = time.clock

# Set up logging
#log = logging.getLogger('can.pcan')


CANFOX_bitrate_objs = {  1000000 : CANFOX_BAUD_1M,
                          800000 : CANFOX_BAUD_800K,
                          500000 : CANFOX_BAUD_500K,
                          250000 : CANFOX_BAUD_250K,
                          125000 : CANFOX_BAUD_125K,
                          100000 : CANFOX_BAUD_100K,
                           95000 : CANFOX_BAUD_95K,
                           83000 : CANFOX_BAUD_83K,
                           50000 : CANFOX_BAUD_50K,
                           47000 : CANFOX_BAUD_47K,
                           33000 : CANFOX_BAUD_33K,
                           20000 : CANFOX_BAUD_20K,
                           10000 : CANFOX_BAUD_10K,
                            5000 : CANFOX_BAUD_5K
                         }


pcan_fd_parameter_list = ['nom_brp', 'nom_tseg1', 'nom_tseg2', 'nom_sjw', 'data_brp', 'data_tseg1', 'data_tseg2', 'data_sjw']


class CanFoxBus(BusABC):

    def __init__(self, channel=105, state=BusState.ACTIVE, bitrate=500000, *args, **kwargs):
        """A PCAN USB interface to CAN.



        """

        #super(CanFoxBus, self).__init__(self, channel='PCAN_USBBUS1', state=BusState.ACTIVE, bitrate=500000, *args, **kwargs)
        self.channel_info = channel
        self.fd = kwargs.get('fd', False)
        pcan_bitrate = CANFOX_bitrate_objs.get(bitrate, CANFOX_BAUD_250K)



        self.m_objCANFOXBasic = CANFOXBasic()
        self.m_PcanHandle = 105   #globals()[channel]
        self._filters = None

        if state is BusState.ACTIVE or state is BusState.PASSIVE:
            self.state = state
        else:
            raise ArgumentError("BusState must be Active or Passive")


        if self.fd:
            f_clock_val = kwargs.get('f_clock', None)
            if f_clock_val is None:
                f_clock = "{}={}".format('f_clock_mhz', kwargs.get('f_clock_mhz', None))
            else:
                f_clock = "{}={}".format('f_clock', kwargs.get('f_clock', None))

            fd_parameters_values = [f_clock] + ["{}={}".format(key, kwargs.get(key, None)) for key in pcan_fd_parameter_list if kwargs.get(key, None) is not None]

            self.fd_bitrate = ' ,'.join(fd_parameters_values).encode("ascii")


            result = self.m_objCANFOXBasic.InitializeFD(self.m_PcanHandle, self.fd_bitrate)
        else:
            if HAS_EVENTS:
                self._recv_event = CreateEvent(None, 0, 0, "R2")
                self._tran_event = CreateEvent(None, 0, 0, "T2")
            result = self.m_objCANFOXBasic.Initialize(self.m_PcanHandle, pcan_bitrate)

        if result != CANFOX_ERROR_OK:
            raise PcanError(self._get_formatted_error(result))

        if HAS_EVENTS:

            if 0:
                self._recv_event = CreateEvent(None, 0, 0, "R2")
                result = self.m_objCANFOXBasic.SetValue(
                    self.m_PcanHandle, 1, self._recv_event) #"""PCAN_RECEIVE_EVENT"""
                if result != CANFOX_ERROR_OK:
                    raise PcanError(self._get_formatted_error(result))

        super(CanFoxBus, self).__init__(channel=channel, state=state, bitrate=bitrate, *args, **kwargs)

    def _get_formatted_error(self, error):
        """
        Gets the text using the GetErrorText API function.
        If the function call succeeds, the translated error is returned. If it fails,
        a text describing the current error is returned. Multiple errors may
        be present in which case their individual messages are included in the
        return string, one line per error.
        """

        def bits(n):
            """
            Iterate over all the set bits in `n`, returning the masked bits at
            the set indices
            """
            while n:
                # Create a mask to mask the lowest set bit in n
                mask = (~n + 1)
                masked_value = n & mask
                yield masked_value
                # Toggle the lowest set bit
                n ^= masked_value

        stsReturn = self.m_objCANFOXBasic.GetErrorText(error, 0)
        if stsReturn[0] != CANFOX_ERROR_OK:
            strings = []

            for b in bits(error):
                stsReturn = self.m_objCANFOXBasic.GetErrorText(b, 0)
                if stsReturn[0] != CANFOX_ERROR_OK:
                    text = "An error occurred. Error-code's text ({0:X}h) couldn't be retrieved".format(error)
                else:
                    text = stsReturn[1].decode('utf-8', errors='replace')

                strings.append(text)

            complete_text = '\n'.join(strings)
        else:
            print("is OK",stsReturn[1])
            try:
                complete_text = stsReturn[1].decode('utf-8', errors='replace')
            except:
                complete_text = stsReturn[1]
        return complete_text

    def status(self):
        """
        Query the PCAN bus status.

        :rtype: int
        :return: The status code. See values in **basic.PCAN_ERROR_**
        """
        return self.m_objCANFOXBasic.GetStatus(self.m_PcanHandle)

    def status_is_ok(self):
        """
        Convenience method to check that the bus status is OK
        """
        status = self.status()
        return status == PCAN_ERROR_OK

    def reset(self):
        """
        Command the PCAN driver to reset the bus after an error.
        """
        status = self.m_objCANFOXBasic.Reset(self.m_PcanHandle)
        return status == PCAN_ERROR_OK

    def _recv_internal(self, timeout):

        if HAS_EVENTS:
            # We will utilize events for the timeout handling
            timeout_ms = int(timeout * 1000) if timeout is not None else INFINITE
        elif timeout is not None:
            # Calculate max time
            end_time = timeout_clock() + timeout

        #log.debug("Trying to read a msg")

        result = None
        while result is None:
            if self.fd:
                result = self.m_objCANFOXBasic.ReadFD(self.m_PcanHandle)
            else:
                #print("Read")
                result = self.m_objCANFOXBasic.Read(self.m_PcanHandle)

            if result[0] == CANFOX_ERROR_QRCVEMPTY:
                if HAS_EVENTS:
                    result = None
                    val = WaitForSingleObject(self._recv_event, timeout_ms)
                    if val != WAIT_OBJECT_0:
                        return None, False
                elif timeout is not None and timeout_clock() >= end_time:
                    return None, False
                else:
                    result = None
                    time.sleep(0.001)
            elif result[0] & (CANFOX_ERROR_BUSLIGHT | CANFOX_ERROR_BUSHEAVY):
                log.warning(str(self._get_formatted_error(result[0]).value)+ " --")
                return None, False
            elif result[0] != CANFOX_ERROR_OK:
                raise PcanError(self._get_formatted_error(result[0]))
            elif result[0] ==-1:
                print("is -1 !!!!")

        #print("RX ")
        theMsg = result[1]
        itsTimeStamp = result[2]

        #log.debug("Received a message")

        is_extended_id = (theMsg.extended ) == 1
        is_remote_frame = (theMsg.remote ) == 1
        is_fd = 0
        bitrate_switch = 1
        error_state_indicator = 1
        is_error_frame = 1


        if self.fd:
            dlc = dlc2len(theMsg.DLC)
            timestamp = boottimeEpoch + (itsTimeStamp.value / (1000.0 * 1000.0))
        else:
            dlc = theMsg.len
            timestamp = boottimeEpoch + itsTimeStamp.value


        rx_msg = Message(timestamp=theMsg.timestamp,
                         arbitration_id=theMsg.id,
                         is_extended_id=is_extended_id,
                         is_remote_frame=is_remote_frame,
                         is_error_frame=is_error_frame,
                         dlc=dlc,
                         data=theMsg.data[:dlc],
                         is_fd=is_fd,
                         bitrate_switch=bitrate_switch,
                         error_state_indicator=error_state_indicator)

        return rx_msg, False

    def send(self, msg, timeout=None):
        msgType = 1 if msg.is_extended_id else 0

        if 1:
            # create a TPCANMsg message structure

            CANMsg = canMSG()
            canMsg = canMSG()
            len = c_long(0)
            canMsg.len = c_ubyte(8)
            #canMsg.data = MessageBuffer.DATA
            canMsg.extended = c_char(0)
            canMSG.remote  = c_char(0)
            canMsg.id   = msg.arbitration_id
            # configure the message. ID, Length of data, message type and data
            CANMsg.ID = msg.arbitration_id
            CANMsg.LEN = msg.dlc
            CANMsg.MSGTYPE = msgType

            # if a remote frame will be sent, data bytes are not important.
            if not msg.is_remote_frame:
                # copy data
                for i in range(CANMsg.LEN):
                    pass
                    canMsg.data[i] = msg.data[i]


            #log.debug("Data: %s", msg.data)
            #log.debug("Type: %s", type(msg.data))
            #print("Send")
            result = self.m_objCANFOXBasic.Write(self.m_PcanHandle, canMsg)

        if result != CANFOX_ERROR_OK:
            raise PcanError("Failed to send: " + self._get_formatted_error(result))

    def flash(self, flash):
        """
        Turn on or off flashing of the device's LED for physical
        identification purposes.
        """
        print("calling canfox.py-> flash()")
        #self.m_objCANFOXBasic.SetValue(self.m_PcanHandle, PCAN_CHANNEL_IDENTIFYING, bool(flash))

    def shutdown(self):
        super(CanFoxBus, self).shutdown()
        self.m_objCANFOXBasic.Uninitialize(self.m_PcanHandle)

    @property
    def state(self):
        return self._state

    @state.setter
    def state(self, new_state):

        self._state = new_state

        if new_state is BusState.ACTIVE:
            #print("calling canfox.py-> state bus active")
            #self.m_objCANFOXBasic.SetValue(self.m_PcanHandle, PCAN_LISTEN_ONLY, PCAN_PARAMETER_OFF)
            pass

        elif new_state is BusState.PASSIVE:
             print("calling canfox.py-> state bus passive")
            # When this mode is set, the CAN controller does not take part on active events (eg. transmit CAN messages)
            # but stays in a passive mode (CAN monitor), in which it can analyse the traffic on the CAN bus used by a
            # PCAN channel. See also the Philips Data Sheet "SJA1000 Stand-alone CAN controller".
            #self.m_objCANFOXBasic.SetValue(self.m_PcanHandle, PCAN_LISTEN_ONLY, PCAN_PARAMETER_ON)

    @staticmethod
    def _detect_available_configs():
        configs = [{'interface': 'canfox', 'channel': '105'}]
        print("detected avail configs")
        return configs
        channel_configs = get_channel_configs()
        LOG.info('Found %d channels', len(channel_configs))
        for channel_config in channel_configs:
            if not channel_config.channelBusCapabilities & vxlapi.XL_BUS_ACTIVE_CAP_CAN:
                continue
            LOG.info('Channel index %d: %s',
                     channel_config.channelIndex,
                     channel_config.name.decode('ascii'))
            configs.append({'interface': 'vector',
                            'app_name': None,
                            'channel': channel_config.channelIndex})
        return configs

def get_channel_configs():
    """if vxlapi is None:
        return []
    driver_config = vxlapi.XLdriverConfig()
    try:
        vxlapi.xlOpenDriver()
        vxlapi.xlGetDriverConfig(driver_config)
        vxlapi.xlCloseDriver()
    except:
        pass"""
    return ["canFox0"]
class PcanError(CanError):
    """
    A generic error on a PCAN bus.
    """
    pass

