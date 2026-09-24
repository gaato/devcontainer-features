#!/bin/bash
set -e
source dev-container-features-test-lib
source ./smoke.sh
check "pinned moonc" bash -c 'moon version --all | grep -F "moonc v0.10.14+7d59c7ec9"'
reportResults
