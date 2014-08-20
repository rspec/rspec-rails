module AmmeterShim
  # Is this thread safe!?!?
  # This won't work with sub-processes
  def capture(io, &block)
    case io
    when :stdout
      capture_stdout(&block)
    when :stderr
      capture_stderr(&block)
    else
      raise "Unknown IO #{io}"
    end
  end

  def capture_stdout(&block)
    captured_stream = StringIO.new

    orginal_io, $stdout = $stdout, captured_stream

    block.call

    captured_stream.string
  ensure
    $stdout = orginal_io
  end

  def capture_stderr(&block)
    captured_stream = StringIO.new

    orginal_io, $stderr = $stderr, captured_stream

    block.call

    captured_stream.string
  ensure
    $stderr = orginal_io
  end
end

RSpec.configure do |config|
  config.extend AmmeterShim, :type => :generator
end
