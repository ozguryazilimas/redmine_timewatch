class CreateModelBase < ActiveRecord::Migration[4.2]

  def change
    create_table :rtw_notifications do |t|
      t.integer :issue_id
      t.float :spent_time
      t.integer :timebase
      t.integer :warning_ratio
      t.text :recipients

      t.timestamps
    end

    create_table :rtw_project_settings do |t|
      t.integer :project_id
      t.integer :timebase
      t.integer :warning_ratio
      t.string :email_subject
      t.text :recipients
      t.text :email_template

      t.timestamps
    end
  end

end

