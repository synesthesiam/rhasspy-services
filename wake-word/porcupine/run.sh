#!/usr/bin/env bash
set -e
this_dir="$( cd "$( dirname "$0" )" && pwd )"
install_dir="${this_dir}"

# -----------------------------------------------------------------------------

# Load virtual environment
venv="${install_dir}/.venv"
if [[ ! -d "${venv}" ]]; then
    echo "No virtual environment found at ${venv}. Please run install.sh."
    exit 1
fi

source "${venv}/bin/activate"

# -----------------------------------------------------------------------------

# Sample pipelines:
# autoaudiosrc ! audioconvert ! audioresample ! audio/x-raw, rate=16000, channels=1, format=S16LE ! filesink location=/dev/stdout
#
# filesrc location=test.wav ! wavparse ! audioconvert ! audioresample ! audio/x-raw, rate=16000, channels=1, format=S16LE ! filesink location=/dev/stdout

python3 "${this_dir}/main.py" "$@"