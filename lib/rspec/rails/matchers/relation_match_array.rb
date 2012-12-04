if defined?(ActiveRecord::Relation)
  RSpec::Matchers::OperatorMatcher.register(ActiveRecord::Relation, '=~', RSpec::Matchers::BuiltIn::MatchArray)

  module RSpec
    module Rails
      module RelationOperationMatcherHook
        def inherited(subclass)
          RSpec::Matchers::OperatorMatcher.register(subclass, '=~', RSpec::Matchers::BuiltIn::MatchArray)
          super
        end
      end
    end
  end
  ActiveRecord::Relation.extend(RSpec::Rails::RelationOperationMatcherHook)
end
