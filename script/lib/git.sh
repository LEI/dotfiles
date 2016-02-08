#!/usr/bin/env bash

# git.sh

git_submodule() {
    git pull && \
    git submodule init && \
    git submodule update && \
    git submodule status
}
