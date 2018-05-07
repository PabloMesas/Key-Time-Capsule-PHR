# Key-Time-Capsule---K.T.C.---P.H.R.---F.U.K.C.

La idea es implementar un sistema de cifrado que permita retener una clave durante un tiempo deseado. Este tipo de servicios se puede aplicar para poder cifrar archivos o documentos sensibles durante un tiempo mínimo como documentos clasificados del gobierno, el bloqueo de unos productos en una subasta o programar rutinas que solo serán efectivas pasado un tiempo.
La motivación de este proyecto ha surgido por la posibilidad de poder cifrar la clave de acceso de usuario de la videoconsola asegurándose que el acceso queda retenido durante un tiempo mínimo y así poder aprovechar el tiempo para algo más provechoso.
Nuestro objetivo principal comprende implementar al menos el sistema de descifrado dejando la tarea de cifrado para un host o cpu conectada con la fpga. De esta manera se relega la tarea más pesada y larga a la fpga.


Marcado este objetivo hito principal como cumplido se presentarán otros objetivos secundarios:

- Implementar varias unidades de descifrado junto a un planificador que distribuya la carga entre las distintas unidades.
- Implementar una unidad de cifrado.

El sistema de cifrado está basado en la investigación llevada a cabo por Ronald L. Rivest Adi Shamir y David A. Wagner sobre cifrado de claves temporal. Este cifrado se basa en el uso repetido de cuadrados de orden muy alto. En concreto, el cifrado de una clave se obtiene de resolver la ecuación

Ck=k+a^(2^t ) mod θ(n)

Siendo n un módulo formado por dos números primos muy grandes y t el parámetro donde se especifica el tiempo que permanecerá cifrado. K es por supuesto la clave a cifrar y Ck es la clave cifrada. A, es en un principio un valor positivo aleatorio inferior pero que probablemente se tome el valor 2 como constante para a para facilitar el cómputo sin comprometer la seguridad del cifrado. Tras esto, una vez cifrada la clave se deben desechar los valores p y q utilizados para obtener el módulo n. 
Dejando como única forma de obtener la clave de manera eficiente y rápida la resolución de esta ecuación

k=Ck-a^(2^t ) mod n
