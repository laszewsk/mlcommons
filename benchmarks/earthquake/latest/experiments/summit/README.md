
# Getting Started


0. Checkout code from https://github.com/<ORG>/mlcommons.git
1. Navigate to summit code
2. Run `python3 environmenttest.py`
   1. If you do not have a clean output, you must reconfigure your environment.
   2. `module load python/3.8-anaconda`
   3. `conda create -n "ENV3" python=3.10`
      1. Type y to accept.
   4. `conda init bash`
   5. `conda activate ENV3`
   6. Note the latest version on summit (python/3.9.13) does not work.
3. Run the following sequence of code to setup cloudmesh
   ```bash
   python3 -m venv ~/ENV3
   source ~/ENV3/bin/activate
   pip install pip -U
   pip install cloudmesh-installer -U
   mkdir ~/cm
   (cd ~/cm && cloudmesh-installer get sbatch)
   ```
4. Verify that cloudmesh functions by running help and enable dbugging
   ```bash
   cms help
   cms debug on
   ```
5. Run `make`
6. Run `sh jobs-summit.sh`