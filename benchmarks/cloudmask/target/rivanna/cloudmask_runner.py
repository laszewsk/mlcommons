import os
from pathlib import Path
from cloudmesh.common.Shell import Shell
from cloudmesh.common.StopWatch import StopWatch

username = Shell.user()
path_of_mlcommons = Path(Shell.map_filename(
    f'/scratch/{username}/mlcommons/benchmarks/cloudmask/target/rivanna'
).path).as_posix()

os.chdir(path_of_mlcommons)
progress = 1
StopWatch.progress(progress)
gpus = ['a100', 'v100', 'p100']
epochs = [10, 30, 50]
for card in gpus:
    for epoch in epochs:
        Shell.run(f'cms set currentgpu={card}')
        Shell.run(f'cms set currentepoch={epoch}')
        Shell.run(
            f"sed -i '/epochs:/c\epochs: {epoch}/' cloudMaskConfig.yaml")
        Shell.run(f'sbatch --wait --gres=gpu:{card}:2 rivanna.sh')
        progress += 5
        StopWatch.progress(progress)
StopWatch.progress(100)