#!/bin/bash

set -e
source FUNCTIONS_SCRIPT_FILE

echo "Starting bundle install using shared bundle path"
ci_retry eval "RUBYOPT=$RUBYOPT:' --enable rubygems' bundle install --gemfile ./Gemfile --path REPLACE_BUNDLE_PATH --retry=3 --jobs=3"
