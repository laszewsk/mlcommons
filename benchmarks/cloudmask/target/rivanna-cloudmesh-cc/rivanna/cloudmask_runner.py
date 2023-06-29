import os
from pathlib import Path
from cloudmesh.common.Shell import Shell
from cloudmesh.common.StopWatch import progress

username = Shell.user()
path_of_mlcommons = Path(Shell.map_filename(
    f'/scratch/{username}/mlcommons/benchmarks/cloudmask/target/rivanna'
).path).as_posix()

os.chdir(path_of_mlcommons)
progress_amount = 1
progress(progress=progress_amount)
gpus = ['a100', 'v100', 'p100', 'rtx2080', 'k80']
epochs = [10, 30, 50]
for card in gpus:
    for epoch in epochs:
        Shell.run(f'cms set currentgpu={card}')
        Shell.run(f'cms set currentepoch={epoch}')
        Shell.run(
            f"sed -i '/epochs:/c\epochs: {epoch}' config.yaml")
        Shell.run(
            f"sed -i '/mlperf_logfile:/c\mlperf_logfile: ./mlperf_cloudmask_{card}_{epoch}.log' config.yaml")
        Shell.run(
            f"sed -i '/log_file:/c\log_file: ./cloudMask_Log_{card}_{epoch}.log' config.yaml")
        Shell.run(f'sbatch --wait --gres=gpu:{card}:2 rivanna.sh')
        progress_amount += 6
        progress(progress=progress_amount)
progress(progress=100)