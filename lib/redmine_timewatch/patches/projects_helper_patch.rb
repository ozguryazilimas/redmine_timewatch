require_dependency 'projects_helper'

module RedmineTimewatch
  module Patches
    module ProjectsHelperPatch

      def project_settings_tabs
        tabs = super

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

ProjectsController.helper(RedmineTimewatch::Patches::ProjectsHelperPatch)

