#!/usr/bin/env bash
set -e
this_dir="$( cd "$( dirname "$0" )" && pwd )"

if [[ ! -z "$1" ]]; then
    this_dir="$1"
fi

# -----------------------------------------------------------------------------

# Load virtual environment
venv=".venv"
if [[ ! -d "${venv}" ]]; then
    venv="${this_dir}/.venv"
fi

if [[ -d "${venv}" ]]; then
    source "${venv}/bin/activate"
fi

# -----------------------------------------------------------------------------

# PyInstaller
if [[ -z "$(which pyinstaller)" ]]; then
    echo "Installing PyInstaller"
    python3 -m pip install pyinstaller
fi

cd "${this_dir}" && \
    python3 -m pip install --force-reinstall ini_jsgf/ jsgf_fst_arpa/ vocab_dict/ vocab_g2p/ && \
    pyinstaller rhasspy_training.spec --noconfirm && \
    python3 -m pip uninstall -y  ini_jsgf jsgf_fst_arpa vocab_dict vocab_g2p