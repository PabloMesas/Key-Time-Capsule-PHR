#include <stdio.h>
#include "math.h"

/*
--------------------------------------------------------------------
  Return ratio square mod n calculated per seconds

           squares calculated
  ratio = ---------------------
            seconds invested

--------------------------------------------------------------------
*/
void getRatioSquare (double time_inv_d, mpz_t squares, mpf_t ratio) {
  mpf_t t, time_inv_f;
  mpf_init(t);
  mpf_init(time_inv_f);

  mpf_set_d (time_inv_f, time_inv_d);
  mpf_set_z (t, squares);
  mpf_div(ratio, t, time_inv_f);

  // Free memory
  mpf_clear(t);
  mpf_clear(time_inv_f);
}

/*
--------------------------------------------------------------------
  Read the test_result file which must contain the key decrypted
  and the time invested in.
  With that time and the t component, obtained from the data used to
  set the test, it will calculate the ratio squares mod n per
  seconds the fpga do to finally store insithe the
  average_per_seconds file with the components n, fiN, base,
  and ratio.
--------------------------------------------------------------------
*/
int main (int argc, char *argv[]) {
  double time_inv;
  FILE *fp;
  mpz_t Ck, k, base, t, n, fiN;
  mpz_init(Ck);
  mpz_init(k);
  mpz_init(base);
  mpz_init(t);
  mpz_init(n);
  mpz_init(fiN);

  // Rational number
  mpf_t ratio;
  mpf_init(ratio);

  // Read the results from the test.
  fp = fopen("test_result.txt", "r");
  if (!fp) {
    printf("test_resul.txt not found");
    return 1;
  }
  mpz_inp_str(k, fp, 16);        // Key decrypted
  fscanf(fp, "%lf", &time_inv);  // Time invested
  fclose(fp);

  // Pick up the data used in the test
  fp = fopen("decrypt_test.txt", "r");
  if (!fp) {
    printf("decrypt_test.txt not found");
    return 1;
  }
  mpz_inp_str(Ck, fp, 16);
  mpz_inp_str(base, fp, 16);
  mpz_inp_str(n, fp, 16);
  mpz_inp_str(t, fp, 16);
  mpz_inp_str(fiN, fp, 16);
  fclose(fp);

  // Obtain performance
  getRatioSquare(time_inv, t, ratio);

  // Store the results in a file.
  fp = fopen("average_square_per_seconds.txt", "w");
  mpz_out_str(fp, 16, n);
  fputc('\n', fp);
  mpz_out_str(fp, 16, fiN);
  fputc('\n', fp);
  mpz_out_str(fp, 16, base);
  fputc('\n', fp);
  mpf_out_str(fp, 10, 0, ratio);  // remember float
  fclose(fp);

  // Free memory
  mpz_clear(Ck);
  mpz_clear(k);
  mpz_clear(base);
  mpz_clear(t);
  mpz_clear(n);
  mpz_clear(fiN);

  mpf_clear(ratio);

  return 0;
}