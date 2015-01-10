require_dependency 'projects_controller'


module RedmineTimewatch
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          # alias_method_chain :project_settings_tabs, :redmine_timewatch
        end
      end

      module ClassMethods

      end

      module InstanceMethods

        def rtw_project_settings
          @settings = params[:settings]

          if params[:reset].present?
            RtwProjectSetting.destroy_all(:project_id => @project.id)
            flash[:notice] = l(:notice_successful_update)
          else
            project_setting = RtwProjectSetting.for_project(@project).first_or_initialize
            project_setting.assign_attributes(@settings)

            if project_setting.save!
              flash[:notice] = l(:notice_successful_update)
            else
              flash[:error] = l('redmine_timewatch.project_settings.error_update_not_successful')
            end
          end

          redirect_to settings_project_path(@project, :tab => 'rtw_project_settings')
        end

      end

    end
  end
end

