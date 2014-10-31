#!/bin/bash

set -e
source FUNCTIONS_SCRIPT_FILE

echo "Starting bundle install using shared bundle path"
travis_retry eval "bundle install --gemfile ./Gemfile --path REPLACE_BUNDLE_PATH --retry=3 --jobs=3"
