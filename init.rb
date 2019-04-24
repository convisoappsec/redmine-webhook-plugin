
require 'redmine'

Rails.logger.info 'Starting Updates Notifier plugin...'

require_dependency 'updates_notifier_issue_change_listener'

Redmine::Plugin.register :redmine_updates_notifier do
  name 'Redmine Updates Notifier plugin'
  author 'Ramesh Nair'
  description 'This sends update notifications to a callback URL when changes are made within Redmine.'
  version '0.1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings :partial => 'settings/updates_notifier_settings',
           :default => {
              'callback_url' => 'http://example.com/callback/' ,
              'ignore_api_changes' => 1
           }
      

end


