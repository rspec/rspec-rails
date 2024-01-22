SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SPECS_HAVE_RUN_FILE=specs.out
MAINTENANCE_BRANCH=`cat maintenance-branch`

# Don't allow rubygems to pollute what's loaded. Also, things boot faster
# without the extra load time of rubygems. Only works on MRI Ruby 1.9+
export RUBYOPT="--disable=gem"

ci_retry() {
  local result=0
  local count=1
  while [ $count -le 3 ]; do
    [ $result -ne 0 ] && {
      echo -e "\n\033[33;1mThe command \"$@\" failed. Retrying, $count of 3.\033[0m\n" >&2
    }
    "$@"
    result=$?
    [ $result -eq 0 ] && break
    count=$(($count + 1))
    sleep 1
  done

  [ $count -eq 3 ] && {
    echo "\n\033[33;1mThe command \"$@\" failed 3 times.\033[0m\n" >&2
  }

  return $result
}

fold() {
  local name="$1"
  local status=0
  shift 1
  echo "============= Starting $name ==============="

  "$@"
  status=$?

  if [ "$status" -eq 0 ]; then
    echo "============= Ending $name ==============="
  else
    STATUS="$status"
  fi

  return $status
}

function documentation_enforced {
  if [ -x ./bin/yard ]; then
      return 0
  else
    return 1
  fi
}

function clone_repo {
  if [ ! -d $1 ]; then # don't clone if the dir is already there
    ci_retry eval "git clone https://github.com/rspec/$1 --depth 1 --branch $MAINTENANCE_BRANCH"
  fi;
}

function run_specs_and_record_done {
  echo "${PWD}/bin/rspec"
  bin/rspec spec --backtrace --format progress --profile --format progress --out $SPECS_HAVE_RUN_FILE
}

function run_specs_one_by_one {
  echo "Running each spec file, one-by-one..."

  for file in `find spec -iname '*_spec.rb'`; do
    echo "Running $file"
    bin/rspec $file -b --format progress
  done
}

function check_binstubs {
  echo "Checking required binstubs"

  local success=0
  local binstubs=""
  local gems=""

  if [ ! -x ./bin/rspec ]; then
    binstubs="$binstubs bin/rspec"
    gems="$gems rspec-core"
    success=1
  fi

  if [ ! -x ./bin/rake ]; then
    binstubs="$binstubs bin/rake"
    gems="$gems rake"
    success=1
  fi

  if [ -d features ]; then
    if [ ! -x ./bin/cucumber ]; then
      binstubs="$binstubs bin/cucumber"
      gems="$gems cucumber"
      success=1
    fi
  fi

  if [ $success -eq 1 ]; then
    echo
    echo "Missing binstubs:$binstubs"
    echo "Install missing binstubs using one of the following:"
    echo
    echo "  # Create the missing binstubs"
    echo "  $ bundle binstubs$gems"
    echo
    echo "  # To binstub all gems"
    echo "  $ bundle install --binstubs"
    echo
    echo "  # To binstub all gems and avoid loading bundler"
    echo "  $ bundle install --binstubs --standalone"
  fi

  return $success
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

  echo "bin/yard doc --no-cache"

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
