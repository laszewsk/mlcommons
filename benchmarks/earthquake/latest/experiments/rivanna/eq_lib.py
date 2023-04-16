
import os
import glob
import string
import sys
import yaml

import cloudmesh.common as cloudmesh


class UnprefixTemplate(string.Template):
    """
    Required as the sbatch program prefers using {varname} instead of $varname or ${varname}.
    This rewrites the string.Template engine to support {varname}-style substitution.
    """
    delimiter = '{'
    pattern = r'''
    \{(?:
       (?P<escaped>\{) |                        # Escapes {{ as {
       (?P<named>[_a-zA-Z][_a-zA-Z0-9\.]*)\} |  # Allows any alphanumeric value
       {(?P<braced>[_a-zA-Z][_a-zA-Z0-9\.]*)\}\}
    )'''


def expand_string(my_str, my_dict = dict(), sep="."):
    shell_expanded = string.Template(my_str).safe_substitute(**os.environ)
    inner_dict = cloudmesh.FlatDict(my_dict, sep=sep)
    cloudmesh_expansion = UnprefixTemplate(shell_expanded).safe_substitute(**os.environ, **inner_dict)
    return cloudmesh_expansion


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


def load_yaml(filepath):
    content = cloudmesh.readfile(filepath)
    config = yaml.safe_load(content)
    return config


def _property_lookup(key, my_dict, delim="."):
    def _decend(my_dict, path_array, depth=1):
        if isinstance(path_array, list) and len(path_array) > 1:
            key = path_array.pop(0)
            return _decend(my_dict[key], path_array, depth+1)
        else:
            return my_dict[path_array[0]]
    lookup_property = key.split(delim)
    value = _decend(my_dict, lookup_property)
    return value


def property_lookup(argv):
    cfg_file = get_config(argv, "yaml")

    data = load_yaml(cfg_file)
    value = _property_lookup(argv[2], data, delim=".")
    print(value)
    return value


if __name__ == '__main__':
    property_lookup(sys.argv)
