#ifndef MATH_PRANVI_H
#define MATH_PRANVI_H

#include <bsd/stdlib.h>
#include <gmp.h>

#define PRIME_LENGTH 16   // Bits. Must be multiple of 4.

void initialValue (int length, char * hexword);
char getHex(int num);
void randomSeed(int length, char * randomData);
void getRandomBase(mpz_t base, mpz_t n);
void getModulus(mpz_t n, mpz_t fiN);

#endif