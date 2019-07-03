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
    ./bootstrap >/dev/null 2>&1
    ./configure >/dev/null 2>&1

    make -j"$(nproc)" >/dev/null 2>&1
    make install >/dev/null 2>&1

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
    git clone https://github.com/RaphielGang/aarch64-raph-linux-android.git -b config >/dev/null 2>&1
    cd config || exit
    ct-ng build >/dev/null 2>&1
}

# Push the peck
push_gcc() {
    chmod -R 777 "$HOME"/x-tools
    cd "$HOME"/x-tools/aarch64-raphiel-elf || exit
    git init
    git add .
    git checkout -b "$BRANCHNAME"
    git commit -m "[Rollups]: GCC-10 $(date +%d%m%y)" --signoff
    git remote add origin https://raphielscape:"$GITHUB_TOKEN"@github.com/RaphielGang/aarch64-raph-linux-android.git
    git push --force origin "$BRANCHNAME"
}

build_env
build_conf
run
push_gcc
