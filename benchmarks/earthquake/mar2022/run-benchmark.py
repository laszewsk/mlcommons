
import click
#from cloudmesh.common import Shell
import subprocess
import os


class BenchmarkRunner(object):
    def __init__(self, account: str, slurm_script_path: str):
        self._allocation = account
        self._script_path = slurm_script_path
        self._configs = list()

    def register_config(self, card_name: str, timelimit: str,
                        num_gpus: int = 1, num_cpus: int = 1):
        # See https://slurm.schedmd.com/sbatch.html#SECTION_INPUT-ENVIRONMENT-VARIABLES
        newrun = {
            'SLURM_GRES': f'gpu:{card_name}:{num_gpus}',
            'SLURM_JOB_NAME': "mlcommons-science-earthquake-%u-%j",
            'SLURM_CPUS_ON_NODE': num_cpus,
            'SLURM_TIMELIMIT': timelimit,
        }
        self._configs.append(newrun)
        return newrun

    def default(self):
        self.default_rivanna_a100()
        return self

    def default_rivanna_a100(self):
        self.register_config(card_name="a100",
                             timelimit='05:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_v100(self):
        self.register_config(card_name="v100",
                             timelimit='06:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_p100(self):
        self.register_config(card_name="p100",
                             timelimit='06:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_k80(self):
        self.register_config(card_name="k80",
                             timelimit='12:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_rtx2080(self):
        self.register_config(card_name="rtx2080",
                         timelimit='06:00:00',
                         num_cpus=6,
                         num_gpus=1)
        return self

    def default_rivanna_rtx3090(self):
        self.register_config(card_name="rtx3090",
                         timelimit='06:00:00',
                         num_cpus=6,
                         num_gpus=1)
        return self

    def list_gpus(self):
        return ["a100", "p100", "v100", "k80", "rtx2080", "rtx3090"]

    def lookup_config(self, host, card_name):
        try:
            return getattr(self, f"default_{host}_{card_name}")()
        except AttributeError:
            print(f"System {host} does not have a default for card: {card_name}")

    def setup_prerun(self, configs=None):
        def slurm_setup(my_config):
            for env, val in my_config.items():
                os.environ[str(env)] = str(val)
            return my_config

        if configs is None:
            for config in self._configs:
                yield slurm_setup(config)
        else:
            for config in configs:
                yield slurm_setup(config)

    def run(self):
        for config in self.setup_prerun():
            print(f"Running {config = }")
            env = os.environ.copy()
            proc = subprocess.Popen(['sbatch', self._script_path], env=env, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            stdout, stderr = proc.communicate()
            print(f"Output {stdout=}")
            if stderr is not None or stderr != "":
                print(f"Output {stdout=}")
            #r = Shell.run(f"sbatch {self._script_path}")


@click.command()
@click.option("-a", "--account",
              type=str,
              default="ds6011-sp22-002", help="Specify which account to use for spawning jobs.")
@click.option("-g", "--gpu",
              type=click.Choice(['a100', 'v100', 'p100', 'rtx2080', 'rtx3090', 'k80']),
              multiple=True,
              default=list(["k80"]), help="Which gpu to run on.")
@click.argument("slurm_script", type=click.Path(exists=True, dir_okay=False, resolve_path=True))
def cli(account, gpu, slurm_script):
    runner = BenchmarkRunner(account=account, slurm_script_path=slurm_script)
    for card in gpu:
        runner.lookup_config(host="rivanna", card_name=card)
    runner.run()


def main():
    cli(prog_name="run-batch")


if __name__ == '__main__':
    main()
