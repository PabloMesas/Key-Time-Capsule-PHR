import serial
import numpy as np

ser = serial.Serial("COM4", 9600)

data = 0
for i in np.arange(0, 10000, 9):
    data_encoded = bytes(str(data).encode('ascii'))
    data_len = len(data_encoded)
    print("T:" + str(data_encoded))
    ser.write(data_encoded)
    print("  " + str(ser.read(size=data_len)))
    data = i
