#!/bin/bash

ARG="$1"

FLAGS="${@:2}"

THING="flixel haxeui-flixel haxeui-core hxWindowColorMode haxeui-theme-kenney hxcpp"
if [ "$EUID" -ne 0 ]; then
    echo "WARRNING, SCRIPT IS NOT on SUDO!!!"
fi

help_func() {
    echo "ARG is null!"
    echo "$(basename "$0") [ARG] [FLAG, OPTIONAL, MULTIPLE]"
    echo ""
    echo "arg list:"
    echo "--build"
    echo "--buildtest"
    echo "--dllib"
    exit 0
}

build_func() {
    echo "!!SIGNAL BUILD"
    if [ -z "$FLAGS" ]; then
        echo "lime test linux$FLAGS"
        haxelib run lime build linux
    else
        echo "lime test linux $FLAGS"
        haxelib run lime build linux $FLAGS
    fi
}

buildtest_func() {
    echo "!!SIGNAL BUILD TEST"
    if [ -z "$FLAGS" ]; then
        haxelib run lime test linux
    else
        echo "lime test linux $FLAGS"
        haxelib run lime test linux $FLAGS
    fi
    exit 0
}

dllib_func() {
    echo "!!SIGNAL DOWNLOAD LIB"
    for i in $THING; do
        haxelib run install "$i"
    done
    echo ""
    echo "you should download libgtk-3-dev libayatana-appindicator3-dev pkg-config using apt, or dnf"
    echo "for pacman gtk3 libayatana-appindicator pkgconf"
    echo "done, use $(basename "$0") --build or --buildtest!"
    exit 0
}

# Checking the first argument to route the script execution
case "$ARG" in
    "--build")     build_func ;;
    "--buildtest") buildtest_func ;;
    "--dllib")     dllib_func ;;
    *)             help_func ;;
esac
