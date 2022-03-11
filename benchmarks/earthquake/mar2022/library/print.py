#!/usr/bin/env python
# coding: utf-8

# # Print in Color

# In[ ]:
import subprocess

startbold = "\033[1m"
resetfonts = "\033[0m"
startred = "\033[31m"

startpurple = "\033[35m"
startyellowbkg = "\033[43m"


def _to_string(*argv, wrap=False):
    line = []
    for msg in argv:
        line.append(str(msg))

    
    return " ".join(line)


def get_free_gpu_memory():
  _output_to_list = lambda x: x.decode('ascii').split('\n')[:-1]

  ACCEPTABLE_AVAILABLE_MEMORY = 1024
  COMMAND = "nvidia-smi --query-gpu=memory.free --format=csv"
  memory_free_info = _output_to_list(subprocess.check_output(COMMAND.split()))[1:]
  memory_free_values = [int(x.split()[0]) for i, x in enumerate(memory_free_info)]
  print(memory_free_values)
  return memory_free_values


def printLOG(*argv, wrap=False):
    content = _to_string(*argv, wrap=wrap)
    free = str(get_free_gpu_memory())
    sys.__stdout__.write(f"{content} {free}\n")


def print_red(*argv, wrap=False):
    print(startbold + startred + _to_string(*argv, wrap=wrap) + resetfonts)


def print_purple(*argv, wrap=False):
    print(startbold + startpurple + _to_string(*argv, wrap=wrap) + resetfonts)


def print_bf(*argv, wrap=False):
    print(startbold + _to_string(*argv, wrap=wrap) + resetfonts)


def wraptotext(textinput, size=None):
    if size is None:
        size = 120
    textlist = wrap(textinput, size)
    textresult = textlist[0]
    for itext in range(1, len(textlist)):
        textresult += "\n" + textlist[itext]
    return textresult


def timenow():
    now = datetime.now()
    return now.strftime("%m/%d/%Y, %H:%M:%S") + " UTC"


def float32fromstrwithNaN(instr):
    if instr == "NaN":
        return NaN
    return np.float32(instr)


def printexit(*argv):
    print(_to_string(*argv))
    sys.exit()


def strrnd(value):
    return str(round(value, 4))


# In[ ]:


TESTING = False
if TESTING:
    import sys

    printexit("a", 1, 3)

