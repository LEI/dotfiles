#!/bin/sh

# Resume last session by default
claude() { env claude "${@:---resume}"; }
