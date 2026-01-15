<H1> python3 cook book </H1>

- [Set Environment](#set-environment)


# Set Environment

```bash
cat << 'EOM' > py_env.sh
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

if [ -n "$1" ]; then
    DEFAULT_ENV_DIR="$1"
fi

if [ $os_distro == "centos" ]; then
    /opt/rh/rh-python38/root/usr/bin/python -m venv "$DEFAULT_ENV_DIR"
    . "$DEFAULT_ENV_DIR/bin/activate"
else
    python3.8 -m venv "$DEFAULT_ENV_DIR"
    . "$DEFAULT_ENV_DIR/bin/activate"
fi
EOM
chmod +x py_env.sh
```