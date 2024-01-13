#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define KRED "\x1B[31m"
#define KNRM "\x1B[0m"

int OUT_BUF_SIZE = 100;

extern void print(char *out_buf, const char *format, const char *hex_number);

int test(char *format, char *hex_number, char *expected) {
  char out_buf[OUT_BUF_SIZE];

  print(out_buf, format, hex_number);

  if (strcmp(expected, out_buf) != 0) {
    fprintf(stderr, "%s(%s, %s) Real: '%s' not equal to expected '%s' %s\n",
            KRED, format, hex_number, out_buf, expected, KNRM);
    return 1;
  }

  return 0;
}

char random_letter() {
  char res;
  if (random() % 2) {
    res = 'A' + (random() % 6);
  } else {
    res = 'a' + (random() % 6);
  }
  // printf("Next char:%c\n", res);
  return res;
}

char random_digit() {
  char res = '0' + (random() % 10);
  // printf("Next digit:%c\n", res);
  return res;
}

char random_flag() {
  char res = " -+0"[random() % 3];
  // printf("Next flag:%c\n", res);
  return res;
}

char *random_format() {
  // printf("FORMAT\n");
  char *format = malloc(32);
  int pos = 0;

  int flags_len = random() % 4;
  for (int i = 0; i < flags_len; i++) {
    format[pos++] = random_flag();
  }
  int width_len = random() % 2; // TODO: increase
  for (int i = 0; i < width_len; i++) {
    format[pos++] = random_digit();
  }
  format[pos] = 0;

  return format;
}

char *random_hex() {
  // printf("HEX\n");
  char *hex = malloc(16);
  int pos = 0;

  if (random() % 2) {
    hex[pos++] = '-';
  }

  if (random() % 2) {
    hex[pos++] = '0';
    hex[pos++] = 'x';
  }

  int len = random() % 7 + 1;
  for (int i = 0; i < len; i++) {
    if ((random() % 3) == 0) {
      hex[pos++] = random_letter();
    } else {
      hex[pos++] = random_digit();
    }
  }
  hex[pos] = 0;

  return hex;
}

int hex_to_dec(char *hex) {
  int res;
  sscanf(hex, "%x", &res);
  return res;
}

int test_random() {
  char *format = random_format();
  char *hex = random_hex();
  int dec = hex_to_dec(hex);
  // printf("R f:|%s| h:|%s| d:|%i|\n", format, hex, dec);
  fflush(stdout);

  char out_buf1[OUT_BUF_SIZE];
  char out_buf2[OUT_BUF_SIZE];

  char sformat[64] = "%";
  strcat(sformat, format);
  strcat(sformat, "i");

  sprintf(out_buf1, sformat, dec);
  print(out_buf2, format, hex);

  if (strcmp(out_buf1, out_buf2) != 0) {
    fprintf(stderr,
            "%sRandom: (%s, %s) Real: '%s' not equal to expected '%s' %s\n",
            KRED, format, hex, out_buf2, out_buf1, KNRM);
    free(format);
    free(hex);

    return 1;
  }
  free(format);
  free(hex);

  return 0;
}

void test_all() {
  int res =
      // Base
      test("", "0", "0") + test("", "1", "1") + test("", "11", "17") +
      test("", "1A", "26") + test("", "1a", "26") + test("", "001A", "26") +
      test("-4", "-10", "-16 ") +

      // // Sign
      test("", "1A", "26") + test("", "-1A", "-26") + test("+", "-1A", "-26") +
      test("+", "1A", "+26") + test("++", "1A", "+26") +
      test("++", "-1A", "-26") +

      // Right shist
      test("5", "1A", "   26") + test("5", "-1A", "  -26") +
      test("+5", "-1A", "  -26") + test("+5", "1A", "  +26") +

      // Right shist with zero
      test("05", "1A", "00026") + test("05", "-1A", "-0026") +
      test("+05", "-1A", "-0026") + test("+05", "1A", "+0026") +

      // Left shift combination ('-' in flags)
      test("+-7", "1A", "+26    ") + test("-+7", "-1A", "-26    ") +

      test("-5", "1A", "26   ") + test("- -5", "D2", " 210 ") +

      // space flag
      test(" 5", "5", "    5") + test("- 5", "5", " 5   ") +
      test("0 5", "5", " 0005") + test("0+ 5", "5", "+0005") +
      test("0+ 5", "5", "+0005") + test("0- 5", "5", " 5   ") +
      test(" ", "D5", " 213") + test(" 5", "c57c", " 50556") +

      // capital and low letter
      test(" ", "AbCdeF", " 11259375") + test(" ", "b3C45eF6", " 3015991030") +

      // empty things - UNDEFINED BEHAVIOUR
      test("", "1", "1") + test("", "", "0") + test("+3", "", " +0") +
      test("-3", "", "0  ") + test(" 3", "", "  0") + test("- ", "", " 0") +

      // "0x" prefixed
      test("3", "0x1A", " 26") + test("- ", "-0xA1", "-161") +
      test("3", "0X1A", " 26") + test("- ", "-0XA1", "-161") +
      test("- ", "0xA1", " 161") + test("- ", "0x0A1", " 161") +

      // max, min int32
      test("", "7FFFFFFF", "2147483647") +
      test("", "-80000000", "-2147483648") +

      test("", "80000000", "2147483648") + test("", "BB9ACA00", "3147483648") +
      test("", "FFFFFFFFFFFF", "281474976710655") +
      test("", "4FABE0ABFFF", "5474976710655") +
      test("", "7FFFFFFFFFFFFFFF", "9223372036854775807") +
      test("", "FFFFFFFFFFFFFFFF", "18446744073709551615") +
      test("", "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
           "170141183460469231731687303715884105727") +
      test("+", "34C4B357A5793B85F675DDBFFFFFFFFF",
           "+70141183460469231731687303715884105727") +
      test("", "-1B30E1CC814B96EFC85F5FFFFFFFFF",
           "-141183460469231731687303715884105727") +
      test("40", "-1B30E1CC814B96EFC85F5FFFFFFFFF",
           "   -141183460469231731687303715884105727") +
      test("+-3", "8Ee4fACF834B20a0b0DE134F630E7342",
           "-150343060792470555638386732992063179966") +
      // test("", "8Ee4fACF834B20a0b0DE134F630E7342"),
      //      "-150343060792470555638386732992063179966") +
      // test("", "8EE4FACF834B20A0B0DE134F63000000",
      //      "189939306128467907824987874439704084480") +
      //      //
      //      10001110111001001111101011001111100000110100101100100000101000001011000011011110000100110100111101100011000000000000000000000000

      // long with -
      test("", "-F00000000000000", "-1080863910568919040") +
      test("4", "10", "  16") +
      test("", "-80000000000000000000000000000000",
           "-170141183460469231731687303715884105728") +
      test("", "-80000000000000000000000000000001",
           "170141183460469231731687303715884105727") +

      // No -0
      test("+", "-0", "+0") + test("+3", "-0x0", " +0");

  // incorrect prefixes - NOT SUPPORTED
  // test("- ", "01xA1", "1") + test("- ", "-01xA1", "-1") +
  // test("- ", "00xA1", " 0");

  // random tests
  for (int i = 0; i < 10000; i++) {
    // res += test_random();
  }

  if (res == 0) {
    printf("PASSED\n");
  } else {
    printf("FAILED: %i\n", res);
  }
}

int main() {
  test_all();

  char out_buf[OUT_BUF_SIZE];
  const char *format = "";
  const char *hex_number = "-1A"; // -26 in decimal

  print(out_buf, format, hex_number);
  printf("Result: '%s'\n", out_buf);
}
