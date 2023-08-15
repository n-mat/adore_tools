#!/usr/bin/env bash


set -euo pipefail

trap 'get_help' EXIT


exiterr (){ printf "$@\n"; exit 1;}

CLONE_DIR="${HOME}"
SUPPORTED_UBUNTU_VERSIONS="20.04 20.10 22.04"
REQUIRED_FREESPACE_GB="20"
ADORE_REPO="https://github.com/eclipse/adore.git"

ADORE_HELP_LINK="https://github.com/eclipse/adore/issues"
ADORE_DOCS_LINK="https://eclipse.github.io/adore/"

HEADLESS=0

get_help(){
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
      echo "ERROR: ADORe setup failed." >&2
    fi
    printf "\n\n"
    printf "Having trouble? Reach out to the ADORe team, we are here to help!\n"
    printf "  https://github.com/eclipse/adore/issues \n"
    printf "\n\n"
    exit $exit_status
}

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help         Print this help and exit
-H, --headless     Run ADORe installation in headless mode 
-v, --verbose      Print script debug info
EOF
  exit
}

function parse_params() {

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -H | --headless) HEADLESS=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")


  return 0
}


prompt_yes_no() {
    while true; do
        read -rp "Do you want to proceed? (yes/no): " choice
        case $choice in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please enter 'yes' or 'no'."
                ;;
        esac
    done
}


banner(){

coffee_cup="
ADORe will be setup on your system. The following system changes will occurs:
   - Your OS version will be checked against supported versions
   - Docker will be installed or updated using a setup script based off of the official docker docs: https://docs.docker.com/engine/install/ubuntu/
   - APT dependencies 'gnu make' and 'git' will be installed
   - ADORe (${ADORE_REPO}) will be cloned to: ${CLONE_DIR}/adore
   - ADORe core modules will be built with \"make build\"
   - You may be prompted for sudo password (root priviliges are needed to install docker, make, and git)

ADORe Requirements:
   - ADORe requires a minimum of 20GB of storage
   - Recent version of docker 
   - This script is designed and tested for Ubuntu
   - adore_if_carla requires and additional 20GB of storage
 
   Initial setup can take 10-15 minutes depending on system and internet connection.
   Grab a cup of coffee and wait for the setup to complete.

    ( (
     ) )
  ........
  |      |]
  \      / 
   \`'--'\`
"
    printf "%s\n" "$coffee_cup"
    if [[ $HEADLESS == 0 ]]; then 
        if ! prompt_yes_no; then
            exiterr "ADORe setup aborted."
        fi
    else
        echo "INFO: Doing headless/unattended installation."
    fi
}


check_os_version(){
    local os_version=$(cat /etc/os-release | grep VERSION_ID | cut -d'"' -f2)

    if [[ $SUPPORTED_UBUNTU_VERSIONS != *"$os_version"* ]]; then
        exiterr "ERROR: unsupported os version: ${os_version} Supported versions: ${SUPPORTED_UBUNTU_VERSIONS}"
    fi
}

check_freespace(){
    freespace=$(df -h --output=avail . | tail -n 1 | awk '{print $1}' | sed "s|G||g")
    current_device=$(df --output=source . | tail -n 1)
    if (( $(echo "$freespace <= $REQUIRED_FREESPACE_GB" | bc -l) )); then     
        exiterr "ERROR: Not enough free space: ${freespace} available and: ${REQUIRED_FREESPACE_GB} required.\n Free up some space on '${current_device}' and try again."
    fi 
}

install_dependencies(){
    sudo apt-get update
    sudo apt-get install -y make git
}

install_docker(){
    bash <(curl -sSL https://raw.githubusercontent.com/DLR-TS/adore_tools/master/tools/install_docker.sh)
}

clone_adore(){
    cd "${CLONE_DIR}"
    
    if [[ ! -d "adore" ]]; then
        git clone "${ADORE_REPO}"
    fi
    cd "${CLONE_DIR}/adore"
    cp .gitmodules .gitmodules.bak
    sed -i "s|git@github.com:|https://github.com/|g" .gitmodules
    git submodule update --init
    mv .gitmodules.bak .gitmodules
    git submodule sync
}

build_adore_cli(){
newgrp docker << END
    cd "${CLONE_DIR}/adore"
    make build
    make build_adore-cli
    make build_catkin_base
END
}

success(){
    printf "\n"
    printf "ADORe was setup successfully!\n"
    printf "  ADORe Directory: ${CLONE_DIR}/adore \n"
    printf "  Use: 'cd ${CLONE_DIR}/adore && make cli' to get started \n"
    printf "  Read the docs: ${ADORE_DOCS_LINK} \n"
    printf "  Get help: ${ADORE_HELP_LINK}\n"
    printf "\n"
}

parse_params
banner
check_freespace
check_os_version
install_dependencies
clone_adore
install_docker
build_adore_cli
if [[ $HEADLESS == 1 ]]; then
    make run_test_scenarios
fi
success
