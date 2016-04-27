#include <stdio.h>
#include <stdlib.h>

#define N 250000

struct Strategy {
    double profitLoss;
    void (*backtest)(struct Strategy *, struct Tick *);
};

struct Tick {
    long timestamp;
    double open;
    double high;
    double low;
    double close;
    double rsi2;
    double rsi5;
    double rsi7;
    double rsi9;
    double rsi14;
    double stochastic5K;
    double stochastic5D;
    double stochastic10K;
    double stochastic10D;
    double stochastic14K;
    double stochastic14D;
};

__device__ void backtest(struct Strategy *self, struct Tick *tick) {
    int i;
    int j = 0;

    // Pretend to do something.
    // TODO: Actually do something useful.
    for (i=0; i<50; i++) {
        j++;
    }
}

__global__ void initializeStrategies(struct Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i].profitLoss = 10000 + i;
        strategies[i].backtest = backtest;
    }
}

__global__ void backtestStrategies(struct Strategy *strategies, struct Tick *tick) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i].backtest(&strategies[i], tick);
    }
}

int main() {
    int threadsPerBlock = 1000;
    int blockCount = N / threadsPerBlock;

    struct Strategy strategies[N];
    struct Strategy *devStrategies;
    int i;
    int j;

    int tickCount = 1000000;
    struct Tick *ticks = (Tick*) malloc(tickCount * sizeof(Tick));
    struct Tick *devTicks;
    int kFoldCount = 10;

    void (*backtester)(struct Strategy*, struct Tick*);

    backtester = &backtestStrategies;

    for (i=0; i<tickCount; i++) {
        ticks[i].timestamp = 1460611103;
        ticks[i].open = 89.5;
        ticks[i].high = 89.9;
        ticks[i].low = 89.2;
        ticks[i].close = 89.4;
        ticks[i].rsi2 = 89.7;
        ticks[i].rsi5 = 89.75;
        ticks[i].rsi7 = 89.72;
        ticks[i].rsi9 = 89.76;
        ticks[i].rsi14 = 89.9;
        ticks[i].stochastic5K = 89.2;
        ticks[i].stochastic5D = 89.4;
        ticks[i].stochastic10K = 89.7;
        ticks[i].stochastic10D = 89.75;
        ticks[i].stochastic14K = 89.72;
        ticks[i].stochastic14D = 89.76;
    }

    cudaSetDevice(0);

    // Allocate memory on the GPU for the strategies.
    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));
    
    // Copy tick data to the GPU.
    cudaMalloc((void**)&devTicks, N * sizeof(Tick));
    cudaMemcpy(devTicks, ticks, N * sizeof(Tick), cudaMemcpyHostToDevice);

    // Initialize strategies on the GPU.
    initializeStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);

    for (i=0; i<kFoldCount; i++) {
        for (j=0; j<tickCount; j++) {
            // Run backtests for all strategies.
            (*backtester)<<<blockCount, threadsPerBlock>>>(devStrategies, &devTicks[j]);
        }
    }

    // Free memory for the tick data from the GPU.
    cudaFree(devTicks);

    // TODO: Determine if this is necessary.
    //cudaDeviceSynchronize();

    // Copy strategies from the GPU.
    cudaMemcpy(strategies, devStrategies, N * sizeof(Strategy), cudaMemcpyDeviceToHost);

    // Display results.
    for (i=0; i<N; i++) {
        printf("%f\n", strategies[i].profitLoss);
    }

    // Free memory for the strategies on the GPU.
    cudaFree(devStrategies);

    return 0;
}
