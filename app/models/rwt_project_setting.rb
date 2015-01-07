
class RtwProjectSetting < ActiveRecord::Base

  attr_accessor :project_id, :timebase, :warning_ratio, :recipients, :email_template, :created_at, :updated_at

end

