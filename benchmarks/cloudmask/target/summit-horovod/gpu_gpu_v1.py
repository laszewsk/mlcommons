'''
Measure GPU to GPU communication bandwidth.

python gpu_gpu_v1.py
'''
import torch
import time

def measure_bandwidth(length):
    mega = 1024 * 1024
    if torch.cuda.is_available():
    # Get the number of available GPUs
        num_gpus = torch.cuda.device_count()
        if num_gpus < 2:
            print("This example requires at least two GPUs.")
        else:
            # Initialize two tensors on different GPUs
            tensor_gpu0 = torch.rand(length*mega, dtype=torch.float32).cuda(0)
            tensor_gpu1 = torch.rand(length*mega, dtype=torch.float32).cuda(1)

            # Synchronize and copy data from GPU 1 to GPU 0

                # Warm-up to ensure CUDA context is initialized
            torch.cuda.synchronize()
            # Transfer data from CPU to GPU
            start_time = time.time()
            with torch.cuda.device(0):
                tensor_gpu0.copy_(tensor_gpu1)  # Copy data from GPU 1 to GPU 0
            torch.cuda.synchronize()
            end_time = time.time()

    transfer_time = end_time - start_time
    data_size_bytes = length*mega*4
    bandwidth = data_size_bytes / (transfer_time * 1024 * 1024)  # MB/s
    return bandwidth

# main
if __name__ == "__main__":
    sizes = []
    limit = 12
    for i in range(limit):
        sizes.append(2**i)

    for item in sizes:
        bandwidth = measure_bandwidth(item)

        if bandwidth is not None:
            print(f"{item*4} MByte: (GPU -> GPU): {bandwidth:.2f} MB/s")
        else:
            print("Bandwidth measurement failed.")

