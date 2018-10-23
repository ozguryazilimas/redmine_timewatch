require_dependency 'projects_controller'


module RedmineTimewatch
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods

        def rtw_project_settings
          @settings = params[:settings]

          if params[:reset].present?
            RtwProjectSetting.destroy_all(:project_id => @project.id)
            flash[:notice] = l(:notice_successful_update)
          else
            project_setting = RtwProjectSetting.for_project(@project).first_or_initialize
            project_setting.assign_attributes(RtwProjectSetting.sanitize_settings(@settings))

            if project_setting.save!
              flash[:notice] = l(:notice_successful_update)
            else
              flash[:error] = l('redmine_timewatch.project_settings.error_update_not_successful')
            end
          end

          redirect_to settings_project_path(@project, :tab => 'rtw_project_settings')

        rescue ActiveRecord::RecordInvalid => e
          err_msg = project_setting.errors.messages.map do |k, v|
            attr_key = I18n.t("activerecord.attributes.rtw_project_setting.#{k}")
            "#{attr_key} #{v.to_sentence}"
          end

          flash[:error] = err_msg.join(', ')
          redirect_to settings_project_path(@project, :tab => 'rtw_project_settings')
        end

      end

    end
  end
end

