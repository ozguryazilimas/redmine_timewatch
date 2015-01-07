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
          after_save :timewatch_spent_time_delta
        end
      end

      module ClassMethods

      end

      module InstanceMethods

        def timewatch_spent_time_delta
          if issue
            Rails.logger.info "******** RTW issue: #{issue.id} has total spent hours #{issue.total_spent_hours}"
          end
        end

      end

    end
  end
end

