
class RtwProjectSetting < ActiveRecord::Base
  unloadable

  attr_accessible :project_id, :timebase, :warning_ratio, :email_subject, :recipients, :email_template,
    :created_at, :updated_at, :notify_on_custom, :notify_on_estimated, :custom_field_id,
    :warning_ratio_estimated, :email_subject_estimated, :recipients_estimated, :email_template_estimated

  # belongs_to :project

  NOTIFY_ON_CUSTOM_ATTRIBUTES = [
    :timebase,
    :warning_ratio,
    :email_subject,
    :recipients,
    :email_template
  ]

  NOTIFY_ON_ESTIMATED_ATTRIBUTES = [
    :custom_field_id,
    :warning_ratio_estimated,
    :email_subject_estimated,
    :recipients_estimated,
    :email_template_estimated
  ]

  FALSIFY_ATTRS = [
    :notify_on_estimated,
    :notify_on_custom
  ]


  validates_presence_of *NOTIFY_ON_CUSTOM_ATTRIBUTES, :if => Proc.new{|rtws| rtws.notify_on_custom}
  validates_presence_of *NOTIFY_ON_ESTIMATED_ATTRIBUTES, :if => Proc.new{|rtws| rtws.notify_on_estimated}

  scope :for_project, ->(project) {
    proj_id = project.is_a?(Class) ? project.id : project
    where(:project_id => proj_id)
  }


  def self.settings_for_project(proj_id)
    settings = for_project(proj_id).first_or_initialize(RedmineTimewatch.settings)
    settings
  end

  def warning_level
    warning_ratio * timebase / 100.0
  end

  def calc_level(current_spent_time)
    current_spent_time % timebase
  end

  def calc_factor(current_spent_time)
    current_spent_time.to_i / timebase
  end

  def is_above_threshold(issue_id, current_spent_time)
    return false unless notify_on_custom
    above_threshold = false

    Rails.logger.debug "RTW issue #{issue_id} has total spent hours #{current_spent_time.inspect}"

    current_level = calc_level(current_spent_time)
    should_check = (current_level.to_i == 0) || (current_level >= warning_level)

    current_factor = calc_factor(current_spent_time)
    last_spent_time = RtwNotification.last_spent_time_for_issue(issue_id)
    last_level = calc_level(last_spent_time)
    last_factor = calc_factor(last_spent_time)

    Rails.logger.debug "RTW current_factor:#{current_factor} last_factor:#{last_factor} last_spent_time:#{last_spent_time} last_level:#{last_level}"

    if current_factor > last_factor + 1
      above_threshold = true
    elsif current_factor == last_factor + 1
      if (last_level < warning_level) || (current_level >= warning_level)
        above_threshold = true
      end
    else # current_factor == last_factor
      if (current_level >= warning_level) && (last_level < warning_level)
        above_threshold = true
      end
    end

    above_threshold
  end

  def custom_estimated_value(issue)
    return nil unless custom_field_id

    begin
      cf = CustomField.find(custom_field_id)
      retval = issue.custom_field_value(cf).to_f
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "Redmine Timewatch: Could not find CustomField while recording notification for id #{custom_field_id.inspect}"
      retval = nil
    end

    retval
  end

  def self.sanitize_settings(settings)
    FALSIFY_ATTRS.each do |attr|
      settings[attr] = false if settings[attr].blank?
    end

    settings
  end

end

