require_dependency 'projects_controller'


module RedmineTimewatch
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods

        def rtw_project_settings
          if params[:reset].present?
            RtwProjectSetting.for_project(@project).destroy_all
            flash[:notice] = l(:notice_successful_update)
          else
            @settings = params.require(:settings)
            @settings.permit!
            project_setting = RtwProjectSetting.for_project(@project).first_or_initialize
            sanitized_settings = HashWithIndifferentAccess.new(RtwProjectSetting.sanitize_settings(@settings))
            project_setting.assign_attributes(sanitized_settings)

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

