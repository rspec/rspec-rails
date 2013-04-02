module RSpec
  module Rails
    module Version
      STRING = '2.13.0'

      def self.rails_version?(version)
        current_version = if ::Rails.version.is_a?(Gem::Version)
                            ::Rails.version
                          else
                            Gem::Version.new(::Rails.version.to_s)
                          end
        Gem::Requirement.new(version).satisfied_by?(current_version)
      end
    end
  end
end
