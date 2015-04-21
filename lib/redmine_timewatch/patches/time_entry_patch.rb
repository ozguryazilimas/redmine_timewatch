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
          if issue && issue.project.module_enabled?('timewatch')
            settings = RtwProjectSetting.settings_for_project(issue.project_id)
            current_spent_time = issue.total_spent_hours

            if (current_spent_time > 0)
              # check if issue spent time is approaching threshold
              if settings.is_above_threshold(issue.id, current_spent_time)
                current_factor = settings.calc_factor(current_spent_time)
                target_time = (current_factor + 1) * settings.timebase

                RtwNotification.process_spent_time_notification(
                  issue,
                  settings,
                  target_time,
                  current_spent_time,
                  RtwNotification::TYPE_SPENT
                )
              end

              # check if issue spent time is approaching estimated time
              if settings.notify_on_estimated && RtwNotification.custom_estimated_not_notified(issue)
                target_time = settings.custom_estimated_value(issue)

                if target_time && target_time != 0.0 &&
                  current_spent_time >= (target_time * settings.warning_ratio_estimated / 100.0)
                  # RtwNotification.process_custom_estimated_time_notification(
                  RtwNotification.process_spent_time_notification(
                    issue,
                    settings,
                    target_time,
                    current_spent_time,
                    RtwNotification::TYPE_CUSTOM_ESTIMATED
                  )
                end
              end
            end
          end
        end

      end

    end
  end
end

