namespace "truncate" do
  TRUNCATE_DEFAULT_DURATION = 1
  TRUNCATE_DEFAULT_COUNT = 15

  desc "Truncate Payload Log Entries that are older than a certain date or successful (Default: #{TRUNCATE_DEFAULT_DURATION} days ago)"
  task :payload_log_entries, [:duration] => :environment do |task, args|
    duration = (args[:duration] ? args[:duration].to_i : TRUNCATE_DEFAULT_DURATION).days.ago
    duration_count = PayloadLogEntry.where('created_at < ?', duration).count
    Rails.logger.info "#{'*' * 20}Truncating #{duration_count} Payload Log Entries greater than #{duration.strftime('%D')}...#{'*' * 20}"
    PayloadLogEntry.where('created_at < ?', duration).delete_all

    success_count = PayloadLogEntry.where("status = 'successful'").count
    Rails.logger.info "#{'*' * 20}Truncating #{success_count} Payload Log Entries that were successful...#{'*' * 20}"
    PayloadLogEntry.where("status = 'successful'").delete_all
  end

  desc "Truncate Project Statuses for each project down to a given number (Default: #{TRUNCATE_DEFAULT_COUNT})"
  task :project_statuses, [:count] => :environment do |task, args|
    count = (args[:count] ? args[:count].to_i : TRUNCATE_DEFAULT_COUNT)
    ProjectStatusesTrimmer.run(count)
  end
end
