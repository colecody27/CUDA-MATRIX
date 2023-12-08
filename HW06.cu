#include <cuda.h>
#include <cstdlib>
#include <iostream>
#define N 16

//Compute number of even values in a 16 x 16 array 
__global__ void countEvens(int da[N][N], int *dcount){
    //Find location of thread
    int x = threadIdx.x;
    int y = threadIdx.y;

    //Check if value is even  
    if(da[x][y] % 2 == 0){
        atomicAdd(dcount, 1);
    }         
}

//Compute matrix square
__global__ void computeSquare(int da[N][N], int dsquare[N][N]){
    //Find location of thread
    int row = threadIdx.x;
    int col = threadIdx.y;

    //Compute square
    for(int i = 0; i < N; i++){
            dsquare[row][col] += da[row][i] * da[i][col];
    }
}

int main(){
    /*EXERCISE 1*/
    //Create 2d array with random values
    int arr[N][N];
    for(int i = 0; i < N; i++){
        for(int j = 0; j <  N; j++){
            arr[i][j] = rand() % 30;
        }
    }

    //Print out array
    std::cout << "Random array: \n";
    for(int i = 0; i < N; i++){
        std::cout << "[";
        for(int j = 0; j < N; j++){
            if(j == N-1)
               std::cout << arr[i][j];    
            else
               std::cout << arr[i][j] <<  ", ";
        }
        std::cout << "]\n";
    }

    //Allocate memory on GPU and declare variables
    int *da;
    int *dCount; 
    int hCount;
    cudaMalloc((void **)&da, N*N*sizeof(int));
    cudaMalloc((void **)&dCount, sizeof(int));

    //Copy array from CPU TO GPU 
    cudaMemcpy(da, arr, N*N*sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(N, N);
    countEvens<<<1, threadsPerBlock>>>((int(*) [N])da, dCount); 

    //Move value from GPU to CPU
    cudaMemcpy(&hCount, dCount, sizeof(int), cudaMemcpyDeviceToHost);

    //Free device memory 
    cudaFree(da);
    cudaFree(dCount); 

    std::cout <<  "\nNumber of even values in array is: " << hCount << "\n\n"; 


    /*EXERCISE 2*/
    //Allocate memory on GPU and declare variables 
    int *dsquared;
    int squared[N][N];
    cudaMalloc((void **)&da, N*N*sizeof(int));
    cudaMalloc((void **)&dsquared, N*N*sizeof(int));

    //Copy array from CPU TO GPU 
    cudaMemcpy(da, arr, N*N*sizeof(int), cudaMemcpyHostToDevice);

    computeSquare<<<1, threadsPerBlock>>>((int(*) [N])da, (int(*) [N])dsquared); 

    //Move value from GPU to CPU
    cudaMemcpy(squared, dsquared, N*N*sizeof(int), cudaMemcpyDeviceToHost);

    //Free device memory 
    cudaFree(da);
    cudaFree(dsquared);

    std::cout << "Squared array is: \n";
    //Print out squared array
    for(int i = 0; i < N; i++){
        std::cout << "[";
        for(int j = 0; j < N; j++){
            if(j == N-1)
               std::cout << squared[i][j];    
            else
               std::cout << squared[i][j] <<  ", ";
        }
        std::cout << "]\n";
    }
    
    return 0; 
}