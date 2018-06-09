#include <stdio.h>
#include <sys/resource.h> // setpriority()

#include "math.h"

/*
--------------------------------------------------------------------
  Main
--------------------------------------------------------------------
*/
int main (int argc, char *argv[]) {
  long int secondsEncrypted;
  FILE *fp;

  mpz_t n, fiN, exp, time_z, two, base, powMod, key, encryptedKey;
  mpz_init(n);
  mpz_init(fiN);
  mpz_init(exp);
  mpz_init(time_z);
  mpz_init(two);
  mpz_init(base);
  mpz_init(powMod);
  mpz_init(key);
  mpz_init(encryptedKey);
  //float
  mpf_t time_f;
  mpf_init(time_f);

  // Capture from argument the time the key will need to be
  // decrypted.
  if (argc != 2) {
    printf ("Introduce encrypt time (seconds)\n");
    return 1;
  }
  secondsEncrypted = atol(argv[1]);

  // Read the ratio square per seconds stored in file.
  fp = fopen("average_square_per_seconds.txt", "r");
  if (!fp) {
    printf("average_square_per_seconds.txt not found");
    return 1;
  }
  mpz_inp_str(n, fp, 16);
  mpz_inp_str(fiN, fp, 16);
  mpz_inp_str(base, fp, 16);
  mpf_inp_str(time_f, fp, 10);
  fclose(fp);
  mpz_out_str(NULL, 16, n);
  printf("\n");
  mpz_out_str(NULL, 16, fiN);
  printf("\n");
  mpz_out_str(NULL, 16, base);
  printf("\n");
  mpf_out_str(NULL, 10, 10, time_f);
  printf("\n");

  // Calculate T parameter (T = time(seconds) * ratio(square per
  // per seconds).
  mpf_mul_ui(time_f, time_f, secondsEncrypted);
  mpz_set_f(time_z, time_f);
  mpz_out_str(NULL, 16, time_z);
  printf("\n");

  // Obtaining random base.
  //getRandomBase(base, n);

  // exp = 2 ^ time mod fi(n)
  mpz_set_ui (two, 2L);
  mpz_powm(exp, two, time_z, fiN);

  // powMod = base ^ exp mod n
  mpz_powm(powMod, base, exp, n);

  // Get key value and load it into a mpz_int
  fp = fopen("key.txt", "r");
  mpz_inp_str(key, fp, 10);
  mpz_out_str(NULL, 10, key);
  printf("\n");
  fclose(fp);
  // Obtain encrypted key
  mpz_add(encryptedKey, key, powMod);

  // Store data to next decrypt
  fp = fopen("key_encrypted.txt", "w");
  mpz_out_str(fp, 16, encryptedKey);
  fputc('\n', fp);
  mpz_out_str(fp, 16, base);
  fputc('\n', fp);
  mpz_out_str(fp, 16, n);
  fputc('\n', fp);
  mpz_out_str(fp, 16, time_z);
  fclose(fp);

  // Free memory
  mpz_clear(n);
  mpz_clear(fiN);
  mpz_clear(exp);
  mpz_clear(two);
  mpz_clear(base);
  mpz_clear(powMod);
  mpz_clear(time_z);
  mpz_clear(key);
  mpz_clear(encryptedKey);
  mpf_clear(time_f);
  return 0;
}
