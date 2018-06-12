import serial

def toInt (ascii):
    lenx = len(ascii)
    return sum(ord(ascii[byte])<<8*(lenx-byte-1) for byte in range(lenx))

ser = serial.Serial("COM4", 9600)

ck = b'00000000000000000000000111110001'
print("CK: " + str(ck)+ " " + str(int(ck, 2)))
ser.write([0xF1, 0x01, 0x00, 0x00])
k_1 = ser.read(size=4)
k_1 = "".join(map(chr, k_1))[::-1]
print("    " + str(bin(toInt(k_1)))+ " " + str(toInt(k_1)))

a = b'11111111111111111111111111111111'
print("A:  " + str(a)+ " " + str(int(a, 2)))
ser.write([0xFF, 0xFF, 0xFF, 0xFF])
k_1 = ser.read(size=4)
k_1 = "".join(map(chr, k_1))[::-1]
print("    " + str(bin(toInt(k_1)))+ " " + str(toInt(k_1)))

n = b'00000000000000000000001011111111'
print("N:  " + str(n)+ " " + str(int(n, 2)))
ser.write([0xFF, 0x02, 0x00, 0x00])
k_1 = ser.read(size=4)
k_1 = "".join(map(chr, k_1))[::-1]
print("    " + str(bin(toInt(k_1)))+ " " + str(toInt(k_1)))

t = b'00000000000000000000000000010001'
print("T:  " + str(t)+ " " + str(int(t, 2)))
ser.write([0x11, 0x00, 0x00, 0x00])
k_1 = ser.read(size=4)
k_1 = "".join(map(chr, k_1))[::-1]
print("    " + str(bin(toInt(k_1)))+ " " + str(toInt(k_1)))

k = b'11101100'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=1)
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

ser.close()
