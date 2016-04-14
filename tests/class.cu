#include <stdio.h>

#define N 250000

struct Strategy {
    double profitLoss;
    void (*backtest)(struct Strategy *);
};

__device__ void backtest(struct Strategy *self) {
    self->profitLoss++;
}

__global__ void runBacktest(struct Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i].backtest(&strategies[i]);
    }
}

__global__ void initializeStrategies(struct Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i].profitLoss = 10000 + i;
        strategies[i].backtest = backtest;
    }
}

int main() {
    int threadsPerBlock = 10;
    int blockCount = N / threadsPerBlock;

    struct Strategy strategies[N];
    struct Strategy *devStrategies;
    int i;

    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));
    cudaMemcpy(devStrategies, strategies, N * sizeof(Strategy), cudaMemcpyHostToDevice);

    initializeStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);
    runBacktest<<<blockCount, threadsPerBlock>>>(devStrategies);

    cudaDeviceSynchronize();
    cudaMemcpy(strategies, devStrategies, N * sizeof(Strategy), cudaMemcpyDeviceToHost);

    for (i=0; i<N; i++) {
        printf("%f\n", strategies[i].profitLoss);
    }

    cudaFree(devStrategies);

    return 0;
}
