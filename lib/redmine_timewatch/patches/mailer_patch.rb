require_dependency 'mailer'


module RedmineTimewatch
  module Patches
    module MailerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods

        def timewatch_spent_time_over_threshold(user, issue, mail_body, mail_subject, mail_recipients, target_time, target_type)
          redmine_headers 'Project' => issue.project.identifier,
                          'Issue-Id' => issue.id,
                          'Issue-Author' => issue.author.login
          redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to

          message_id issue
          references issue
          recipients = mail_recipients
          # @author = ?
          @issue = issue
          @body = mail_body
          @subject = mail_subject
          @target_time = target_time
          @for_type = target_type
          @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

          mail :to => recipients,
            :subject => mail_subject
        end

      end
    end
  end
end

