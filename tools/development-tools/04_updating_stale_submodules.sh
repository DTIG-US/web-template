#!/bin/bash

submodule_array=("web-carousel"
"web-footer"
"web-header"
"web-offering"
"web-partner"
"web-handsani-demo"
"web-home"
"web-legal"
"web-not-found"
)

for submodule in ${submodule_array[@]}; do
    echo "Updating the submodule: ${submodule}"
    git submodule update --init --recursive
done

echo "Updating the submodules is done"