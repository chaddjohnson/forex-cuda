#include <stdio.h>
#include <thrust/device_ptr.h>
#include <thrust/device_new.h>

#define N 512

using namespace thrust;

class Study {
    public:
        int data[N];

        __device__ __host__ Study() {
            calculate();
        }

        __device__ __host__ void calculate() {
            for (int i=0; i<N; i++) {
                data[i] = i*2;
            }
        }
};

__global__ void test(Study* s) {
    for (int i=0; i<N; i++)
        printf("%d\n", s->data[i]);
}

int main() {
    device_ptr<Study> s = device_new<Study>();
    test<<<1,1>>>(thrust::raw_pointer_cast(s));

    cudaDeviceSynchronize();
    printf("Done!\n");
}
