#include <stdio.h>
#include <stdlib.h>

#define N 200000

class Strategy {
    private:
        double profitLoss;

    public:
        __device__ Strategy() {
            this->profitLoss = 0;
        }
        __device__ void backtest() {
            int i = 0;
            int j = 0;

            for (i=0; i<50; i++) {
                j++;
            }

            this->profitLoss += 1.0;
        }
        __device__ __host__ double getProfitLoss() {
            return this->profitLoss;
        }
};

__global__ void initializeStrategies(Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i] = Strategy::Strategy();
    }
}

__global__ void backtestStrategies(Strategy *strategies) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        strategies[i].backtest();
    }
}

int main() {
    // int threadsPerBlock = 1000;
    // int blockCount = N / threadsPerBlock;
    int threadsPerBlock = 1024;
    int blockCount = 32;

    Strategy *devStrategies;
    Strategy *strategies = (Strategy*)malloc(N * sizeof(Strategy));
    int i = 0;

    cudaSetDevice(0);

    // Allocate memory for strategies on the GPU.
    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));

    // Initialize strategies on the GPU.
    initializeStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);

    for (i=0; i<3635988; i++) {
        backtestStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);
    }

    // Copy strategies from the GPU.
    cudaMemcpy(strategies, devStrategies, N * sizeof(Strategy), cudaMemcpyDeviceToHost);

    // Display results.
    for (i=0; i<1000; i++) {
        printf("%f\n", strategies[i].getProfitLoss());
    }

    // Free memory for the strategies on the GPU.
    cudaFree(devStrategies);

    return 0;
}