#!/bin/bash
set -e
source dev-container-features-test-lib
source ./smoke.sh
check "gcc not installed" bash -c '! command -v gcc'
reportResults
