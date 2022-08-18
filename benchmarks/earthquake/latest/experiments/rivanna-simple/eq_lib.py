
import os
import glob
import sys
import yaml

import cloudmesh.common as cloudmesh

def get_config(argv, ext="yaml"):
    configs = glob.glob(f"*.{ext}")

    if len(argv) == 1:
        print(f"Please choose a yaml file as parameter or choose a number:", file=sys.stderr)
        for i in range(0, len(configs)):
            print(f"{i}) {configs[i]}", file=sys.stderr)
        print()
        sys.exit(0)
    try:
        i = int(argv[1])
        filename = configs[i]
    except (TypeError, KeyError, ValueError) as e:
        print("B")
        filename = sys.argv[1]
    print(f"Using config {filename}", file=sys.stderr)

    if not os.path.exists(filename):
        print(f"File {filename} not found", file=sys.stderr)
        sys.exit(1)

    return filename


def property_lookup(argv):
    def _decend(my_dict, path_array, depth=1):
        if isinstance(path_array, list) and len(path_array) > 1:
            key = path_array.pop(0)
            return _decend(my_dict[key], path_array, depth+1)
        else:
            return my_dict[path_array[0]]
    cfg_file = get_config(argv, "yaml")

    data_in = cloudmesh.readfile(cfg_file)
    data = yaml.safe_load(data_in)

    lookup_property = argv[2].split(".")
    value = _decend(data, lookup_property)
    print(value)
    return value


if __name__ == '__main__':
    property_lookup(sys.argv)
