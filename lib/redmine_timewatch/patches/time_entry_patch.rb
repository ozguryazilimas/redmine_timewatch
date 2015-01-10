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
            Rails.logger.debug "RTW issue #{issue.id} has total spent hours #{current_spent_time.inspect}"

            settings = RtwProjectSetting.settings_for_project(issue.project_id)
            current_level = settings.calc_level(current_spent_time)
            should_update = (current_spent_time > 0 && current_level == 0.0) || (current_level >= settings.warning_level)

            Rails.logger.debug "RTW should_update:#{should_update.to_s} current_level:#{current_level}"

            if should_update
              current_factor = settings.calc_factor(current_spent_time)
              last_spent_time = RtwNotification.last_spent_time_for_issue(issue)
              last_level = settings.calc_level(last_spent_time)
              last_factor = settings.calc_factor(last_spent_time)

              Rails.logger.debug "RTW current_factor:#{current_factor} last_factor:#{last_factor} last_spent_time:#{last_spent_time} last_level:#{last_level}"

              if (last_level == 0.0) || (current_factor > last_factor)
                Rails.logger.warn "RTW issue #{issue.id} has spent hours #{current_spent_time} is over threshold"

                target_time = (current_factor + 1) * settings.timebase
                RtwNotification.process_spent_time_notification(issue, settings, target_time, current_spent_time)
              end
            end
          end
        end

      end

    end
  end
end

