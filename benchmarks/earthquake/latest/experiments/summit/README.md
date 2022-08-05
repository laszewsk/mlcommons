
# Getting Started


0. Checkout code from https://github.com/<ORG>/mlcommons.git
1. Navigate to summit code
2. Run `python3 environmenttest.py`
   1. If you do not have a clean output, you must reconfigure your environment.
   2. If not, run module load python/3.9.13-77x6elg (or related).
3. Run the following sequence of code to setup cloudmesh
   ```bash
   python3 -m venv ~/ENV3
   source ~/ENV3/bin/activate
   pip install cloudmesh-installer -U
   mkdir ~/cm
   (cd ~/cm && cloudmesh-installer get cc)
   (cd ~/cm && cloudmesh-installer get sbatch)
   ```
4. Verify that cloudmesh functions by running help and enable dbugging
   ```bash
   cms help
   cms debug on
   ```
5. Run `make`
6. 