def test():
    import serial
    pname = '/dev/tty.usbserial-A800ewxY'
    ser = serial.Serial(pname, 115200)
    for i in range(0,10):
        print ser.read()
