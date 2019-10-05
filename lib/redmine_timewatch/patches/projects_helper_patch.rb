require_dependency 'projects_helper'


module RedmineTimewatch
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :project_settings_tabs_without_redmine_timewatch, :project_settings_tabs
          alias_method :project_settings_tabs, :project_settings_tabs_with_redmine_timewatch
        end
      end

      module InstanceMethods

        def project_settings_tabs_with_redmine_timewatch
          tabs = project_settings_tabs_without_redmine_timewatch

          if User.current.allowed_to?(:rtw_timewatch, @project)
            tabs << {
              :name => 'rtw_project_settings',
              :action => :rtw_manage_project_settings,
              :partial => 'projects/rtw_project_settings',
              :label => 'redmine_timewatch.project_settings.label_timewatch'
            }
          end

          tabs
        end

      end

    end
  end
end

