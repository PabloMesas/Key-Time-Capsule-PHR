# Key-Time-Capsule-PHR

La idea es implementar un sistema de cifrado que permita retener una clave durante un tiempo deseado. Este tipo de servicios se puede aplicar para poder cifrar archivos o documentos sensibles durante un tiempo mínimo como por ejemplo documentos clasificados del gobierno, ocultar ofertas en una subasta o programar rutinas que solo serán efectivas pasado un tiempo.

Este planteamiento viene a implementar lo postulado en Time-lock puzzles and timed-release Crypto, 1996 por Ronald L. Rivest, Adi Shamir, y David A. Wagner.

Nuestro objetivo principal comprende implementar al menos el sistema de descifrado dejando la tarea de cifrado para un host o cpu conectada con la fpga. De esta manera se relega la tarea más pesada y larga a la fpga.

El sistema implementado hace uso de un Host, CPU con conexión a un puerto serie, y una placa de desarrollo FPGA Basys 3. De forma que la FPGA actua como coprocesador del host y se encarga de descifrar las claves cifradas por el método postulado en Time-Lock puzzle. Mientras que el Host cifra las claves con la seguridad de que permanecerán cifradas pasado un tiempo especificado.