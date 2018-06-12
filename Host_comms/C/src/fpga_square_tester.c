#include <stdio.h>
#include "math.h"

/*
--------------------------------------------------------------------
  Set a modulus n and fiN, base, CryptedKey and t to test the fpga
  performance.
--------------------------------------------------------------------
*/
int main (int argc, char *argv[]) {
  int testCicle = 1;
  mpz_t Ck, powMod, base, e, two, t, n, fiN;
  FILE *fp;

  mpz_init(Ck);
  mpz_init(powMod);
  mpz_init(base);
  mpz_init(e);
  mpz_init(two);
  mpz_init(t);
  mpz_init(n);
  mpz_init(fiN);

  // Key value for test
  mpz_set_str(Ck, "69", 16);
  
  // Control argument input
  if (argc == 2) mpz_set_str(t, argv[1], 16);
  else mpz_set_str(t, "100 000", 10);

  // Obtain a random modulus n of 2*PRIME_LENGTH bits
  getModulus(n, fiN);
  // Obtaining random base.
  getRandomBase(base, n);

  // Calcule Crypted Key
  // e = 2 ^ t mod fi(n)
  mpz_set_ui (two, 2L);
  mpz_powm(e, two, t, fiN);
  // powMod = base ^ e mod n
  mpz_powm(powMod, base, e, n);
  // Obtain encrypted key
  mpz_add(Ck, Ck, powMod);


  // Store data
  fp = fopen("decrypt_test.txt", "w");
  mpz_out_str(fp, 16, Ck);
  fputc('\n', fp);
  mpz_out_str(fp, 16, base);
  fputc('\n', fp);
  mpz_out_str(fp, 16, n);
  fputc('\n', fp);
  mpz_out_str(fp, 16, t);
  fputc('\n', fp);
  mpz_out_str(fp, 16, fiN);
  fclose(fp);

  // Free memory
  mpz_clear(Ck);
  mpz_clear(powMod);
  mpz_clear(base);
  mpz_clear(e);
  mpz_clear(two);
  mpz_clear(t);
  mpz_clear(n);
  mpz_clear(fiN);

  return 0;
}