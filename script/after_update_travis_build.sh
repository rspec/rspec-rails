#!/bin/bash
set -e

echo "Restoring custom Travis config"
mv .travis.yml{.update_backup,}

echo "Removing Base rubocop, Rspec-Rails does not use it"
rm '.rubocop_rspec_base.yml'
