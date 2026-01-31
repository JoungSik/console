# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Set environment
set :environment, ENV.fetch("RAILS_ENV", "production")

# Set output log file
set :output, "log/cron.log"

# Example task - runs every day at 2am
# every 1.day, at: '2:00 am' do
#   rake "cleanup:old_records"
# end

# Todo 리마인더 - 매일 오전 9시에 실행
every 1.day, at: "9:00 am" do
  runner "CheckTodoRemindersJob.perform_later"
end
