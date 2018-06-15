#!/usr/bin/env python3

###############################################################################
###############################################################################
# This scripts reads the values Ck, a, n and t allocated in the file pointed
# in the first argument. Those hexadecimal values are truncated to bits and
# then segmented in 8 bits packages to transfer it through the serial bus.
# Once all the values are send, the program will wait to receive decrypted key
# from the FPGA to truncate it to an hexadecimal value.
###############################################################################
###############################################################################

import time
import serial
import sys

LENGTH = 8 # Number of hexadecimal ciphers in the body N 

###############################################################################
# Truncate a ascii byte to integer
###############################################################################
def toInt (ascii):
    lenx = len(ascii)
    return sum(ord(ascii[byte])<<8*(lenx-byte-1) for byte in range(lenx))

###############################################################################
# Send the variables allocated in the list "mens" through the port specified in
# "serial". For every variable send there is an ack which must be exactly the
# same variable send before.
###############################################################################
def send_data_board(mens, ser):
    #ck, a, n, t = mens
    for num in mens:
        for i  in range(0, int(LENGTH/2), 1):
            ser.write(num[i])
        ack = ser.read(size=len(num))
        ack = "".join(map(chr, ack))[::-1]
        print("    " + str(hex(toInt(ack)))+ " " + str(toInt(ack)))

###############################################################################
# Main programs use 2 arguments which are file to read the variables to send
# and file to write the decrypted key and time invested in the decryption.
#
# Before send the variables through the serial ports they must be converted
# to binary. The words must have LENGTH * 4 bits so in case the variables don't
# uses al the length it'll be attached with some zeros at the begining.
# After the last variable is send the program will store the actual time.
#
# Once the variables are send. The script will wait to receive the key
# decrypted which must have a dimension of LENGTH bits. 
# Then it will be converted to hexadecimal and it will catch the actual time
# to make the substraction with the other and obtain the time invested in the
# decrypt.
#
# Key and time invested will finally be stored in the file pointed in the
# second argument.
###############################################################################
if(len(sys.argv) != 3):
    print (sys.argv[0], 'takes exactly 2 argument (', len(sys.argv) - 1, ' given)' )
else:
    with open(sys.argv[1], "r") as in_file:
        out_file = open(sys.argv[2], 'w')

        ser = serial.Serial('/dev/ttyUSB1', 9600)
        mensaje = []

        for i in range(0,4):
            num =  []
            line = in_file.readline().rstrip('\n')
            line_len = len(line)
            zero_len = LENGTH - line_len

            if ( line_len % 2 != 0 ):
                for i in range(0, zero_len - 1, 2):
                    num.append(bytearray.fromhex('00'))
                num.append(bytearray.fromhex('0'+line[0]))
                for i in range(1, line_len, 2):
                    num.append(bytearray.fromhex(line[i]+line[i+1]))
            else:
                for i in range(0, zero_len, 2):
                    num.append(bytearray.fromhex('00'))
                for i in range(0, line_len, 2):
                    num.append(bytearray.fromhex(line[i]+line[i+1]))
            num.reverse()
            mensaje.append(num)

        print(ser.name)
        send_data_board(mensaje, ser)
        tiempoInicio = time.time()
        s = ser.read( size=int((LENGTH/8)) )
        tiempoFinal = time.time()
        transcurrido = tiempoFinal - tiempoInicio
        out_file.writelines(s.hex())
        out_file.write('\n')
        out_file.writelines(str(transcurrido))
