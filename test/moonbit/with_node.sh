#!/bin/bash
set -e
source dev-container-features-test-lib
source ./smoke.sh
smoke_native
# Running the js output spawns node; building it does not.
check "js run" moon -C "$project" run --target js cmd/main
reportResults
