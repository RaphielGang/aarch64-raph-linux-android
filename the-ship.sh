#!/usr/bin/env bash
#
# Copyright (C) 2019 Raphielscape LLC.
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for building and pushing GCC Under CI

# Environment dependencies
build_env() {
    cd crosstool-ng || exit
    ./bootstrap
    ./configure

    make -j"$(nproc)"
    make install

    cd ..
    rm -rf crosstool-ng
}

# Build Configs
build_conf() {
    mkdir repo
    cd repo || exit
    git config --global user.email "rapherion@raphielgang.org"
    git config --global user.name "Raphiel Rollerscaperers"
}

run() {
    git clone https://github.com/RaphielGang/aarch64-raph-linux-android.git -b config config
    cd config || exit
    ct-ng defconfig
    ct-ng build
}

# Push the peck
push_gcc() {
    chmod -R 777 "$HOME"/x-tools
    cd "$HOME"/x-tools/aarch64-raphiel-elf || exit
    git init
    git checkout -b elf
    git add .
    git commit -m "[Rollups]: GCC-10 $(date +%d%m%y)" --signoff

    # GCC doesn't like quoted token
    # shellcheck disable=2086
    git remote add origin https://raphielscape:$GITHUB_TOKEN@github.com/RaphielGang/aarch64-raph-linux-android.git

    git push --force origin elf
}

build_env
build_conf
run
push_gcc
