#!/usr/bin/env bash

# Finds all ADORe modules and calls make build on them

set -euo pipefail


SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SUBMODULES_PATH="$(pwd)"


EXCLUDED_MODULES="lizard_docker make_gadgets apt_cacher_ng_docker catkin_docker ci_teststand cppcheck_docker cpplint_docker catkin_docker extended_sumo_if_ros"
EXCLUDED_MODULES=$(echo "$EXCLUDED_MODULES" | tr ' ' '\n' )



all_modules=$(find . -mindepth 2 -maxdepth 2 -type f -name "*.mk" -exec dirname {} \; | sed "s|./||g")

echo "Building: adore_ml"
(cd "${SUBMODULES_PATH}/adore_ml" && make build)


modules=$(comm -3 <(echo "$all_modules" | sort) <(echo "$EXCLUDED_MODULES" | sort) | sort -r)
for module in $modules; do
    echo "Building: ${module}"
    (cd "${SUBMODULES_PATH}/${module}" && make build)
done

echo "Building: extended_sumo_if_ros"
(cd "${SUBMODULES_PATH}/extended_sumo_if_ros" && make build)

