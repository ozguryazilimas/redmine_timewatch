class AllowBlankProjectSetting < ActiveRecord::Migration[5.2]

  def change
    change_column :rtw_project_settings, :notify_on_custom, :boolean, :default => false, :null => true
    change_column :rtw_project_settings, :notify_on_estimated, :boolean, :default => false, :null => true
    change_column :rtw_project_settings, :custom_field_id, :integer, :null => true
  end

end

