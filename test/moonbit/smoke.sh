# Shared by the test scripts; source after dev-container-features-test-lib.
# Only exit codes are checked, so a change to the `moon new` template does
# not break the tests.

project="$(mktemp -d)/hello"
check "moon on PATH" moon version --all
check "MOON_HOME" test "$MOON_HOME" = /usr/local/moon
check "MOON_HOME writable" test -w "$MOON_HOME"
check "moon new" moon new "$project"
check "moon check" moon -C "$project" check
check "moon test" moon -C "$project" test
check "moon run" moon -C "$project" run cmd/main
check "wasm build" moon -C "$project" build --target wasm --release
check "js build" moon -C "$project" build --target js --release

smoke_native() {
    check "native run" moon -C "$project" run --target native cmd/main
    check "native build" moon -C "$project" build --target native --release
}
