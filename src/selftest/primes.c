
/* Generate the first 256 primes mode 256 */

#include <stdio.h>
#include <string.h>

#define COUNT 2000
unsigned char sieve[COUNT];

int main(void)
{
    int num = 0;
    int x, y;
    memset(sieve, 0, sizeof(sieve));
    for (x = 2; num < 256 && x < COUNT; ++x) {
        if (!(sieve[x])) {
            printf(" 0x%02x,", x & 0xFF);
            ++num;
        }
        for (y = x; y < COUNT; y += x) {
            sieve[y] = 1;
        }
    }
    printf("\n");
    return 0;
}
