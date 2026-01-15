#!/bin/bash

os_distro_raw=`awk -F '=' '/^ID=/ { print $2 }' /etc/os-release`
os_distro="${os_distro_raw%\"}"
os_distro="${os_distro#\"}"

function usage() {
    echo "Usage: $0 [-h] [<dir>]"
    echo ""
    echo "  -h:    display this help and exit"
    echo "  <dir>: directory to store python environment config"
    echo "       default: ~/.venv/default"
}

DEFAULT_ENV_DIR="$HOME/.venv/default"
while getopts ":h" opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# check excuted as script or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script must be sourced. Use 'source $0' or '. $0'" >&2
    exit 1
fi

if [ -n "$1" ]; then
    DEFAULT_ENV_DIR="$1"
fi

if [ $os_distro == "centos" ]; then
    /opt/rh/rh-python38/root/usr/bin/python -m venv "$DEFAULT_ENV_DIR"
    . "$DEFAULT_ENV_DIR/bin/activate"
else
    python3 -m venv "$DEFAULT_ENV_DIR"
    . "$DEFAULT_ENV_DIR/bin/activate"
fi