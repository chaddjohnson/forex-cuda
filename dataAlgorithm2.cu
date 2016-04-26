#include <stdio.h>
#include <stdlib.h>

#define CONFIGURATION_COUNT 250000

struct Tick {
    long timestamp;
    double open;
    double high;
    double low;
    double close;
    double sma13;
    double ema50;
    double ema100;
    double ema200;
    double rsi;
    double stochK;
    double stochD;
    double prcUpper;
    double prcLower;
};

struct Strategy {
    double profitLoss;
    void (*backtest)(Strategy *, Tick *);
};

__device__ void backtest(Strategy *self, Tick *tick) {
    int i;
    int j = 0;

    // Pretend to do something.
    // TODO: Actually do something useful.
    for (i=0; i<50; i++) {
        j++;
    }
}

__global__ void initializeStrategies(Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < CONFIGURATION_COUNT) {
        strategies[i].profitLoss = 10000 + i;
        strategies[i].backtest = backtest;
    }
}

__global__ void backtestStrategies(Strategy *strategies, Tick *tick) {
    // TODO: Harness multiple dimensions?
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < CONFIGURATION_COUNT) {
        strategies[i].backtest(&strategies[i], tick);
    }
}

int main() {
    int threadsPerBlock = 1000;
    int blockCount = CONFIGURATION_COUNT / threadsPerBlock;

    Strategy strategies[CONFIGURATION_COUNT];
    Strategy *devStrategies;
    int i = 0;
    int j = 0;
    int k = 0;

    int tickCount = 1000000;
    Tick *ticks = (Tick*) malloc(CONFIGURATION_COUNT * sizeof(Tick));;
    Tick *devTicks;
    int kFoldCount = 10;

    void (*backtester)(Strategy*, Tick*);
    backtester = &backtestStrategies;

    cudaSetDevice(0);

    // Allocate memory on the GPU for the strategies.
    cudaMalloc((void**)&devStrategies, CONFIGURATION_COUNT * sizeof(Strategy));

    // Allocate memory on the GPU for the ticks.
    cudaMalloc((void**)&devTicks, CONFIGURATION_COUNT * sizeof(Tick));

    // Initialize strategies on the GPU.
    initializeStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);

    // Run through each k-fold step.
    for (i=0; i<kFoldCount; i++) {
        // Run through every tick.
        for (j=0; j<tickCount; j++) {
            printf("%i\n", j);

            if (j > 0) {
                // Wait for currently-running kernels to finish.
                cudaDeviceSynchronize();

                // Free currently-allocated GPU memory, and allocate more.
                cudaFree(devTicks);

                // Clear host memory for previous ticks.
                memset(ticks, 0, CONFIGURATION_COUNT * sizeof(Tick));
            }

            // Set up data for every configuration.
            for (k=0; k<CONFIGURATION_COUNT; k++) {
                ticks[k].timestamp = 1460611103;
                ticks[k].open = 89.5;
                ticks[k].high = 89.5;
                ticks[k].low = 89.5;
                ticks[k].close = 89.5;
                ticks[k].sma13 = 89.5;
                ticks[k].ema50 = 89.5;
                ticks[k].ema100 = 89.5;
                ticks[k].ema200 = 89.5;
                ticks[k].rsi = 89.5;
                ticks[k].stochK = 89.5;
                ticks[k].stochD = 89.5;
                ticks[k].prcUpper = 89.5;
                ticks[k].prcLower = 89.5;
            }

            // Copy ticks to the GPU.
            cudaMemcpy(devTicks, ticks, CONFIGURATION_COUNT * sizeof(Tick), cudaMemcpyHostToDevice);

            // Run backtests for all strategy configurations.
            (*backtester)<<<blockCount, threadsPerBlock>>>(devStrategies, devTicks);
        }
    }

    // Free memory for the tick data from the GPU.
    cudaFree(devTicks);

    // Copy strategies from the GPU.
    cudaMemcpy(strategies, devStrategies, CONFIGURATION_COUNT * sizeof(Strategy), cudaMemcpyDeviceToHost);

    // Display results.
    for (i=0; i<CONFIGURATION_COUNT; i++) {
        printf("%f\n", strategies[i].profitLoss);
    }

    // Free memory for the strategies on the GPU.
    cudaFree(devStrategies);

    return 0;
}
