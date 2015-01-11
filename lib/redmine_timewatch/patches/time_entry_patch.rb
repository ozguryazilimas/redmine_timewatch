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
            settings = RtwProjectSetting.settings_for_project(issue.project_id)
            current_spent_time = issue.total_spent_hours

            if (current_spent_time > 0) && settings.is_above_threshold(issue.id, current_spent_time)
              current_factor = settings.calc_factor(current_spent_time)
              target_time = (current_factor + 1) * settings.timebase
              RtwNotification.process_spent_time_notification(issue, settings, target_time, current_spent_time)
            end
          end
        end

      end

    end
  end
end

