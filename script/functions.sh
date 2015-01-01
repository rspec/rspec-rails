# This file was generated on 2014-12-31T23:38:56-08:00 from the rspec-dev repo.
# DO NOT modify it by hand as your changes will get lost the next time it is generated.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/travis_functions.sh
source $SCRIPT_DIR/predicate_functions.sh

# idea taken from: http://blog.headius.com/2010/03/jruby-startup-time-tips.html
export JRUBY_OPTS="${JRUBY_OPTS} -X-C" # disable JIT since these processes are so short lived
SPECS_HAVE_RUN_FILE=specs.out
MAINTENANCE_BRANCH=`cat maintenance-branch`

function clone_repo {
  if [ ! -e $1/Gemfile ]; then # don't reclone
    # deal with our bundler cache directory.
    # Git won't clone into a non-empty dir so we have to move it aside and move it back.
    mkdir -p $1/bundle
    pushd $1
    mv bundle ../$1-bundle
    travis_retry eval "git clone git://github.com/rspec/$1 --depth 1 --branch $MAINTENANCE_BRANCH ."
    mv ../$1-bundle bundle
    popd
  fi;
}

function run_specs_and_record_done {
  local rspec_bin=bin/rspec

  # rspec-core needs to run with a special script that loads simplecov first,
  # so that it can instrument rspec-core's code before rspec-core has been loaded.
  if [ -f script/rspec_with_simplecov ]; then
    rspec_bin=script/rspec_with_simplecov
  fi;

  echo "${PWD}/bin/rspec"
  $rspec_bin spec --backtrace --format progress --profile --format progress --out $SPECS_HAVE_RUN_FILE
}

function run_cukes {
  if [ -d features ]; then
    # force jRuby to use client mode JVM or a compilation mode thats as close as possible,
    # idea taken from https://github.com/jruby/jruby/wiki/Improving-startup-time
    #
    # Note that we delay setting this until we run the cukes because we've seen
    # spec failures in our spec suite due to problems with this mode.
    export JAVA_OPTS='-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1'

    echo "${PWD}/bin/cucumber"

    if is_mri_192; then
      # For some reason we get SystemStackError on 1.9.2 when using
      # the bin/cucumber approach below. That approach is faster
      # (as it avoids the bundler tax), so we use it on rubies where we can.
      bundle exec cucumber --strict
    else
      # Prepare RUBYOPT for scenarios that are shelling out to ruby,
      # and PATH for those that are using `rspec` or `rake`.
      RUBYOPT="-I${PWD}/bundle -rbundler/setup" \
         PATH="${PWD}/bin:$PATH" \
         bin/cucumber --strict
    fi
  fi
}

function run_specs_one_by_one {
  echo "Running each spec file, one-by-one..."

  for file in `find spec -iname '*_spec.rb'`; do
    bin/rspec $file -b --format progress
  done
}

function run_spec_suite_for {
  if [ ! -f ../$1/$SPECS_HAVE_RUN_FILE ]; then # don't rerun specs that have already run
    echo "Running specs for $1"
    pushd ../$1
    unset BUNDLE_GEMFILE
    bundle_install_flags=`cat .travis.yml | grep bundler_args | tr -d '"' | grep -o " .*"`
    travis_retry eval "bundle install $bundle_install_flags"
    run_specs_and_record_done
    bundle clean # prep for travis caching
    popd
  fi;
}

function check_documentation_coverage {
  echo "bin/yard stats --list-undoc"

  bin/yard stats --list-undoc | ruby -e "
    while line = gets
      has_warnings ||= line.start_with?('[warn]:')
      coverage ||= line[/([\d\.]+)% documented/, 1]
      puts line
    end

    unless Float(coverage) == 100
      puts \"\n\nMissing documentation coverage (currently at #{coverage}%)\"
      exit(1)
    end

    if has_warnings
      puts \"\n\nYARD emitted documentation warnings.\"
      exit(1)
    end
  "

  # Some warnings only show up when generating docs, so do that as well.
  bin/yard doc --no-cache | ruby -e "
    while line = gets
      has_warnings ||= line.start_with?('[warn]:')
      has_errors   ||= line.start_with?('[error]:')
      puts line
    end

    if has_warnings || has_errors
      puts \"\n\nYARD emitted documentation warnings or errors.\"
      exit(1)
    end
  "
}

function check_style_and_lint {
  echo "bin/rubucop lib"
  bin/rubocop lib
}

function run_all_spec_suites {
  fold "one-by-one specs" run_specs_one_by_one
  fold "rspec-core specs" run_spec_suite_for "rspec-core"
  fold "rspec-expectations specs" run_spec_suite_for "rspec-expectations"
  fold "rspec-mocks specs" run_spec_suite_for "rspec-mocks"
  fold "rspec-rails specs" run_spec_suite_for "rspec-rails"

  if rspec_support_compatible; then
    fold "rspec-support specs" run_spec_suite_for "rspec-support"
  fi
}
