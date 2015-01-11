require File.expand_path('../../test_helper', __FILE__)

class RtwProjectSettingTest < ActiveSupport::TestCase

  fixtures :projects, :trackers, :issue_statuses, :issues

  # rake redmine:plugins:test NAME=redmine_timewatch
  def test_is_above_threshold
    issue = issues(:issues_001)
    project = issue.project
    timebase = 4
    warning_ratio = 75

    settings = RtwProjectSetting.settings_for_project(project.id)
    settings.timebase = timebase
    settings.warning_ratio = warning_ratio
    settings.save!

    # last_spent_time, current_spent_time, expected result
    scenarios = [
      [0.0, 0, false],
      [0.0, 0.0, false],
      [0.0, 0.5, false],
      [0.0, 1.5, false],
      [0.0, 2.5, false],
      [0.0, 3.0, true],
      [0.0, 3.75, true],
      [0.0, 4.0, true],
      [0.0, 4.5, true],
      [0.0, 7.5, true],
      [0.0, 25.0, true],

      [2.0, 3.0, true],
      [2.0, 3.75, true],
      [2.0, 4.0, true],
      [2.0, 4.5, true],
      [2.0, 7.5, true],
      [2.0, 25.0, true],

      [3.0, 3.0, false],
      [3.0, 3.75, false],
      [3.0, 4.0, false],
      [3.0, 4.5, false],
      [3.0, 7.5, true],
      [3.0, 25.0, true],

      [4.0, 5.0, false],
      [4.0, 6.0, false],
      [4.0, 7.0, true],
      [4.0, 7.5, true],
      [4.0, 8.0, true],
      [4.0, 9.0, true],

      [7.0, 7.5, false],
      [7.0, 8.0, false],
      [7.0, 10.0, false],
      [7.0, 11.0, true]
    ]

    puts "\n"
    puts "timebase: #{timebase}\nwarning_ratio: #{warning_ratio}%\n"
    puts "\n"

    scenarios.each do |scenario|
      last_spent_time, current_spent_time, expected = scenario

      RtwNotification.destroy_all
      if last_spent_time > 0
        rtwn = RtwNotification.create(
          :issue_id => issue.id,
          :spent_time => last_spent_time,
          :timebase => settings.timebase,
          :warning_ratio => settings.warning_ratio,
          :recipients => settings.recipients
        )
      end

      calculated = settings.is_above_threshold(issue.id, current_spent_time)
      puts "previous: #{last_spent_time}\tcurrent: #{current_spent_time}\texpected: #{expected}\tcalculated: #{calculated}\n"
      assert expected == calculated
    end
  end

end

