RSpec.describe 'Rails app with use_active_record = false but active record railties loaded' do
  it 'properly handles name scope in fixture_support' do
    cmd = 'ruby spec/rspec/rails/features/rails_app/partial_active_record_false.rb'
    cmd_status = ruby_script_runner(cmd)
    expect(cmd_status[:stdout].last&.chomp).to eq("1 example, 0 failures")
    expect(cmd_status[:exitstatus]).to eq(0)
  end

  def ruby_script_runner(cmd)
    require 'open3'
    cmd_status = { stdout: [], exitstatus: nil }
    Open3.popen2(cmd) do |_stdin, stdout, wait_thr|
      frame_stdout do
        while line = stdout.gets
          puts "|  #{line}"
          cmd_status[:stdout] << line if line =~ /\d+ (example|examples), \d+ failure/
        end
      end
      cmd_status[:exitstatus] = wait_thr.value.exitstatus
    end
    cmd_status
  end

  def frame_stdout
    puts
    puts '-' * 50
    yield
    puts '-' * 50
  end
end
