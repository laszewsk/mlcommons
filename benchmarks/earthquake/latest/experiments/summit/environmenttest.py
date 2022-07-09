import os
import platform
import shutil
import sys

# Core tools for bootstrapping

git = shutil.which("git")
tar = shutil.which("tar")
xz = shutil.which("xz")

assert git is not None, "Git must be installed."
assert tar is not None, "Tar must be installed."
assert xz is not None,  "XZ-utils must be installed."

# Future extension - Supporting ROCm framework.
#assert shutil.which("rocm-smi") or \
assert shutil.which("nvidia-smi"), "NVidia libraries must exist"


# Validate python version

python_ver = sys.version_info 
common_ver = '.'.join(map(str, sys.version_info[:3]))

assert python_ver.major >= 3, "Python must be version 3 or newer"
assert python_ver.minor >= 7, "Python much be version 3.7 or newer"

print(f"Python Path: {shutil.which('python')}")
print(f"Python3 Path: {shutil.which('python3')}")
print(f"Python version: {common_ver}")
print(f"Git path: {git}")
print(f"Tar path: {tar}")
if platform.system().lower() == "windows":
    usr = "USERNAME"
else:
    usr = "USER"

print(f"Current User: {os.environ[usr]}")

