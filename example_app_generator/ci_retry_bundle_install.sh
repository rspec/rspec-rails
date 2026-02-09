#!/bin/bash

set -e
source FUNCTIONS_SCRIPT_FILE

echo "Starting bundle install using shared bundle path"
ci_retry eval "bundle config set path REPLACE_BUNDLE_PATH; bundle install --gemfile ./Gemfile --retry=3 --jobs=3"
