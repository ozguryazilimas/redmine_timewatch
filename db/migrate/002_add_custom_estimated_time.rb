class AddCustomEstimatedTime < ActiveRecord::Migration

  def change
    add_column :rtw_project_settings, :notify_on_custom, :boolean, :default => false, :null => false
    add_column :rtw_project_settings, :notify_on_estimated, :boolean, :default => false, :null => false
    add_column :rtw_project_settings, :custom_field_id, :integer, :null => false
    add_column :rtw_project_settings, :warning_ratio_estimated, :integer, :default => 100
    add_column :rtw_project_settings, :email_subject_estimated, :string
    add_column :rtw_project_settings, :recipients_estimated, :text
    add_column :rtw_project_settings, :email_template_estimated, :text

    add_column :rtw_notifications, :custom_estimated_time, :float
    add_column :rtw_notifications, :custom_estimated_id, :integer
    add_column :rtw_notifications, :notification_type, :string, :default => 'spent', :null => false
  end

end

