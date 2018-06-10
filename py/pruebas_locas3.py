from bitstring import BitStream, BitArray
import time

with open("key_encrypted32.txt", "r") as in_file:
    out_file = open('key_decrypted.txt', 'w')
    tiempoInicio = time.time()
    
    for i in range(0,4):
        line = in_file.readline().rstrip('\n')
        mensaje = []
        while len(line) < 8: #Añadimos los 0 necesarios para que el numero sea de 1024
            line = '0' + line
        for i in range(7, -1, -2):
            numero =line[i-1] + line[i]
            print (numero)
            print (bytearray.fromhex(numero))
            # print (bytes(numero))
            # mensaje.append(bytes(numero))
        # line = BitArray(hex=line)
        # print (line)
        # print (line.bin)
        # print(mensaje)
    tiempoFinal = time.time()
    transcurrido = tiempoFinal - tiempoInicio
    print (transcurrido)
