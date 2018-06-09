import serial

ser = serial.Serial("COM4", 9600)

ck = b'47B0264C'
print("CK: " + str(ck)+ " " + str(int(ck, 16)))
ser.write([0x4C, 0x26, 0xB0, 0x47])

a = b'167C47F2'
print("A:  " + str(a)+ " " + str(int(a, 16)))
ser.write([0xF2, 0x47, 0x7C, 0x16])

n = b'59793353'
print("N:  " + str(n)+ " " + str(int(n, 16)))
ser.write([0x53, 0x33, 0x79, 0x59])

t = b'00000004'
print("T:  " + str(t)+ " " + str(int(t, 16)))
ser.write([0x04, 0x00, 0x00, 0x00])

k = b'11101011'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=1)
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

###########################################################
print("\n")
###########################################################

ck = b'29AE071F'
print("CK: " + str(ck)+ " " + str(int(ck, 16)))
ser.write([0x1F, 0x07, 0xAE, 0x29])

a = b'51647052'
print("A:  " + str(a)+ " " + str(int(a, 16)))
ser.write([0x52, 0x70, 0x64, 0x51])

n = b'CB65F26B'
print("N:  " + str(n)+ " " + str(int(n, 16)))
ser.write([0x6B, 0xF2, 0x65, 0xCB])

t = b'00000030'
print("T:  " + str(t)+ " " + str(int(t, 16)))
ser.write([0x30, 0x00, 0x00, 0x00])

k = b'10000000'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=1)
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

###########################################################
print("\n")
###########################################################

ck = b'3A6B178D'
print("CK: " + str(ck)+ " " + str(int(ck, 16)))
ser.write([0x8D, 0x17, 0x6B, 0x3A])

a = b'167C47F2'
print("A:  " + str(a)+ " " + str(int(a, 16)))
ser.write([0xF2, 0x47, 0x7C, 0x16])

n = b'59793353'
print("N:  " + str(n)+ " " + str(int(n, 16)))
ser.write([0x53, 0x33, 0x79, 0x59])

t = b'0000041C'
print("T:  " + str(t)+ " " + str(int(t, 16)))
ser.write([0x1C, 0x04, 0x00, 0x00])

k = b'00100110'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=1)
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

###########################################################
print("\n")
###########################################################

ck = b'20F6C535'
print("CK: " + str(ck)+ " " + str(int(ck, 16)))
ser.write([0x35, 0xC5, 0xF6, 0x20])

a = b'2BA2AE9D'
print("A:  " + str(a)+ " " + str(int(a, 16)))
ser.write([0x2B, 0xA2, 0xAE, 0x9D])

n = b'6D18D4EF'
print("N:  " + str(n)+ " " + str(int(n, 16)))
ser.write([0xEF, 0xD4, 0x18, 0x6D])

t = b'00010000'
print("T:  " + str(t)+ " " + str(int(t, 16)))
ser.write([0x00, 0x00, 0x01, 0x00])

k = b'01101001'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=1)
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

ser.close()
