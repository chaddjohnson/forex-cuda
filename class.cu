#include <stdio.h>
#include <stdlib.h>

#define N 200000

class Strategy {
    private:
        double profitLoss;

    public:
        __device__ __host__ Strategy() {
            this->profitLoss = 0;
        }
        __device__ __host__ void backtest() {
            this->profitLoss++;
        }
        __device__ __host__ double getProfitLoss() {
            return this->profitLoss;
        }
};

__global__ void backtestStrategies(Strategy *strategies) {
    // Reference: https://devblogs.nvidia.com/parallelforall/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/
    for (int i = blockIdx.x * blockDim.x + threadIdx.x;
         i < N;
         i += blockDim.x * gridDim.x)
    {
        strategies[i].backtest();
    }
}

int main() {
    int blockCount = 32;
    int threadsPerBlock = 1024;

    Strategy *devStrategies;
    Strategy *strategies = (Strategy*)malloc(N * sizeof(Strategy));
    int i = 0;

    // Allocate memory for strategies on the GPU.
    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));

    // Initialize strategies on host.
    for (i=0; i<N; i++) {
        strategies[i] = Strategy();
    }

    // Copy strategies from host to GPU.
    cudaMemcpy(devStrategies, strategies, N * sizeof(Strategy), cudaMemcpyHostToDevice);

    for (i=0; i<363598; i++) {
        backtestStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);
    }

    // Copy strategies from the GPU.
    cudaMemcpy(strategies, devStrategies, N * sizeof(Strategy), cudaMemcpyDeviceToHost);

    // Display results.
    for (i=0; i<N; i++) {
        printf("%f\n", strategies[i].getProfitLoss());
    }

    // Free memory for the strategies on the GPU.
    cudaFree(devStrategies);

    return 0;
}