user = os.environm["USER"]

for v in range (10)
    jobname = f"hallo-{user}-{v}"
    os.system (f"sbatch --jobname={jobname}")


data = dotdict({
    "name": "abc",
    "user": os.enironm["user"]
})

slurm_script = \
"""
#SBATCH jobname=job-{user}
""".format(**data)

writefile(data.name, slurm_script)


util

readfile writefile
