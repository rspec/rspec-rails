RSpec::Matchers.define :be_generated do
  match do |relative|
    absolute = File.expand_path(relative, subject.destination_root)
    File.exists?(absolute) && contents_match?(absolute)
  end

  chain :containing do |*expected_contents|
    @expected_contents = expected_contents
  end

  def contents_match?(absolute)
    return true if @expected_contents.nil?

    actual_contents = File.read(absolute)
    @expected_contents.each do |content|
      case content
        when String
          actual_contents.should == content
        when Regexp
          actual_contents.should =~ content
      end
    end
  end

  failure_message_for_should do |relative|
    if @expected_contents
      "expected the generated file #{relative} to contain #{@expected_contents.to_s}"
    else
      "expected the file #{relative} to be generated"
    end
  end

  failure_message_for_should_not do |relative|
    "expected that the generator would not generate a file #{relative}"
  end

end
