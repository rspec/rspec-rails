shared_examples_for "runs metadata hooks of :type =>" do |type, type_group|

  [:before, :after].each do |hook|
    [:all, :each].each do |scope|

      it "runs #{hook} #{scope} hooks before groups of #{type}" do
        with_isolated_config do |config|
          run_count = 0
          config.send(hook, scope, :type => type) { run_count += 1 }
          group = RSpec::Core::ExampleGroup.describe do
            include type_group
            specify { true }
          end
          group.run RSpec::Core::Reporter.new
          expect(run_count).to eq 1
        end
      end

    end
  end

end
