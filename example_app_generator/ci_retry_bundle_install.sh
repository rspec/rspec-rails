#!/bin/bash

set -e
source FUNCTIONS_SCRIPT_FILE

echo "Starting bundle install using shared bundle path"
RUBYOPT="$RUBYOPT --enable rubygems" bundle config set --local path REPLACE_BUNDLE_PATH
ci_retry eval "RUBYOPT=$RUBYOPT:' --enable rubygems' bundle install --gemfile ./Gemfile --retry=3 --jobs=3"
