#!/bin/bash

# Change into the src/app directory
cd src/app

# The url is stored in a variable for easy access
url="https://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@github.com/DTIG-US/"

# The array of submodules to add
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


# The default branch for all submodules is main
branch="main"

for submodule in ${submodule_array[@]}; do
    echo "Adding the submodule: ${submodule}"
    git submodule add ${url}${submodule}.git
    git submodule sync
    git submodule update --init --recursive
done

echo "Adding the submodules is done"