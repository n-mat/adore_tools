#!/usr/bin/env bash

set -euo pipefail

# Finds all ADORe modules and calls make clean on them

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SUBMODULES_PATH="$(pwd)"


EXCLUDED_MODULES="lizard_docker make_gadgets apt_cacher_ng_docker catkin_docker ci_teststand cppcheck_docker cpplint_docker catkin_docker"
EXCLUDED_MODULES=$(echo "$EXCLUDED_MODULES" | tr ' ' '\n' )



all_modules=$(find . -mindepth 2 -maxdepth 2 -type f -name "*.mk" -exec dirname {} \; | sed "s|./||g")

modules=$(comm -3 <(echo "$all_modules" | sort) <(echo "$EXCLUDED_MODULES" | sort) | sort -r)
for module in $modules; do
    echo "Cleaning: ${module}"
    (cd "${SUBMODULES_PATH}/${module}" && make clean)
done
