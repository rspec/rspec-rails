Then /^the example(s)? should( all)? pass$/ do |*|
  Then %q{the exit status should be 0}
  Then %q{the output should contain "0 failures"}
end

