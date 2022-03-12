
import click
#from cloudmesh.common import Shell

import subprocess
import os
import sys


class BenchmarkRunner(object):
    def __init__(self, account: str, slurm_script_path: str):
        """Runner for handling sbatch commands

        Args:
            account(str): The Account name to use for the sbatch allocation
            slurm_script_path(str): A string representing the path to the slurm script to be run.
        """
        self._allocation = account
        self._script_path = slurm_script_path
        self._configs = list()

    def register_config(self, card_name: str, timelimit: str,
                        num_gpus: int = 1, num_cpus: int = 1):
        """Add an environment configuration to the runner

        This command appends a slurm configuration into the runner object.  This
        updates the underlying self._configs to include a run with the specified
        parameters, to be later used with self.run().

        Args:
            card_name(str): The name of the card to be used in GRES configuration
            timelimit(str): The maximum amount of time for the batch job.
            num_gpus(int): The total number of GPUs to request for the job
            num_cpus(int): The total number of CPUs to request for a single job task.

        Returns:
            dict[str,str]: The parameters to be used for the registered run.
        """
        # See https://slurm.schedmd.com/sbatch.html#SECTION_INPUT-ENVIRONMENT-VARIABLES
        newrun = {
            'SBATCH_GRES': f'gpu:{card_name}:{num_gpus}',
            'SBATCH_JOB_NAME': "mlcommons-science-earthquake-%u-%j",
            'SBATCH_CPUS_ON_NODE': num_cpus,
            'SBATCH_TIMELIMIT': timelimit,
        }
        self._configs.append(newrun)
        return newrun

    def default(self):
        """Fluent API to define a default runner.

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.default_rivanna_a100()
        return self

    def default_rivanna_a100(self):
        """Default settings for an a100 on rivanna

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.register_config(card_name="a100",
                             timelimit='05:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_v100(self):
        """Default settings for an v100 on rivanna"""
        self.register_config(card_name="v100",
                             timelimit='06:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_p100(self):
        """Default settings for an p100 on rivanna

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.register_config(card_name="p100",
                             timelimit='06:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_k80(self):
        """Default settings for an k80 on rivanna

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.register_config(card_name="k80",
                             timelimit='12:00:00',
                             num_cpus=6,
                             num_gpus=1)
        return self

    def default_rivanna_rtx2080(self):
        """Default settings for an rtx2080 on rivanna

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.register_config(card_name="rtx2080",
                         timelimit='06:00:00',
                         num_cpus=6,
                         num_gpus=1)
        return self

    def default_rivanna_rtx3090(self):
        """Default settings for an 3090 on rivanna

        returns:
            self: The current benchmark runner class (fluent)
        """
        self.register_config(card_name="rtx3090",
                         timelimit='06:00:00',
                         num_cpus=6,
                         num_gpus=1)
        return self

    def list_gpus(self):
        """Lists the valid values for GPUs.
        returns:
            list[str]: A list of strings for each card name.
        """
        return ["a100", "p100", "v100", "k80", "rtx2080", "rtx3090"]

    def lookup_config(self, host, card_name):
        """Utility method to lookup a specific default configuration.

        This method inspects the current running class for methods matching
        the pattern default_<hostname>_<card_name>, and if a method is found
        return the default configuration for that method.

        """
        try:
            return getattr(self, f"default_{host}_{card_name}")()
        except AttributeError:
            print(f"System {host} does not have a default for card: {card_name}")

    def setup_slurm_environ(self, configs=None):
        """Generator method for preparing environment variables for a sbatch run

        This method runs in one of two modes:
        1. When configs is none, then the previously configured register_config
           calls will be looped on and triggered, setting all the necessary environment
           variables.
        2. When configs is not none, it uses this passed value as environment
           variables in each slurm call.

        Arguments:
            configs(dict[str,any]): A configuration dictionary to be used instead
                of the configurations previously registered.  If not specified,
                the previously registered entries will be used instead.
        Yields:
            tuple[dict[str,any],dict[str,str]]: A tuple, where the first option
                contains all environment variables to be augmented for sbatch,
                and the second argument is a complete environment variable set
                with the first argument's augmentation

        """
        def slurm_setup(my_config):
            """Builds an augmented environment variable list based on the passed configuration

            Args:
                my_config(dict[str,any]): A key-value mapping to populate the new environment with.

            Returns:
                dict[str,str]: A dicationary prepared for used in a subprocess call.
            """
            my_env = os.environ.copy()
            for env, val in my_config.items():
                my_env[str(env)] = str(val)
            return my_env

        if configs is None:
            for config in self._configs:
                yield config, slurm_setup(config)
        else:
            for config in configs:
                yield config, slurm_setup(config)

    def run(self):
        """Runs the configured environments.

        Spawns sbatch commands based on the previously registered values from
        calls to self.register_config().

        Returns
            None: Output is printed to screen as provided by sbatch.
        """
        for config, env in self.setup_slurm_environ():
            print(f"Running {config = }")
            stdout, stderr = subprocess.Popen(['sbatch', self._script_path], env=env, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
            print(stdout)
            print(f"{stderr = }", file=sys.stderr)


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
    """CLI method register

    Provides CLI options and configuration for running the `BenchmarkRunner` class.

    Returns
        None: Outputs from the runner are echoed to standard out.
    """
    runner = BenchmarkRunner(account=account, slurm_script_path=slurm_script)
    for card in gpu:
        runner.lookup_config(host="rivanna", card_name=card)
    runner.run()


def main():
    """Driver used when running from command line"""
    cli(prog_name="run-batch")


if __name__ == '__main__':
    main()
