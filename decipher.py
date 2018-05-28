import serial

ser = serial.Serial("COM4", 9600)

ck = b'00000000000000000000000100111111'
print("CK: " + str(ck)+ " " + str(int(ck, 2)))
ser.write(ck)

a = b'00000000000000000000000000000011'
print("A:  " + str(a)+ " " + str(int(a, 2)))
ser.write(a)

n = b'00000000000000000000001011111111'
print("N:  " + str(n)+ " " + str(int(n, 2)))
ser.write(n)

t = b'00000000000000000000000000000101'
print("T:  " + str(t)+ " " + str(int(t, 2)))
ser.write(t)

print("Waiting for result...")

k = b'01110011'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=len(k))
print("    " + str(k_1))
