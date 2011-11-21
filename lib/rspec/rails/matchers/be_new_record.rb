module RSpec::Matchers
  class BeANewRecord
    include BaseMatcher

    def matches?(actual)
      !actual.persisted?
    end
  end

  def be_new_record
    BeANewRecord.new
  end
end
