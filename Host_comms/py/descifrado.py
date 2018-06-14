#!/usr/bin/env python3

import time
import serial
import sys

LENGTH = 8 # Numero de cifras hexadecimales del cuerpo N (multiplo de 8)

def toInt (ascii):
    lenx = len(ascii)
    return sum(ord(ascii[byte])<<8*(lenx-byte-1) for byte in range(lenx))

def send_data_board(mens, ser):
    #ck, a, n, t = mens
    for num in mens:
        for i  in range(0, int(LENGTH/2), 1):
            ser.write(num[i])
        ack = ser.read(size=len(num))
        ack = "".join(map(chr, ack))[::-1]
        print("    " + str(hex(toInt(ack)))+ " " + str(toInt(ack)))

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
