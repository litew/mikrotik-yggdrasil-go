#!/usr/bin/dumb-init /bin/bash

set -euxo pipefail

conf_file=/config/yggdrasil.conf

## [ -f "${conf_file}" ] || yggdrasil -genconf >${conf_file}

exec yggdrasil -useconffile ${conf_file}
