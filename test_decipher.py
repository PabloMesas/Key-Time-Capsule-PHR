import serial

ser = serial.Serial("COM4", 9600)

ck = b'00000000000000000000000100111111'
print("CK: " + str(ck)+ " " + str(int(ck, 2)))
ser.write(ck)
ck_1 = ser.read(size=len(ck))
print("    " + str(ck_1))

print("Waiting for result...")

k = b'01110011'
print("K: " + str(k)+ " " + str(int(k, 2)))
k_1 = ser.read(size=len(k))
print("    " + str(k_1))
