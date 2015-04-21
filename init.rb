require 'redmine_timewatch'

Redmine::Plugin.register :redmine_timewatch do
  name 'Redmine Timewatch plugin'
  author 'Onur Kucuk'
  description 'Redmine plugin to track time_entry changes and setup alarms'
  version '1.0.0'
  url 'http://www.ozguryazilim.com.tr'
  author_url 'http://www.ozguryazilim.com.tr'
  requires_redmine :version_or_higher => '2.5.2'


  project_module :timewatch do
    permission :rtw_timewatch, {:projects => [:rtw_project_settings]}, :require => :member
  end


  settings :partial => 'redmine_timewatch/settings',
    :default => {
      :notify_on_custom => false,
      :timebase => 10,
      :warning_ratio => 75,
      :recipients => '',
      :email_subject => 'Harcanan zaman uyarısı',
      :email_template => '' +
        "ISSUE_NUMBER işi için harcanan zaman ISSUE_SPENT_TIME saate yaklaşmaktadır." +
        "Bu işe daha fazla zaman harcanmamasını istiyorsanız lütfen iş kaydına yazarak belirtiniz.\r\n" +
        "\r\n" +
        "Bu iş için yapılanları işteki kayıtlardan öğrenebilir, açıklamaları yeterli bulmamanız halinde" +
        "daha detaylı açıklama isteğinizi işe yazarak belirtebilirsiniz. Ekibimiz daha detaylı açıklama yapacaktır.\r\n" +
        "\r\n" +
        "Teşekkürler,\r\n" +
        "İşlerGüçler Robotu\r\n",
      :notify_on_estimated => false,
      :custom_field_id => 0,
      :warning_ratio_estimated => 100,
      :email_subject_estimated => 'Harcanan zaman uyarısı',
      :recipients_estimated => '',
      :email_template_estimated => '' +
        "ISSUE_NUMBER işi için harcanan zaman tahmin edilen ISSUE_CUSTOM_ESTIMATED_TIME saate yaklaşmaktadır." +
        "Bu işe daha fazla zaman harcanmamasını istiyorsanız lütfen iş kaydına yazarak belirtiniz.\r\n" +
        "\r\n" +
        "Bu iş için yapılanları işteki kayıtlardan öğrenebilir, açıklamaları yeterli bulmamanız halinde" +
        "daha detaylı açıklama isteğinizi işe yazarak belirtebilirsiniz. Ekibimiz daha detaylı açıklama yapacaktır.\r\n" +
        "\r\n" +
        "Teşekkürler,\r\n" +
        "İşlerGüçler Robotu\r\n",
    }

end

Rails.configuration.to_prepare do
  [
    [TimeEntry, RedmineTimewatch::Patches::TimeEntryPatch],
    [ProjectsController, RedmineTimewatch::Patches::ProjectsControllerPatch],
    [ProjectsHelper, RedmineTimewatch::Patches::ProjectsHelperPatch],
    [Mailer, RedmineTimewatch::Patches::MailerPatch]
  ].each do |classname, modulename|
    unless classname.included_modules.include?(modulename)
      classname.send(:include, modulename)
    end
  end

end

