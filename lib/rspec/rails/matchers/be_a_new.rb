RSpec::Matchers.define :be_a_new do |model_klass|
  match do |actual|
    model_klass === actual && actual.new_record?
  end
end
