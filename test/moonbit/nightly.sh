#!/bin/bash
set -e
source dev-container-features-test-lib
source ./smoke.sh
smoke_native
reportResults
