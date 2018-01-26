module RedmineTimewatch

  def self.settings
    (Setting[:plugin_redmine_timewatch] || {}).with_indifferent_access
  end

end

