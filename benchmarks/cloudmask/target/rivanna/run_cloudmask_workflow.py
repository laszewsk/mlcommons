# ##############################################################
# pytest -v -x --capture=no benchmarks/cloudmask/target/rivanna/run_cloudmask_workflow.py
# pytest -v  benchmarks/cloudmask/target/rivanna/run_cloudmask_workflow.py
# pytest -v --capture=no  benchmarks/cloudmask/target/rivanna/run_cloudmask_workflow.py::TestCloudmask::<METHODNAME>
# ##############################################################
import os.path
from pathlib import Path
import pytest

from cloudmesh.cc.workflow import Workflow
from cloudmesh.common.Benchmark import Benchmark
from cloudmesh.common.StopWatch import StopWatch
from cloudmesh.common.util import HEADING
from cloudmesh.common.util import banner
from cloudmesh.common.util import path_expand
from cloudmesh.common.Shell import Shell
from cloudmesh.common.variables import Variables
from pprint import pprint

"""
This is a python file to test the implementation of workflow in running the 
mnist files. 
"""

def create_dest():
    # os.chdir(os.path.dirname(os.path.abspath(__file__)))
    #
    # Shell.rmdir("dest")
    # Shell.mkdir("dest")
    expanded_path = Shell.map_filename('~/.cloudmesh/workflow').path
    os.chdir(expanded_path)

#location = Shell.map_filename("./tests/mnist").path
#os.chdir(location)
create_dest()

name = "run"
variables = Variables()

host = "rivanna.hpc.virginia.edu"
username = variables["username"]

def create_workflow(filename='cloudmask.yaml'):
    global w
    global username
    w = Workflow(filename=filename, load=False)

    localuser = Shell.sys_user()
    login = {
        "localhost": {"user": f"{localuser}", "host": "local"},
        "rivanna": {"user": f"{username}", "host": "rivanna.hpc.virginia.edu"}
    }

    create_dest()
    if os.path.isdir('./cloudmask'):
        Shell.rmdir('./cloudmask')
    Shell.mkdir('./cloudmask')
    os.chdir('./cloudmask')
    Shell.mkdir('./runtime')
    os.chdir('./runtime')

    # copy shell files
    shell_files = Path(f'{__file__}').as_posix()
    shell_files_dir = Path(os.path.dirname(shell_files)).as_posix()

    for script in ["vpn-activate.sh", "prepare.sh", "cloudmask_runner.py"]:
        Shell.copy(f"{shell_files_dir}/{script}", ".")
        assert os.path.isfile(f"./{script}")

    os.chdir('..')

    label = "{name}\\nprogress={progress}"

    w.add_job(name=f"vpn-activate.sh", label=label, kind='local',
              user=username, host=host)
    w.add_job(name=f"prepare.sh", label=label,  kind='ssh', user=username,
              host=host)
    w.add_job(name=f"cloudmask_runner.py", label=label, kind='ssh',
              user=username,
              host=host, script="cloudmask_runner.py", venv='MLBENCH')

    w.add_dependencies(f"vpn-activate.sh,prepare.sh,cloudmask_runner.py")
    w.graph.save_to_yaml("./cloudmask.yaml")
    Shell.copy("./cloudmask.yaml", "./runtime/cloudmask.yaml")
    g = str(w.graph)
    print(g)
    return w


class TestCloudmask:

    def test_cloudmask(self):
        HEADING()

        w = create_workflow()
        print(w)
        #w.load(filename=filename)
        w.display(name='cloudmask')
        w.run_topo(show=True)
        create_dest()
        Shell.rmdir('./cloudmask')