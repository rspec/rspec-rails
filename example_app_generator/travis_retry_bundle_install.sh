#!/bin/bash

set -e
source FUNCTIONS_SCRIPT_FILE

echo "Starting bundle install using shared bundle path"
if is_mri_192_plus; then
  travis_retry eval "RUBYOPT=$RUBYOPT' --enable gems' bundle install --gemfile ./Gemfile --path REPLACE_BUNDLE_PATH --retry=3 --jobs=3"
else
  travis_retry eval "bundle install --gemfile ./Gemfile --path REPLACE_BUNDLE_PATH --retry=3 --jobs=3"
fi
