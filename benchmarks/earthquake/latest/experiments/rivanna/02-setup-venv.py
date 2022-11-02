import os
import platform
import subprocess
import sys
import venv
import yaml

import cloudmesh.common as cloudmesh

import eq_lib


def main(argv, ext="yaml"):
    filename = eq_lib.get_config(argv, ext)
    content = cloudmesh.readfile(filename)
    config = yaml.safe_load(content)
    run_config = config["run"]

    venv_path = eq_lib.expand_string(run_config['venvpath'], config)

    if platform.system() == "Windows":
        bin_path = "Scripts"
    else:
        bin_path = "bin"
    if not os.path.exists(venv_path):
        print(f"Creating venv in {venv_path}")
        venv.create(venv_path,
                    prompt="mlcommons-eq",
                    with_pip=True,
                    upgrade_deps=True)

        print("Installing requirements...")
        subprocess.check_call([f"{venv_path}/{bin_path}/python", "-m", "pip", "install", "-U", "-r", "../../requirements.txt"])
        # subprocess.check_call(
        #     [f"{venv_path}/{bin_path}/python", "-m", "pip", "install",
        #      "cloudmesh-installer", "-U"])
        # try:
        #     os.system(f'{venv_path}/{bin_path}/python -m pip install cloudmesh-installer -U')
        # except Exception as e:
        #     print(e)
        # # subprocess.check_call(
        # #     [f"cd", "~/cm", ";", f"{venv_path}/{bin_path}/python", "cloudmesh-installer", "get", "sbatch"]
        # # )
        # try:
        #     os.system(f"cd ~/cm ; {venv_path}/{bin_path}/python cloudmesh-installer get sbatch")
        # except Exception as e:
        #     print(e)

    else:
        print(f"Reusing venv in {venv_path}")
        print("Updating requirements...")
        subprocess.check_call([f"{venv_path}/{bin_path}/python", "-m", "pip", "install", "-U", "-r", "../../requirements.txt"])
        # try:
        #     os.system(f'{venv_path}/{bin_path}/python -m pip install cloudmesh-installer -U')
        # except Exception as e:
        #     print(e)
        # # subprocess.check_call(
        # #     [f"cd", "~/cm", ";", f"{venv_path}/{bin_path}/python", "cloudmesh-installer", "get", "sbatch"]
        # # )
        # try:
        #     os.system(f"cd ~/cm ; {venv_path}/{bin_path}/cloudmesh-installer get sbatch")
        # except Exception as e:
        #     print(e)

if __name__ == "__main__":
    main(sys.argv)
