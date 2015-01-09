
class RtwNotification < ActiveRecord::Base
  unloadable

  ISSUE_NUMBER = 'ISSUE_NUMBER'
  ISSUE_SPENT_TIME = 'ISSUE_SPENT_TIME'

  # these prevent model upbject attributes to be assigned, no idea why
  # attr_accessor :issue_id, :spent_time, :timebase, :warning_ratio, :recipients, :created_at, :updated_at

  scope :for_issue, ->(issue) {
    issue_id = issue.is_a?(Class) ? issue.id : issue
    where(:issue_id => issue_id)
  }

  scope :latest_update, order('updated_at desc').first


  def self.last_spent_time_for_issue(issue)
    ret = 0.0
    latest = RtwNotification.for_issue(issue).order('updated_at desc').first

    if latest.present?
      ret = latest.spent_time rescue 0.0
    end

    ret
  end

  def self.process_spent_time_notification(issue, settings, target_time)
    rtwn = create(
      :issue_id => issue.id,
      :spent_time => issue.total_spent_hours,
      :timebase => settings.timebase,
      :warning_ratio => settings.warning_ratio,
      :recipients => settings.recipients
    )

    Mailer.timewatch_spent_time_over_threshold(
      issue,
      settings.email_template,
      "[##{issue.id}] #{issue.subject}: #{settings.email_subject}",
      settings.recipients,
      target_time.to_i
    ).deliver
  end

  def self.format_email_body(body, issue_info, target_time)
    ret = body.gsub(/#{ISSUE_NUMBER}/, issue_info)
    ret = ret.gsub(/#{ISSUE_SPENT_TIME}/, target_time.to_s)

    ret
  end

end

