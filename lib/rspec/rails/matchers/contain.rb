RSpec::Matchers.define :contain do |expected_content|
  match do |file_path|
    @actual_contents = File.new(file_path).read
    case expected_content
      when String
        @actual_contents == expected_content
      when Regexp
        @actual_contents =~ expected_content
    end
  end
  
  failure_message_for_should do |file_path|
    "expected the file #{file_path} to contain #{expected_content.inspect} but it contained #{@actual_contents.inspect}"
  end
  
  failure_message_for_should_not do |relative|
    "expected the file #{file_path} to not contain #{expected_content} but it did"
  end
end
