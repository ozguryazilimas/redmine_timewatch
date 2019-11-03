
module RedmineTimewatch

  def self.settings
    HashWithIndifferentAccess.new(Setting[:plugin_redmine_timewatch])
  end

end

