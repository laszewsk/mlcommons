help([[
Exposes a python instance running 3.8.5 for rivanna.


]])

local workspace = "/project/bii_dsc/mlcommons-system"

local name = myModuleName()
local version = myModuleVersion()
local base = pathJoin(workspace, "python/base")
prepend_path("PATH", pathJoin(base, 'versions', version, 'bin'))
setenv("LD_LIBRARY_PATH", pathJoin(base, 'ssl/lib'))
setenv("REQUESTS_CA_BUNDLE", "/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt")
setenv("SSL_CERT_FILE", "/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt")
set_alias("python", "python3.8")

whatis("Name: ".. name)
whatis("Version: ".. version)
whatis("Description: ".. "Portable Python 3.8.5 for Rivanna")
