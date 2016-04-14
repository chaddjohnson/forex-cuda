#include <stdio.h>

#define N 2

struct Strategy {
    double profitLoss;
    void (*backtest)(struct Strategy *);
};

void backtest(struct Strategy *self) {
    self->profitLoss++;
}

int main() {
    struct Strategy strategies[N];
    int i;

    // Initialize strategies.
    for (i=0; i<N; i++) {
        strategies[i].profitLoss = 10000;
        strategies[i].backtest = backtest;
    }

    // Backtest.
    for (i=0; i<N; i++) {
        strategies[i].backtest(&strategies[i]);
        printf("%f\n", strategies[i].profitLoss);
    }

    return 0;
}
