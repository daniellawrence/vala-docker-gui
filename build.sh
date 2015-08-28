#!/bin/bash
# -----------------------------------------
# Quickstart
# -----------------------------------------
if [ -f main ];then
    rm main
fi

valac --pkg gtk+-3.0 --pkg gee-0.8 --thread --pkg libsoup-2.4 --pkg json-glib-1.0  main.vala
./main
