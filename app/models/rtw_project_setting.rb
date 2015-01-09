
class RtwProjectSetting < ActiveRecord::Base
  unloadable

  # these prevent model upbject attributes to be assigned, no idea why
  # attr_accessor :project_id, :timebase, :warning_ratio, :recipients, :email_subject, :email_template, :created_at, :updated_at

  # belongs_to :project

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

end

