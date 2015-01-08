
class RtwNotification < ActiveRecord::Base
  unloadable

  # these prevent model upbject attributes to be assigned, no idea why
  # attr_accessor :issue_id, :spent_time, :timebase, :warning_ratio, :recipients, :created_at, :updated_at

  scope :for_issue, ->(issue) {
    issue_id = issue.is_a?(Class) ? issue.id : issue
    where(:issue_id => proj_id)
  }

  scope :latest_update, order('updated_at desc').first


  def self.last_spent_time_for_issue(issue)
    latest = for_issue(issue).latest_update

    if latest
      latest.spent_time
    else
      0.0
    end
  end

  def self.process_spent_time_notification(issue, settings)
    rtwn = create(
      :issue_id => issue_id,
      :spent_time => issue.total_spent_hours,
      :timebase => settings.timebase,
      :warning_ratio => settings.warning_ratio,
      :recipients => settings.recipients
    )

  end

end

