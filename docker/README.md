# Building binaries

cmake -B build -DGGML_CUDA=OFF -DGGML_HIP=OFF -DGGML_VULKAN=OFF -DGGML_RPC=ON -DGGML_BLAS=OFF -DGGML_AVX2=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --target rpc-server --target llama-server --config=Release -j$(nproc)

# Building images
docker buildx build -t woodhouse:5000/woodhouse-llama:1.0.0 -f docker/Dockerfile.llama .