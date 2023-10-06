"""Job Queue Monitor

Usage:
  s.py
  s.py all
  s.py distribution
  s.py --start <char>
  s.py (-h | --help)

Options:
  -h --help     Show this help message and exit.

Description:
    This si a better squeue when you have many jobs that are submitted to SLURM.

    It is enhanced so that you can enter some charaters similar to the top command
    that customize the view

    t will open an input and as you for the time delay between calls
    a will show all jobs
    r will show only running jobs
    p will onliy show pending jobs
    s will show a summary of how many jobs are running and pending

    Once a car (other than t which is a one time action) is pressed that state is changed and
    consecutive itterations over time will show that view. Only if another char is pressed the
    view will be changed.

    current draft:
    https://github.com/laszewsk/mlcommons/blob/main/benchmarks/cloudmask/target/greene_v0.5/bin/s.py

"""

import subprocess
import time
from collections import Counter
from docopt import docopt

def get_squeue_output():
    try:
        result = subprocess.run(['squeue', '--format=%T'], capture_output=True, text=True, check=True)
        return result.stdout.strip().split('\n')[1:]
    except subprocess.CalledProcessError:
        print("Error running 'squeue'. Make sure it's installed and accessible.")
        return []

def main():
    previous_input = None
    args = docopt(__doc__)

    while True:
        if args['all']:
            squeue_output = get_squeue_output()
            print("\nAll Jobs:")
            for job in squeue_output:
                print(job)
            previous_input = 'a'

        elif args['distribution']:
            squeue_output = get_squeue_output()
            job_types = [job.split()[0] for job in squeue_output]
            job_type_counts = Counter(job_types)

            print("\nJob Distribution by Type:")
            for job_type, count in job_type_counts.items():
                print(f"{job_type}: {count}")
            previous_input = 's'

        else:
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

        time.sleep(1)

if __name__ == "__main__":
    main()
