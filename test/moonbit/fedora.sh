#!/bin/bash
# Default options against the base images in the test workflow.
set -e
source dev-container-features-test-lib
source ./smoke.sh
smoke_native
reportResults
