@echo off
echo Building WASM-4 Jam Entry
odin build src -out:build/cart.wasm -target:freestanding_wasm32 -no-entry-point -extra-linker-flags:"--import-memory -zstack-size=8192 --initial-memory=65536 --max-memory=65536 --global-base=6560 --lto-O3 --gc-sections --strip-all"
:w4 run build/cart.wasm
w4 run-native build/cart.wasm