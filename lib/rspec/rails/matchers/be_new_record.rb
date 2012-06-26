module RSpec::Rails::Matchers
  class BeANewRecord < RSpec::Matchers::BuiltIn::BaseMatcher

    # @api private
    def matches?(actual)
      !actual.persisted?
    end
  end

  # Passes if actual returns `false` for `persisted?`.
  #
  # @example
  #
  #     get :new
  #     assigns(:thing).should be_new_record
  def be_new_record
    BeANewRecord.new
  end
end
