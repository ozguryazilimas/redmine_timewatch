# Timewatch

Based on spend time logs on Redmine, Timewatch informs user with email, also it allows you to update issues automatically.

This plugin is compatible with Redmine 4.x and 5.x. If you want to use it with Redmine 3.x please use redmine3 branch.

## Features

1. Custom Time Threshold Notification: When total spent time entered in the issue exceeds specified time interval value in plugin settings (e.g. 10 hours) also the rate specified in the plugin settings (e.g. 80%), new entry is added in the issue.
2. Estimated Time Threshold Notification: In the project, when the total value entered into custom field in decimal type exceeds the rate specified in plugin settings (e.g. 80%), new entry is added in the issue.
3. Entries in the issue can be customized.
4. You can configure timewatch to save different settings for each project.

## Settings

* As well as default settings can be saved, configuring timewatch to save different setting for each project is possible. Plugin settings are accessible at /administration/plugins/redmine_timewatch_plugin address with administration account by clicking 'Configure'.
* The feature which will be used should be enabled. Two separate features can be activate or passivate.
* Notification time base interval in hours: It is time interval value to take as a percentage.
* Warning ratio (%): It is warning time interval to take as a percentage.

Example:

Notification time base interval in hours: 10
Warning ratio (%): 80

In each 10 hour period with these settings, after +8 hours, the system sends message which is specified in the settings.
If  time log is entered in the issue e.g. 7 hours, it will not react. When the time will be 8 hours, the system sends warning message. If spend time is between 8 and 10 hours, there will no warning message in the issue. Because the message has been already sent about 8th hour, the warning message will not send at 9th hour. It will send at 18th hour.

* Email subject: It is the subject of warning email will be sent.
* Email recipients: The adresses to send warning email are written here. Multiple addresses are separated by comma. (example@example.com, example2@example.com)
* Email template: It is the template of email will be sent. To show the issue number in Redmine, ISSUE_NUMBER is used. ISSUE_SPENT_TIME / ISSUE_CUSTOM_ESTIMATED_TIME is used for threshold time value.
* Custom field for estimated time: Custom field which is took care of by timewatch plugin is selected. For this, you should add a custom field in 'decimal number' type  into related project.

## License

Copyright (c) 2015, Onur Küçük. Licensed under [GNU GPLv2](LICENSE)


