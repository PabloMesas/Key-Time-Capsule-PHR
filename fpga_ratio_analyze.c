#include <stdio.h>
#include "math.h"

/*
--------------------------------------------------------------------
  Return ratio square mod n calculated per seconds

           1million usec * squares calculated
  ratio = ------------------------------------
              seconds * 1million + usec

--------------------------------------------------------------------
*/
void getRatioSquare (double time_res, mpz_t squares, mpf_t ratio) {
  mpf_t t;
  mpf_init(t);

  mpf_set_z (t, squares);
  mpf_div_ui(ratio, t, (unsigned long)time_res);

  // Free memory
  mpf_clear(t);
}

int main (int argc, char *argv[]) {
  double time_result;
  FILE *fp;
  mpz_t n, fiN, base, t, Ck, k;
  mpz_init(n);
  mpz_init(fiN);
  mpz_init(base);
  mpz_init(t);
  mpz_init(Ck);
  mpz_init(k);

  // Rational number
  mpf_t ratio;
  mpf_init(ratio);

   // Read the ratio square per seconds stored in file.
  fp = fopen("test_result.txt", "r");
  if (!fp) {
    printf("test_resul.txt not found");
    return 1;
  }
  mpz_inp_str(k, fp, 16);
  fscanf(fp, "%lf", &time_result);
  fclose(fp);

  printf("\n%lf\n", time_result);

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
  getRatioSquare(time_result, t, ratio);

  // Store the results in a file.
  fp = fopen("average_square_per_seconds.txt", "w");
  mpz_out_str(fp, 16, n);
  fputc('\n', fp);
  mpz_out_str(fp, 16, fiN);
  fputc('\n', fp);
  mpf_out_str(fp, 10, 10, ratio);
  fclose(fp);

  // Free memory
  mpz_clear(n);
  mpz_clear(base);
  mpz_clear(t);
  mpz_clear(Ck);
  mpz_clear(k);
  mpf_clear(ratio);
}