#include <cstdlib>
#include <cstdio>
#include <unistd.h>

int main() {
    int tickCount = 3740821;
    int i = 0;
    int j = 0;

    double **ticks = (double**) malloc(tickCount * sizeof(double*));

    // Loop through all ticks.
    for (i=0; i<tickCount; i++) {
        ticks[i] = (double*) malloc(281 * sizeof(double));

        for (j=0; j<281; j++) {
            ticks[i][j] = 89.595;
        }
    }

    printf("allocated\n");
    usleep(1000 * 1000 * 30);

    return 0;
}

