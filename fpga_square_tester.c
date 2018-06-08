#include <stdio.h>
#include "math.h"

int main (int argc, char *argv[]) {
  int testCicle = 1;
  mpz_t n, fiN, base, t, Ck;
  FILE *fp;

  mpz_init(n);
  mpz_init(fiN);
  mpz_init(base);
  mpz_init(t);
  mpz_init(Ck);

  mpz_set_str(Ck, "0", 16);
  
  // Control argument input
  if (argc == 2) mpz_set_str(t, argv[1], 16);
  else mpz_set_str(t, "2", 16);

  // Obtain a random modulus n of 2*PRIME_LENGTH bits
  getModulus(n, fiN);
  // Obtaining random base.
  getRandomBase(base, n);

  // Store data
  fp = fopen("decrypt_test.txt", "w");
  mpz_out_str(fp, 16, Ck);
  fputc('\n', fp);
  mpz_out_str(fp, 16, base);
  fputc('\n', fp);
  mpz_out_str(fp, 10, n);
  fputc('\n', fp);
  mpz_out_str(fp, 10, t);
  fputc('\n', fp);
  mpz_out_str(fp, 16, fiN);
  fclose(fp);

  // Free memory
  mpz_clear(n);
  mpz_clear(fiN);
  mpz_clear(base);
  mpz_clear(t);
  mpz_clear(Ck);
  }