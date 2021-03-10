def crc():
    Crc_key = 0xe36c

    Data = [0,0,0,0,0,0]
    u16_CRCresult = 0
    for i in range(0,6):
        u16_CRCresult = u16_CRCresult ^ Data[i]
        print(i,u16_CRCresult)
        for j in range(0,8):
            if (u16_CRCresult & 0x8000) != 0x0:
                print("crc key",)
                u16_CRCresult = (u16_CRCresult <<1) ^ Crc_key
            else:
                print("< ",)
                u16_CRCresult = u16_CRCresult << 1
        print()
    print(hex(u16_CRCresult))
    return u16_CRCresult

crc()