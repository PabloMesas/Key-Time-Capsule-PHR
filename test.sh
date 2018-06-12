# !/bin/bash

# 1-Introducir tiempo
# 2-Generar n y fi(n) aleatorio. (fpga_square_tester.c)
# 3-Prueba de rendimienro (descifrado.py con fichero de test)
# 4-Cifrar (clave encrypt_key.c)
# 5-Enviar datos para descifrar (donde ocurre la magia de verdad descifrado.py)

if [ $# = 1 ];
then

    cypher_time=$1
    
    echo 'Creating a decrypt test...\n'
    #Random n
    bin/fpga_square_tester 500000
    
    echo 'Launching the decrypt test to the FPGA...'
    file_test_origin='decrypt_test.txt'
    file_test_exit='test_result.txt'
    py/descifrado.py $file_test_origin $file_test_exit
    
    echo '\nTest result:'
    cat 'test_result.txt'
    echo ' sec.\n'
    
    echo 'Obtaining ratio square per secons with the modulus N and base a tested...'
    bin/fpga_ratio_analyze
    
    echo '\nEncrypting key allocated in key.txt for ' $1 ' seconds...'
    #Use time to get a good key
    bin/encrypt_key $cypher_time
    
    echo '\nLaunching the decrypt process to the FPGA...'
    file_origin='key_encrypted.txt'
    file_exit='key_decrypted.txt'
    py/descifrado.py $file_origin $file_exit
    
    echo '\nKey decrypted:'
    cat 'key_decrypted.txt'
    echo ' sec.'
    
else
    echo $0' takes exactly 1 argument "cypher_time" (seconds)'
fi