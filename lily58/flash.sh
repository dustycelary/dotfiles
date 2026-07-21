#!/bin/bash

# 1. Ensure target directory exists and clear old files
mkdir -p ~/qmk_firmware/keyboards/lily58/keymaps/lily58_custom
rm -rf ~/qmk_firmware/keyboards/lily58/keymaps/lily58_custom/*

# 2. Copy current directory files into the keymap folder
cp -r ./* ~/qmk_firmware/keyboards/lily58/keymaps/lily58_custom/

# 3. Flash matching the folder name (lily58_custom)
qmk flash -kb lily58/rev1 -km lily58_custom
