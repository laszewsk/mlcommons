# Measure CPU->GPU bandwidth
# python cpu_gpu_v1.py
#
import torch
import time

def measure_bandwidth(length):
    mega = 1024 * 1024
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    # Generate array on CPU
    data = torch.rand(length*mega, dtype=torch.float32, device='cpu')
 
    # Warm-up to ensure CUDA context is initialized
    torch.cuda.synchronize()
    # Transfer data from CPU to GPU
    start_time = time.time()
    data_copy = data.to(device)
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
            print(f"{item*4} MByte: (CPU -> GPU): {bandwidth:.2f} MB/s")
        else:
            print("Bandwidth measurement failed.")
