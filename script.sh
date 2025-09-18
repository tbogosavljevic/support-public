#!/bin/bash

[ "${PIPEFAIL_CHECK,,}" = "true" ] && { set -eo pipefail; echo "set -eo pipefail enabled"; } || echo "PIPEFAIL_CHECK is empty or not true"
