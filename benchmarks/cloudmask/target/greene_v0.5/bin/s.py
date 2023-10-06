import subprocess
import time
from collections import Counter

def get_squeue_output():
    try:
        result = subprocess.run(['squeue', '--format=%T'], capture_output=True, text=True, check=True)
        return result.stdout.strip().split('\n')[1:]
    except subprocess.CalledProcessError:
        print("Error running 'squeue'. Make sure it's installed and accessible.")
        return []

def main():
    previous_input = None

    while True:
        user_input = input("Enter 'a' to show all jobs, 's' to show distribution by type, or press Enter to use the previous input: ")

        if user_input == 'a':
            squeue_output = get_squeue_output()
            print("\nAll Jobs:")
            for job in squeue_output:
                print(job)
            previous_input = 'a'

        elif user_input == 's':
            squeue_output = get_squeue_output()
            job_types = [job.split()[0] for job in squeue_output]
            job_type_counts = Counter(job_types)

            print("\nJob Distribution by Type:")
            for job_type, count in job_type_counts.items():
                print(f"{job_type}: {count}")
            previous_input = 's'

        elif user_input == '':
            if previous_input == 'a':
                squeue_output = get_squeue_output()
                print("\nAll Jobs:")
                for job in squeue_output:
                    print(job)
            elif previous_input == 's':
                squeue_output = get_squeue_output()
                job_types = [job.split()[0] for job in squeue_output]
                job_type_counts = Counter(job_types)

                print("\nJob Distribution by Type:")
                for job_type, count in job_type_counts.items():
                    print(f"{job_type}: {count}")

        else:
            print("Invalid input. Enter 'a', 's', or press Enter.")

        time.sleep(1)

if __name__ == "__main__":
    main()
