#include <stdio.h>

#include "math.h"

/*
--------------------------------------------------------------------
  Main
--------------------------------------------------------------------
*/
int main (int argc, char *argv[]) {
  int length;
  
  if (argc != 2) {
    printf ("Introduce key length in bits\n");
    return 0;
  }

  // We add 3 chars.
  length = atoi(argv[1]);

  char seedStr[length+3];
  mpz_t seed, key;
  mpz_init(seed);
  mpz_init(key);

  // Setting the randomizer.
  gmp_randstate_t randomizer;
  gmp_randinit_default(randomizer);

  // Obtaining random seed, converting to mpz int and setting it.
  randomSeed(length+3, seedStr);
  mpz_set_str(seed, seedStr, 0);
  gmp_randseed(randomizer, seed);

  // Random key with length in bits
  mpz_urandomb(key, randomizer, length);

  // Store data
  FILE *fp;
  fp = fopen("key.txt", "w");
  mpz_out_str(fp, 10, key);
  fclose(fp);

  // Free memory
  mpz_clear(key);
  mpz_clear(seed);
}