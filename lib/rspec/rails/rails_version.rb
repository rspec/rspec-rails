module RSpec
  module Rails
    # @api private
    def self.rails_version_satisfied_by?(requirement)
      Gem::Requirement.new(requirement).satisfied_by?(rails_version)
    end

    # @api private
    def self.rails_version
      @rails_version ||= if ::Rails.version.is_a?(Gem::Version)
                           ::Rails.version
                         else
                           Gem::Version.new(::Rails.version.to_s)
                         end
    end
  end
end
