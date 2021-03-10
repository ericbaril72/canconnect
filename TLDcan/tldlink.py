class Parser:
    def __init__(self):
        self.defines = ["TLDLink"]
        self.ids=["1C427003","1C427103","1C427203","1C427303"]

    def parse(self,IdString,DataString):
        COid = int(IdString,16)&0x7f
        COtype=int(IdString,16)&0x780
        if IdString=="080":
            COtype="Sync"
        elif COtype==0x700:
            COtype="NMT HB"
        elif (int(IdString,16)& 0xFF8)==0x80:
            COtype="Emergency"
        elif IdString=="100":
            COtype="Timestamp PDO"
        elif COtype in [0x180,0x280,0x380,0x480]:
            COtype="TxPDO"
        elif COtype in [0x200,0x300,0x400,0x500]:
            COtype="RxPDO"
        elif COtype==0x580:
            COtype="Tx SDO"
        elif COtype==0x600:
            COtype="Rx SDO"
        elif IdString=="7E4" or IdString=="7E5":
            COtype="LSS ???"
        else:
            COtype=hex(COtype)

        """
        4:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node4Operational := TRUE;
                END_IF
            10:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 AND B_OPT_838 THEN
                    Node10Operational := TRUE;
                END_IF
            16:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node16Operational := TRUE;
                END_IF
            17:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node17Operational := TRUE;
                END_IF
            20:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node20Operational := TRUE;
                END_IF
            21:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node21Operational := TRUE;
                END_IF
            24:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node24Operational := TRUE;
                END_IF
            91:
                IF NodeStateSlavesArray[index].NODE_STATE = 5 THEN
                    Node91Operational := TRUE;
                    """
        COidSrc=""
        if COid==4:
            COidSrc="4"
        #elif COidSrc
        toret = "nothing    id:0x{:2X} type: {}".format(COid,COtype)
        if IdString in canfreekeys:
            deflist = canfree[IdString].keys()
            toret = str(deflist)
        return toret



