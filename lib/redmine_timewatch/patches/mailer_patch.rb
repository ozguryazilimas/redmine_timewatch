require_dependency 'mailer'


module RedmineTimewatch
  module Patches
    module MailerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do

          def self.deliver_timewatch_spent_time_over_threshold(mail_recipients, args)
            Rails.logger.info "RTW sending email to #{mail_recipients.inspect} for args #{args.inspect}"

            timewatch_spent_time_over_threshold(
              User.anonymous,
              mail_recipients,
              args
            ).deliver_later
          end

        end
      end

      module InstanceMethods

        def timewatch_spent_time_over_threshold(_user, recipient_email, args)
          issue = args[:issue]

          redmine_headers 'Project' => issue.project.identifier,
                          'Issue-Id' => issue.id,
                          'Issue-Author' => issue.author.login
          redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
          redmine_headers 'Timewatch-Type' => args[:type]

          message_id issue
          references issue
          # @author = ?
          @issue = issue
          @body = args[:template]
          @subject = args[:subject]
          @target_time = args[:arget_time]
          @for_type = args[:type]
          @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

          mail :to => recipient_email,
            :subject => @subject
        end

      end
    end
  end
end

