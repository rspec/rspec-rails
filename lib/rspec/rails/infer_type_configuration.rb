RSpec.configure do |config|

  def config.infer_spec_type_from_file_location!
    @infer_spec_type_from_file_location = true
  end

  def config.infer_spec_type_from_file_location?
    @infer_spec_type_from_file_location ||= false
  end

  config.before do
    unless config.infer_spec_type_from_file_location?
      RSpec.warn_deprecation(<<-EOS.gsub(/^\s+\|/,''))
       |Implicitly inferring spec type via file location is deprecated.
       |In RSpec 3.x you will need to explicitly enable this feature via:
       |`RSpec::Configuration#infer_spec_type_from_file_location!`
       |
       |If you wish to manually label spec types via metadata tags you
       |can safely ignore this warning.
      EOS
    end
  end
end
