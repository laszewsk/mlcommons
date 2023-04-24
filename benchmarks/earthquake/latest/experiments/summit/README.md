
# Getting Started


0. Checkout code from https://github.com/<ORG>/mlcommons.git
1. Navigate to summit code
2. Run the environment setup
   1. Recommended: Automated environment setup
      1. Run sh `environment_setup.sh`
         1. This will setup a python instance using conda, create an virtual environment with all the dependencies and download all the git repository code for use in future jobs.
   2. Manually setting up your environment
      1. Run `python3 environmenttest.py`
         1. If you do not have a clean output, you must reconfigure your environment.
         2. `module load python/3.8-anaconda`
         3. `conda create -n "ENV3" python=3.10`
            1. Type y to accept.
         4. `conda init bash`
         5. `conda activate ENV3`
         6. Note the latest version on summit (python/3.9.13) does not work.
      2. Run the following sequence of code to setup cloudmesh
         ```bash
         pip install pip -U
         pip install cloudmesh-installer -U
         mkdir ~/cm
         (cd ~/cm && cloudmesh-installer get sbatch)
         ```
3. Verify that cloudmesh functions by running help and enable debugging
   ```bash
   cms help
   cms debug on
   ```
4. Run `make`
5. Run `sh jobs-summit.sh`