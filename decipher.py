import serial

ser = serial.Serial("COM4", 9600)

ck = b'00000000000000000000000100111111'
print("CK: " + str(ck)+ " " + str(int(ck, 2)))
ser.write([0x3F, 0x01, 0x00, 0x00])

a = b'00000000000000000000000000000011'
print("A:  " + str(a)+ " " + str(int(a, 2)))
ser.write([0x03, 0x00, 0x00, 0x00])

n = b'00000000000000000000001011111111'
print("N:  " + str(n)+ " " + str(int(n, 2)))
ser.write([0xFF, 0x02, 0x00, 0x00])

t = b'00000000000000000000000000000101'
print("T:  " + str(t)+ " " + str(int(t, 2)))
ser.write([0x05, 0x00, 0x00, 0x00])

print("Waiting for result...")




k = b'01110011'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read()
print("    " + str(bin(ord(k_1)))+ " " + str(ord(k_1)))

ser.close()
