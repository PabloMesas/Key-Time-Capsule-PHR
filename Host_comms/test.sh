# !/bin/bash

# 1-Introducir tiempo
# 2-Generar n y fi(n) aleatorio. (fpga_square_tester.c)
# 3-Prueba de rendimienro (descifrado.py con fichero de test)
# 4-Cifrar (clave encrypt_key.c)
# 5-Enviar datos para descifrar (donde ocurre la magia de verdad descifrado.py)

# This script run a decrypt test for a FPGA.

if [ $# = 1 ];
then
    # Get the time in seconds to decrypt the key.
    cypher_time=$1
    
    echo 'Creating a decrypt test...\n'
    # Create a decrypt test with the parameter t = 500000
    C/bin/fpga_square_tester 500000
    
    echo 'Launching the decrypt test to the FPGA...'
    # Launches the decrypt test to the FPGA to get the time invested in.
    file_test_origin='decrypt_test.txt'
    file_test_exit='test_result.txt'
    py/descifrado.py $file_test_origin $file_test_exit
    
    echo '\nTest result:'
    cat 'test_result.txt'
    echo ' sec.\n'
    
    echo 'Obtaining ratio square per secons with the modulus N and base a tested...'
    C/bin/fpga_ratio_analyze
    
    echo '\nEncrypting key allocated in key.txt for ' $cypher_time ' seconds...'
    # Encrypt the key allocated in key.txt for cypher_time seconds.
    C/bin/encrypt_key $cypher_time
    
    echo '\nLaunching the decrypt process to the FPGA...'
    # Launch the values to decrypt the crypted key.
    file_origin='key_encrypted.txt'
    file_exit='key_decrypted.txt'
    py/descifrado.py $file_origin $file_exit
    
    # Print the results.
    echo '\nKey decrypted:'
    cat 'key_decrypted.txt'
    echo ' sec.'
    
else
    echo $0' takes exactly 1 argument "cypher_time" (seconds)'
fi