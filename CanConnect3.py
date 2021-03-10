import time
from threading import Thread,Timer
#commit test in first branch
# import Webserver librairies and webclient
from flask import Flask, send_from_directory, render_template
from flask_socketio import SocketIO, emit
import webbrowser

# import standard CANbus librairy
from TLDcan.decode import BusInterface

#
#
# CANFOX DOC https://www.sontheim-industrie-elektronik.de/fileadmin/user_data/Dokumente/Technische-Beschreibungen/SIECA132_307_EN.pdf
# pyinstaller -w -F --add-data "templates;templates" --add-data "static;static" app.py



# ****************************************************************************************************
# Application Configuration
# ****************************************************************************************************
#
# webserver app c& configuration
app = Flask(__name__)
app.debug = False
app.use_reloader = True
app.config['SECRET_KEY'] = 'secret!'

# socketIO for async data transfer
socketio = SocketIO(app)

# TLD Canbus process and config
#canInterface = {'interface':'canfox','channel':'105','bitrate':250000}
canInterface = {'interface':'pcan','channel':'PCAN_USBBUS1','bitrate':250000}
try:
    bInterface = BusInterface(canInterface)
except:
    bInterface = None

thread = None
webControls = {}



# backgroung thread checking for RX CANmsg and Transmit to WebClient via socketIO emit
def background_stuff():
    global webControls
    #socketio_refresh_timeout = time.time()
    #ut = socketio_refresh_timeout
    slowupdate=time.time()
    while True:
        if bInterface:
            emitData = bInterface.process()
        else:
            emitData = {'type':None}
        if emitData['type']=='fast':

            socketio.emit('message', emitData, namespace='/test')
        elif emitData['type']=='slow':
            #print("businfo",emitData)
            socketio.emit('businfo', emitData, namespace='/test')
            if "ControlSelected" in webControls.keys():
                if bInterface:
                    bInterface.msgArray.txmit()

        if time.time()>slowupdate:
            slowupdate = time.time()+5
            #print("Keys:",bInterface.msgArray.getParsers())
            print("Alive", emitData,"Web Controls:",webControls)



def nodef():
        #socketio.emit('message', emitData , namespace='/test')

        """#msgArray.recv(0.001)

        if 0:
            if time.time()> ut:
                ut=time.time()+4
                srclist=sys.modules.keys()
                tldmods=[]
                for x in srclist:
                    if x.startswith("TLD"):
                        tldmods.append(x)

                print("version:",msgArray.version,tldmods)
            if time.time() > slowupdate:
                slowupdate = time.time() + 3
                mainArray = bInfo.getDevices()
                print(mainArray)
                socketio.emit('businfo', {'interface': canInterface, 'dataArray': mainArray }, namespace='/test')

            if time.time()> socketio_refresh_timeout:
                socketio_refresh_timeout = time.time() + socketIO_refresh_period
                unsent = msgArray.getUnsent()

                if len(unsent):
                    try:
                        socketio.emit('message', {'interface': canInterface, 'dataArray': unsent }, namespace='/test')

                    except:
                        print("Emit exceptio:",Exception)"""


# ****************************************************************************************************
# Socket IO Stuff - comm diagnostics mainly
# ****************************************************************************************************
#
@socketio.on('my event', namespace='/test')
def my_event(msg):

    print("From Browser TAB:",msg['data'])

@socketio.on('webControls', namespace='/test')
def my_event(msg):
    global webControls
    webControls = msg['data']
    print("Web Controls:",msg['data'])

@socketio.on('connect', namespace='/test')
def test_connect():
    emit('my response', {'data': 'Connected', 'count': 0})

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')



# ****************************************************************************************************
# Web Server URLs
# ****************************************************************************************************
#
@app.route('/')
def index():
    global thread
    if thread is None:
        thread = Thread(target=background_stuff)
        thread.start()
    if bInterface:
        data=bInterface.msgArray.getParsers()
    else:
        data={}
    return render_template("index.html",data=data)
    return send_from_directory("templates", "index.html", as_attachment=False,cache_timeout =10)

@app.route('/page2')
def index2():
    global thread
    if thread is None:
        thread = Thread(target=background_stuff)
        thread.start()
    return send_from_directory("templates", "index2.html", as_attachment=False,cache_timeout =10)
@app.route('/businfo')
def businfo():
    global thread
    if thread is None:
        thread = Thread(target=background_stuff)
        thread.start()
    return send_from_directory("templates", "businfo.html", as_attachment=False,cache_timeout =10)


# ****************************************************************************************************
# Main
# ****************************************************************************************************
#

if __name__ == "__main__":
    # delayed start for interface TAB
    starturl = "http://127.0.0.1:5000"
    Timer(0.4, lambda : webbrowser.open(starturl) ).start()

    #start Application
    socketio.run(app)


