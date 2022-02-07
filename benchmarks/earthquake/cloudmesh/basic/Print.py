# # Print in Color

import sys
import subprocess
from datetime import datetime
from numpy import np
from numpy import nan as NaN

class Print:

    startbold = "\033[1m"
    resetfonts = "\033[0m"
    startred = "\033[31m"

    startpurple = "\033[35m"
    startyellowbkg = "\033[43m"

    @staticmethod
    def _to_string(*argv, wrap=False):
        line = []
        for msg in argv:
            line.append(str(msg))


        return " ".join(line)

    @staticmethod
    def get_free_gpu_memory():
      _output_to_list = lambda x: x.decode('ascii').split('\n')[:-1]

      ACCEPTABLE_AVAILABLE_MEMORY = 1024
      COMMAND = "nvidia-smi --query-gpu=memory.free --format=csv"
      memory_free_info = _output_to_list(subprocess.check_output(COMMAND.split()))[1:]
      memory_free_values = [int(x.split()[0]) for i, x in enumerate(memory_free_info)]
      print(memory_free_values)
      return memory_free_values

    @staticmethod
    def LOG(*argv, wrap=False):
        content = Print._to_string(*argv, wrap=wrap)
        free = str(Print.get_free_gpu_memory())
        sys.__stdout__.write(f"{content} {free}\n")

    @staticmethod
    def red(*argv, wrap=False):
        print(Print.startbold + Print.startred + Print._to_string(*argv, wrap=wrap) + Print.resetfonts)

    @staticmethod
    def purple(*argv, wrap=False):
        print(Print.startbold + Print.startpurple + Print._to_string(*argv, wrap=wrap) + Print.resetfonts)

    @staticmethod
    def bf(*argv, wrap=False):
        print(Print.startbold + Print._to_string(*argv, wrap=wrap) + Print.resetfonts)

    @staticmethod
    def wraptotext(textinput, size=None):
        if size is None:
            size = 120
        textlist = wrap(textinput, size)
        textresult = textlist[0]
        for itext in range(1, len(textlist)):
            textresult += "\n" + textlist[itext]
        return textresult

    @staticmethod
    def timenow():
        now = datetime.now()
        return now.strftime("%m/%d/%Y, %H:%M:%S") + " UTC"

    @staticmethod
    def float32fromstrwithNaN(instr):
        if instr == "NaN":
            return NaN
        return np.float32(instr)

    @staticmethod
    def exit(*argv):
        print(Print._to_string(*argv))
        sys.exit()

    @staticmethod
    def strrnd(value):
        return str(round(value, 4))



#TESTING = False
#if TESTING:
#    import sys

#    printexit("a", 1, 3)

