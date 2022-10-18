
import shutil
import sys
import yaml

import eq_lib

import cloudmesh.common as cloudmesh


def main(argv, ext="yaml"):
    filename = eq_lib.get_config(argv, ext)
    content = cloudmesh.readfile(filename)
    config = yaml.safe_load(content)
    data_config = config['data']
    run_config = config["run"]

    work_dir = run_config['workdir']
    shutil.copytree(data_config['destination'], run_config['workdir'])
    shutil.copy(run_config['script'], run_config['workdir'])


if __name__ == "__main__":
    main(sys.argv)
