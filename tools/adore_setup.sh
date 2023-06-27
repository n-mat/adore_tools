#!/usr/bin/env bash

set -x
set -euo pipefail
trap 'get_help' INT


exiterr (){ printf "$@\n"; exit 1;}

CLONE_DIR="${HOME}"
SUPPORTED_UBUNTU_VERSIONS="20.04 20.10 22.04"
REQUIRED_FREESPACE_GB="20"
ADORE_REPO="https://github.com/eclipse/adore.git"

ADORE_HELP_LINK="https://github.com/eclipse/adore/issues"
ADORE_DOCS_LINK="https://eclipse.github.io/adore/"


get_help(){
    printf "\n\n"
    printf "Having trouble? Reach out to the ADORe team, we are here to help!\n"
    printf "  https://github.com/eclipse/adore/issues \n"
    printf "\n\n"
    exit $?
}
prompt_yes_no() {
    while true; do
        read -p "Do you want to proceed? (y/n)" answer
        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Invalid input. Please enter yes or no."
                ;;
        esac
    done
}


banner(){

coffee_cup="
ADORe will be setup on your system. The following system changes will occurs:
   - Docker will be installed or updated
   - APT dependencies 'make' and 'git' will be installed
   - ADORe will be cloned to: ${CLONE_DIR}/adore
   - You may be prompted for sudo password

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
    if ! [[ $(prompt_yes_no) -eq 0 ]]; then
       exiterr "ADORe setup aborted."
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

    if (( freespace <= REQUIRED_FREESPACE_GB )); then
        exiterr "ERROR: Not enough free space: ${freespace} available and: ${REQUIRED_FREESPACE_GB} required.\n Free up some space on '${current_device}' and try again."
    fi 
}

install_dependencies(){
    sudo apt-get update
    sudo apt-get install make git
}

install_docker(){
    cd "${CLONE_DIR}/adore/adore_tools/tools"
    bash install_docker.sh
}

clone_adore(){
    cd "${CLONE_DIR}"
    
    if [[ ! -d "adore" ]]; then
        git clone "${ADORE_REPO}"
    fi
    cd adore
    git config --local url."https://github.com/".insteadOf "git@github.com:"
    git submodule update --init
    
    git config --local --unset-all url."https://github.com/".insteadOf
    sed -i "s|https://github.com/|git@github.com:|g" .git/config
}

build_adore_cli(){

    cd "${CLONE_DIR}/adore"
    make build
    make build_adore-cli
    make build_catkin_base

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

banner
check_freespace
check_os_version
clone_adore
install_dependencies
install_docker
build_adore_cli
success
