#!/bin/bash

set -ex
source FUNCTIONS_SCRIPT_FILE

travis_retry eval "bundle install --gemfile ./Gemfile --path REPLACE_BUNDLE_PATH"
