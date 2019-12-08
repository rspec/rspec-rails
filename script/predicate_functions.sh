function is_mri {
  if ruby -e "exit(RUBY_ENGINE == 'ruby')"; then
    return 0
  else
    return 1
  fi;
}

function is_jruby {
  if ruby -e "exit(RUBY_PLATFORM == 'java')"; then
    return 0
  else
    return 1
  fi;
}

function is_ruby_23_plus {
  if ruby -e "exit(RUBY_VERSION.to_f >= 2.3)"; then
    return 0
  else
    return 1
  fi
}

function additional_specs_available {
  type run_additional_specs > /dev/null 2>&1
  return $?
}

function documentation_enforced {
  if [ -x ./bin/yard ]; then
    return 0
  else
    return 1
  fi
}

function style_and_lint_enforced {
 if [ -x ./bin/rubocop ]; then
   return 0
 else
   return 1
 fi
}
