#!/usr/bin/env bash
set -e
this_dir="$( cd "$( dirname "$0" )" && pwd )"

if [[ ! -z "$1" ]]; then
    this_dir="$1"
fi

install_dir="${this_dir}"
download_dir="${install_dir}/download"
mkdir -p "${download_dir}"

# -----------------------------------------------------------------------------
# Debian dependencies
# -----------------------------------------------------------------------------

function install {
    sudo apt-get install -y "$@"
}

function python_module {
    python3 -c "import $1" 2>/dev/null
    if [[ "$?" -eq "0" ]]; then
        echo "$1"
    fi
}

export -f python_module

# python 3
if [[ -z "$(which python3)" ]]; then
    echo "Installing python 3"
    install python3
fi

# pip
if [[ -z "$(python_module pip)" ]]; then
    echo "Installing python pip"
    install python3-pip
fi

# venv
if [[ -z "$(python_module venv)" ]]; then
    echo "Installing python venv"
    install python3-venv
fi

# python3-dev
if [[ -z "$(python_module distutils.sysconfig)" ]]; then
    echo "Installing python dev"
    install python3-dev
fi

# mosquitto-clients
if [[ -z "$(which mosquitto_sub)" ]]; then
    echo "Installing mosquitto-clients"
    install mosquitto-clients
fi

# Set up fresh virtual environment
venv="${install_dir}/.venv"
rm -rf "${venv}"

python3 -m venv "${venv}"
source "${venv}/bin/activate"
python3 -m pip install wheel

# -----------------------------------------------------------------------------
# openfst
# -----------------------------------------------------------------------------

openfst_dir="${this_dir}/openfst-1.6.9"
if [[ ! -d "${openfst_dir}/build" ]]; then
    tar -xf "${download_dir}/openfst-1.6.9.tar.gz" && \
        cd "${openfst_dir}" && \
        ./configure --prefix="${openfst_dir}/build" --enable-far --enable-static --enable-shared --enable-ngram-fsts && \
        make -j 4 && \
        make install
fi

cp -R "${openfst_dir}"/build/bin/* "${venv}/bin/"
cp -R "${openfst_dir}"/build/include/* "${venv}/include/"
cp -R "${openfst_dir}"/build/lib/*.so* "${venv}/lib/"

# -----------------------------------------------------------------------------
# jsgf2fst
# -----------------------------------------------------------------------------

jsgf2fst_file="${download_dir}/jsgf2fst-0.1.1.tar.gz"
if [[ ! -f "${jsgf2fst_file}" ]]; then
    jsgf2fst_url='https://github.com/synesthesiam/jsgf2fst/releases/download/v0.1.0/jsgf2fst-0.1.1.tar.gz'
    echo "Downloading jsgf2fst (${jsgf2fst_url})"
    curl -sSfL -o "${jsgf2fst_file}" "${jsgf2fst_url}"
fi

# -----------------------------------------------------------------------------

cd "${install_dir}" && \
    python3 -m pip install \
            --global-option=build_ext --global-option="-L${venv}/lib" \
            "${jsgf2fst_file}" && \
    python3 -m pip install \
            -r "${install_dir}/requirements.txt"

# -----------------------------------------------------------------------------

echo "OK"