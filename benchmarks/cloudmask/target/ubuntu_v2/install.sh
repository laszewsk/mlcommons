#! /bin/sh
#
# Using python3
#
#   curl -Ls https://raw.githubusercontent.com/laszewsk/mlcommons/main/benchmarks/cloudmask/experiments/rivanna/install.sh | sh -

##
# <pre>
#! /bin/sh

if [-d mlcommons ]; then
  echo "mlcommons dire exists. skipping"
else
  git clone git@github.com:laszewsk/mlcommons.git
fi

echo "Now execute the command"
echo
echo "    cd mlcommons/benchmarks/cloudmask/"
echo
exit 0

# </pre>
