import serial

def toInt (ascii):
    lenx = len(ascii)
    return sum(ord(ascii[byte])<<8*(lenx-byte-1) for byte in range(lenx))

ser = serial.Serial("COM4", 9600)

ck = b'00000000000000000000000111110001'
print("CK: " + str(ck)+ " " + str(int(ck, 2)))
ser.write([0xF1, 0x01, 0x00, 0x00])
ack = ser.read(size=4)
ack = "".join(map(chr, ack))[::-1]
print("    " + str(bin(toInt(ack)))+ " " + str(toInt(ack)))

a = b'11111111111111111111111111111111'
print("A:  " + str(a)+ " " + str(int(a, 2)))
ser.write([0xFF, 0xFF, 0xFF, 0xFF])
ack = ser.read(size=4)
ack = "".join(map(chr, ack))[::-1]
print("    " + str(bin(toInt(ack)))+ " " + str(toInt(ack)))

n = b'00000000000000000000001011111111'
print("N:  " + str(n)+ " " + str(int(n, 2)))
ser.write([0xFF, 0x02, 0x00, 0x00])
ack = ser.read(size=4)
ack = "".join(map(chr, ack))[::-1]
print("    " + str(bin(toInt(ack)))+ " " + str(toInt(ack)))

t = b'00000000000000000000000000010001'
print("T:  " + str(t)+ " " + str(int(t, 2)))
ser.write([0x11, 0x00, 0x00, 0x00])
ack = ser.read(size=4)
ack = "".join(map(chr, ack))[::-1]
print("    " + str(bin(toInt(ack)))+ " " + str(toInt(ack)))

k = b'11101100'
print("K: " + str(k)+ " " + str(int(k, 2)))
k1 = ser.read(size=1)
print("    " + str(bin(ord(k1)))+ " " + str(ord(k1)))

ser.close()
