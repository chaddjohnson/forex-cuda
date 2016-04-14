#include <stdio.h>

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

    struct Tick tick = {1460611103, 89.5, 89.9, 89.2, 89.4, 89.7, 89.75, 89.72, 89.76, 89.9, 89.2, 89.4, 89.7, 89.75, 89.72, 89.76};
    struct Tick *devTick;

    cudaSetDevice(0);

    // Allocate memory on the GPU for the strategies.
    // TODO: Allocate memory on all GPUs.
    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));
    
    // Initialize strategies on the GPU.
    initializeStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);

    for (i=0; i<1000000; i++) {
        // Copy tick data to the GPU.
        // TODO: Copy to all GPUs.
        cudaMalloc((void**)&devTick, sizeof(Tick));
        cudaMemcpy(devTick, &tick, sizeof(Tick), cudaMemcpyHostToDevice);

        // Run backtests for all strategies.
        // TODO: Run on all GPUs.
        backtestStrategies<<<blockCount, threadsPerBlock>>>(devStrategies, devTick);

        // Free memory for the tick from the GPU.
        cudaFree(devTick);
    }

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
