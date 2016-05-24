#include <stdio.h>
#include <stdlib.h>

#define N 200000

class Strategy {
    private:
        double profitLoss;

    public:
        __device__ __host__ Strategy(int initialProfitLoss) {
            this->profitLoss = initialProfitLoss;
        }
        __device__ __host__ void backtest() {
            int i = 0;
            int j = 0;

            for (i=0; i<50; i++) {
                j++;
            }

            this->profitLoss++;
        }
        __device__ __host__ double getProfitLoss() {
            return this->profitLoss;
        }
};

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
    double *data = (double*)malloc(1000 * sizeof(double));
    double *devData;
    int i = 0;

    cudaSetDevice(0);

    // Allocate memory for strategies on the GPU.
    cudaMalloc((void**)&devStrategies, N * sizeof(Strategy));
    cudaMalloc((void**)&devData, 1000 * sizeof(double));

    // Initialize strategies on host.
    for (i=0; i<N; i++) {
        strategies[i] = Strategy::Strategy(i);
    }

    // Copy strategies from host to GPU.
    cudaMemcpy(devStrategies, strategies, N * sizeof(Strategy), cudaMemcpyHostToDevice);

    for (i=0; i<363598; i++) {
        backtestStrategies<<<blockCount, threadsPerBlock>>>(devStrategies);
        printf("\r%i", i);
    }

    // Copy strategies from the GPU.
    cudaMemcpy(strategies, devStrategies, N * sizeof(Strategy), cudaMemcpyDeviceToHost);
    cudaMemcpy(data, devData, 1000 * sizeof(double), cudaMemcpyDeviceToHost);

    // Display results.
    for (i=0; i<1000; i++) {
        printf("%f\n", strategies[i].getProfitLoss());
    }

    // Free memory for the strategies on the GPU.
    cudaFree(devStrategies);

    return 0;
}