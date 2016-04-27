#include <stdio.h>
#include <thrust/device_ptr.h>
#include <thrust/device_new.h>

#define N 1024000

__global__ void add(int *data) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < N) {
        data[i]++;
    }
}

int main() {
    int data[N];
    int *dev_data;
    int i;

    // Allocate memory on the GPU.
    cudaMalloc((void**)&dev_data, N * sizeof(int));

    // Initialize data.
    for (i=0; i<N; i++) {
        data[i] = 0;
    }

    // Copy data to the GPU.
    cudaMemcpy(dev_data, data, N * sizeof(int), cudaMemcpyHostToDevice);

    for (i=0; i<100; i++) {
        add<<<1000, 1024>>>(dev_data);
    }

    cudaDeviceSynchronize();

    // Copy data from the GPU.
    cudaMemcpy(data, dev_data, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Free memory allocated on the GPU.
    cudaFree(dev_data);

    // for (i=0; i<N; i++) {
    //     printf("%d\n", data[i]);
    // }

    return 0;
}
