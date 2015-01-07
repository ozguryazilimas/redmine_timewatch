require 'redmine_timewatch'

Redmine::Plugin.register :redmine_timewatch do
  name 'Redmine Timewatch plugin'
  author 'Onur Kucuk'
  description 'Redmine plugin to track time_entry changes and setup alarms'
  version '0.1.0'
  url 'http://www.ozguryazilim.com.tr'
  author_url 'http://www.ozguryazilim.com.tr'
  requires_redmine :version_or_higher => '2.5.2'

  settings :partial => 'redmine_timewatch/settings',
    :default => {
      :timebase => 10,
      :warning_ratio => 75,
      :recipients => '',
      :email_template => '' +
        "ISSUE_NUMBER işi için harcanan zaman ISSUE_SPENT_TIME saate yaklaşmaktadır." +
        "Bu işe daha fazla zaman harcanmamasını istiyorsanız lütfen iş kaydına yazarak belirtiniz.\n" +
        "\n" +
        "Bu iş için yapılanları işteki kayıtlardan öğrenebilir, açıklamaları yeterli bulmamanız halinde" +
        "daha detaylı açıklama isteğinizi işe yazarak belirtebilirsiniz. Ekibimiz daha detaylı açıklama yapacaktır.\n" +
        "\n" +
        "Teşekkürler,\n" +
        "İşlerGüçler Robotu\n"
    }
end

Rails.configuration.to_prepare do
  [
    [TimeEntry, RedmineTimewatch::Patches::TimeEntryPatch]
  ].each do |classname, modulename|
    unless classname.included_modules.include?(modulename)
      classname.send(:include, modulename)
    end
  end

end
