run('bin/rspec spec -f doc') || abort
# Ensure we test the issue in-case this isn't the first spec file loaded
run(
  'bin/rspec --backtrace -f doc spec/__verify_fixture_load_order_spec.rb'
) || abort
run('bin/rake --backtrace spec') || abort
run('bin/rake --backtrace spec:requests') || abort
run('bin/rake --backtrace spec:models') || abort
run('bin/rake --backtrace spec:views') || abort
run('bin/rake --backtrace spec:controllers') || abort
run('bin/rake --backtrace spec:helpers') || abort
run('bin/rake --backtrace spec:mailers') || abort
run("bin/rails stats") || abort
