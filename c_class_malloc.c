#include <stdio.h>
#include <stdlib.h>

#define N 2

struct Strategy {
    double profitLoss;
    void (*backtest)(struct Strategy *);
};

void backtest(struct Strategy *self) {
    self->profitLoss++;
}

int main() {
    struct Strategy *strategies = malloc(N * sizeof(struct Strategy));
    int i;

    // Initialize strategies.
    for (i=0; i<N; i++) {
        strategies[i].profitLoss = 10000;
        strategies[i].backtest = backtest;
    }

    strategies[0].backtest(&strategies[0]);

    // Backtest.
    for (i=0; i<N; i++) {
        printf("%f\n", strategies[i].profitLoss);
    }

    return 0;
}
