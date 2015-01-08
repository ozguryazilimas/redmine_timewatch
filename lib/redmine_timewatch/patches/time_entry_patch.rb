require_dependency 'time_entry'


module RedmineTimewatch
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          # alias_method_chain :update, :redmine_timewatch
          after_save :timewatch_spent_time_notify
        end
      end

      module ClassMethods

      end

      module InstanceMethods

        def timewatch_spent_time_notify
          if issue
            current_spent_time = issue.total_spent_hours
            Rails.logger.debug "RTW issue #{issue.id} has total spent hours #{current_spent_time}"

            settings = RtwProjectSetting.settings_for_project(issue.project_id)
            current_level = settings.calc_level(current_spent_time)

            if current_level >= settings.warning_level
              current_factor = settings.calc_factor(current_spent_time)
              last_spent_time = RtwNotification.last_spent_time_for_issue(issue)
              last_factor = settings.calc_factor(last_spent_time)

              if current_factor > last_factor
                Rails.logger.info "RTW issue #{issue.id} has spent hours #{current_spent_time} is over threshold"
                RtwNotification.process_spent_time_notification(issue, settings)
              end
            end
          end
        end

      end

    end
  end
end

