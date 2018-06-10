# !/bin/bash

# 1-Introducir tiempo
# 2-Generar n y fi(n) aleatorio. (fpga_square_tester.c)
# 3-Prueba de rendimienro (descifrado.py con fichero de test)
# 4-Cifrar (clave encrypt_key.c)
# 5-Enviar datos para descifrar (donde ocurre la magia de verdad descifrado.py)

if [ $# = 1 ];
then

    cypher_time=$1
    
    #Random n
    bin/fpga_square_tester
    
    file_test_origin='decrypt_test.txt'
    file_test_exit='test_result.txt'
    py/descifrado.py $file_test_origin $file_test_exit
    
    cat 'test_result.txt'
    echo ' Segundotes'
    
    bin/fpga_ratio_analyze
    
    #Use time to get a good key
    bin/encrypt_key $cypher_time
    
    file_origin='key_encrypted.txt'
    file_exit='key_decrypted.txt'
    py/descifrado.py $file_origin $file_exit
    
    cat 'key_decrypted.txt'
    echo ' Segundotes'
    
else
    echo '$0 takes exactly 1 argument "cypher_time" (seconds)'
fi