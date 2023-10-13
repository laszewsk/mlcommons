'''
Measuring disk read bandwidth.
Generating files up to 32GBytes and measuring file read time.

python disk_io_v1.py

'''

import os
import time
# Create a binary file
def create_file_with_bytes(filename, num_bytes):
    with open(filename, 'wb') as f:
        f.write(b'\0' * num_bytes)


def measure_bandwidth(file_path, giga):
    try:
        # Open the file for reading
        with open(file_path, 'rb') as file:
            file_size = os.path.getsize(file_path)  # Get the file size in bytes
            start_time = time.time()  # Record the start time

            # Read the entire file
            while file.read(file_size):
                pass

            end_time = time.time()  # Record the end time

        elapsed_time = end_time - start_time
        bandwidth = file_size / (elapsed_time *giga)  # Calculate bandwidth in MB/s

        return bandwidth

    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    filename = "output_file.bin"
    giga = 1024*1024*1024
    num_bytes = [giga, 2*giga, 4*giga, 8*giga, 16*giga, 32*giga]
    for item in num_bytes:
        create_file_with_bytes(filename, item)

        bandwidth = measure_bandwidth(filename, giga)

        if bandwidth is not None:
            print(f"{item/giga} GBytes: {bandwidth:.4f} GBytes/s")
        else:
            print("Bandwidth measurement failed.")

