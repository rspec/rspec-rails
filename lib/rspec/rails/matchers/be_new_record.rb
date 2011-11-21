module RSpec::Matchers
  class BeANewRecord
    include BaseMatcher

    # @api private
    def matches?(actual)
      !actual.persisted?
    end
  end

  # Passes if actual returns `false` for `persisted?`.
  #
  # ## Examples:
  #
  #     get :new
  #     assigns(:thing).should be_new_record
  def be_new_record
    BeANewRecord.new
  end
end
