Feature: have_enqueued_job matcher

  The `have_enqueued_job` matcher is used to check if given ActiveJob job was enqueued.

  Background:
    Given active job is available

  Scenario: Checking job class name
    Given a file named "spec/jobs/upload_backups_job_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UploadBackupsJob do
        it "matches with enqueued job" do
          ActiveJob::Base.queue_adapter = :test
          expect {
            UploadBackupsJob.perform_later
          }.to have_enqueued_job(UploadBackupsJob)
        end
      end
      """
    When I run `rspec spec/jobs/upload_backups_job_spec.rb`
    Then the examples should all pass

  Scenario: Checking passed arguments to job
    Given a file named "spec/jobs/upload_backups_job_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UploadBackupsJob do
        it "matches with enqueued job" do
          ActiveJob::Base.queue_adapter = :test
          expect {
            UploadBackupsJob.perform_later("users-backup.txt", "products-backup.txt")
          }.to have_enqueued_job.with("users-backup.txt", "products-backup.txt")
        end
      end
      """
    When I run `rspec spec/jobs/upload_backups_job_spec.rb`
    Then the examples should all pass

  Scenario: Checking job enqueued time
    Given a file named "spec/jobs/upload_backups_job_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UploadBackupsJob do
        it "matches with enqueued job" do
          ActiveJob::Base.queue_adapter = :test
          expect {
            UploadBackupsJob.set(:wait_until => Date.tomorrow.noon).perform_later
          }.to have_enqueued_job.at(Date.tomorrow.noon)
        end
      end
      """
    When I run `rspec spec/jobs/upload_backups_job_spec.rb`
    Then the examples should all pass

  Scenario: Checking job queue name
    Given a file named "spec/jobs/upload_backups_job_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UploadBackupsJob do
        it "matches with enqueued job" do
          ActiveJob::Base.queue_adapter = :test
          expect {
            UploadBackupsJob.perform_later
          }.to have_enqueued_job.on_queue("default")
        end
      end
      """
    When I run `rspec spec/jobs/upload_backups_job_spec.rb`
    Then the examples should all pass
