#include <stdio.h>
#include <sys/resource.h> // setpriority()

#include "math.h"

/*
--------------------------------------------------------------------
  Capture from the argument the time which the key will be encrypted
  Then, from the file average_square_per_seconds, it will obtain
  the components n, fiN, base and ratio.
  With the ration and the time it will calculate t. Next one will
  be e from e = 2 ^ t mod fiN to finally obtain powmod with
  powmod = base ^ e mod n.
  Eventually the next step will be get Ck = k + powmod.
  And in the last part store the encryptedkey, base, n and t ready
  to be readed and decrypted by an FPGA.
--------------------------------------------------------------------
*/
int main (int argc, char *argv[]) {
  long int secondsEncrypted;
  FILE *fp;

  mpz_t encryptedKey, key, powMod, base, e, two, t, n, fiN;
  mpz_init(encryptedKey);
  mpz_init(key);
  mpz_init(powMod);
  mpz_init(base);
  mpz_init(e);
  mpz_init(two);
  mpz_init(t);
  mpz_init(n);
  mpz_init(fiN);

  //float
  mpf_t ratio;
  mpf_init(ratio);

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
  mpf_inp_str(ratio, fp, 10);
  fclose(fp);
  printf("n:\t");
  mpz_out_str(NULL, 16, n);
  printf("\nfiN:\t");
  mpz_out_str(NULL, 16, fiN);
  printf("\nbase:\t");
  mpz_out_str(NULL, 16, base);
  printf("\nratio:\t");
  mpf_out_str(NULL, 10, 10, ratio);
  printf("\n");

  // Calculate T parameter (ratio(square per seconds * T = time(seconds)
  mpf_mul_ui(ratio, ratio, secondsEncrypted);
  mpz_set_f(t, ratio);
  printf("time:\t%li\n", secondsEncrypted);
  printf("t:\t");
  mpz_out_str(NULL, 16, t);
  printf("\n");

  // e = 2 ^ t mod fi(n)
  mpz_set_ui (two, 2L);
  mpz_powm(e, two, t, fiN);

  // powMod = base ^ e mod n
  mpz_powm(powMod, base, e, n);

  // Get key value and load it into a mpz_int
  fp = fopen("key.txt", "r");
  if (!fp) {
    printf("key.txt not found");
    return 1;
  }
  mpz_inp_str(key, fp, 10);
  printf("key:\t");
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
  mpz_out_str(fp, 16, t);
  fclose(fp);

  // Free memory
  mpz_clear(encryptedKey);
  mpz_clear(key);
  mpz_clear(powMod);
  mpz_clear(base);
  mpz_clear(e);
  mpz_clear(two);
  mpz_clear(t);
  mpz_clear(n);
  mpz_clear(fiN);

  mpf_clear(ratio);

  return 0;
}
