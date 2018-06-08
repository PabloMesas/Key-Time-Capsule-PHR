from bitstring import BitStream, BitArray

line = '13f'
print (line)
line = BitArray(hex=line)
print (line)
line = str(line.hex)

while len(line) < 256:
        line = '0' + line
print (line)
line = BitArray(hex=line)
byte_line = bytes.fromhex(line)
print (byte_line)
line = BitArray(hex=line)
print (line)
bin_line = BitArray(line)
print (bin_line.bin)

byte_line = bytes.frombin(bin_line.bin)
print (byte_line)
