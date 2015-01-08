
class RtwProjectSetting < ActiveRecord::Base
  unloadable

  # these prevent model upbject attributes to be assigned, no idea why
  # attr_accessor :project_id, :timebase, :warning_ratio, :recipients, :email_template, :created_at, :updated_at

  # belongs_to :project

  scope :for_project, ->(project) {
    proj_id = project.is_a?(Class) ? project.id : project
    where(:project_id => proj_id)
  }


  def self.settings_for_project(proj_id)
    settings = for_project(proj_id).first
    settings = RedmineTimewatch.settings if settings.blank?

    settings
  end

end

