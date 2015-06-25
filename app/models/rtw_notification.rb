
class RtwNotification < ActiveRecord::Base
  unloadable

  attr_accessible :issue_id, :spent_time, :timebase, :warning_ratio, :recipients, :created_at, :updated_at,
    :custom_estimated_time, :custom_estimated_id, :notification_type


  ISSUE_NUMBER = 'ISSUE_NUMBER'
  ISSUE_SPENT_TIME = 'ISSUE_SPENT_TIME'
  ISSUE_CUSTOM_ESTIMATED_TIME = 'ISSUE_CUSTOM_ESTIMATED_TIME'

  TYPE_SPENT = 'spent'
  TYPE_CUSTOM_ESTIMATED = 'custom_estimated'


  scope :for_issue, ->(issue) {
    issue_id = issue.is_a?(Class) ? issue.id : issue
    where(:issue_id => issue_id)
  }

  scope :latest_update, -> { order('updated_at desc').first }

  scope :for_spent, -> { where(:notification_type => TYPE_SPENT) }
  scope :for_custom_estimated, -> { where(:notification_type => TYPE_CUSTOM_ESTIMATED) }


  def self.last_spent_time_for_issue(issue)
    ret = 0.0
    latest = RtwNotification.for_spent.for_issue(issue).order('updated_at desc').first

    if latest.present?
      # extra extra failsafe to avoid race conditions between issue.save time_entry.save journal.save
      ret = latest.spent_time rescue 0.0
    end

    ret
  end

  def self.custom_estimated_not_notified(issue)
    RtwNotification.for_custom_estimated.for_issue(issue).count < 1
  end

  def self.create_issue_journal(issue, settings, current_spent_time, for_type)
    case for_type
    when TYPE_SPENT
      journal_recipients = settings.recipients
      journal_subject = settings.email_subject
      journal_body = format_email_body(settings.email_template, "##{issue.id}", current_spent_time, TYPE_SPENT)
    when TYPE_CUSTOM_ESTIMATED
      journal_recipients = settings.recipients_estimated
      journal_subject = settings.email_subject_estimated
      journal_body = format_email_body(settings.email_template_estimated, "##{issue.id}", current_spent_time, TYPE_CUSTOM_ESTIMATED)
    end

    journal_msg =  "From   : #{Setting.mail_from}\r\n"
    journal_msg += "To     : #{journal_recipients}\r\n"
    journal_msg += "Subject: [##{issue.id}] #{issue.subject}: #{journal_subject}\r\n"
    journal_msg += "\r\n"
    journal_msg += journal_body

    init_journal_user = User.find_by_login('admin')

    new_journal = Journal.new(:journalized => issue, :user => init_journal_user, :notes => journal_msg)
    new_journal.notify = true
    new_journal.save!
  end

  def self.send_email_notification(issue, settings, target_time, for_type)
    case for_type
    when TYPE_SPENT
      mail_template = settings.email_template
      mail_subject = settings.email_subject
      mail_recipients = settings.recipients
    when TYPE_CUSTOM_ESTIMATED
      mail_template = settings.email_template_estimated
      mail_subject = settings.email_subject_estimated
      mail_recipients = settings.recipients_estimated
    end

    Mailer.timewatch_spent_time_over_threshold(
      issue,
      mail_template,
      "[##{issue.id}] #{issue.subject}: #{mail_subject}",
      mail_recipients,
      target_time.to_i,
      for_type
    ).deliver
  end

  def self.save_notification(issue, settings, for_type)
    rtwn = create(
      :issue_id => issue.id,
      :spent_time => issue.total_spent_hours,
      :timebase => settings.timebase,
      :warning_ratio => settings.warning_ratio,
      :recipients => settings.recipients,
      :notification_type => for_type,
      :custom_estimated_id => settings.custom_field_id,
      :custom_estimated_time => settings.custom_estimated_value(issue)
    )

    rtwn
  end

  def self.process_spent_time_notification(issue, settings, target_time, current_spent_time, for_type)
    case for_type
    when TYPE_SPENT
      Rails.logger.warn "RTW issue #{issue.id} has spent hours #{current_spent_time} that is over threshold"
    when TYPE_CUSTOM_ESTIMATED
      Rails.logger.warn "RTW issue #{issue.id} has spent hours #{current_spent_time} that is close to custom estimated time"
    end

    save_notification(issue, settings, for_type)
    create_issue_journal(issue, settings, target_time, for_type)
    send_email_notification(issue, settings, target_time, for_type)
  end

  def self.format_email_body(body, issue_info, target_time, for_type)
    ret = body.gsub(/#{ISSUE_NUMBER}/, issue_info.to_s)

    case for_type
    when TYPE_SPENT
      ret = ret.gsub(/#{ISSUE_SPENT_TIME}/, target_time.to_i.to_s)
    when TYPE_CUSTOM_ESTIMATED
      ret = ret.gsub(/#{ISSUE_CUSTOM_ESTIMATED_TIME}/, target_time.to_i.to_s)
    end

    ret
  end

end

