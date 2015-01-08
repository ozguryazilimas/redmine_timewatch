
class RtwNotificationHistory < ActiveRecord::Base
  unloadable

  # these prevent model upbject attributes to be assigned, no idea why
  # attr_accessor :issue_id, :spent_time, :timebase, :warning_ratio, :recipients, :created_at, :updated_at

end

