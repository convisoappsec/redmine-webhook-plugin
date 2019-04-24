require 'rubygems'
require 'ostruct'

class UpdatesNotifierIssueChangeListener < Redmine::Hook::Listener
  def controller_issues_bulk_edit_after_save(context={})
    controller_issues_edit_after_save(context)
  end
  def controller_issues_edit_after_save(context={})
    if !Setting.plugin_redmine_updates_notifier[:ignore_api_changes] or !context[:params][:format] or 'xml' != context[:params][:format]
      if context[:issue] and context[:journal]
        currentUser = User.current
        Thread.new(currentUser, context) { |currentUser, context|
          UpdatesNotifier.send_update('issue-edit', currentUser, context[:issue], context[:journal])
        }.run
      end
    end
  end
  def controller_issues_new_after_save(context={})
    if !Setting.plugin_redmine_updates_notifier[:ignore_api_changes] or !context[:params][:format] or 'xml' != context[:params][:format]
      if context[:issue]
        currentUser = User.current
        Thread.new(currentUser, context) { |currentUser, context|
          UpdatesNotifier.send_update('issue-new', currentUser, context[:issue])
        }.run
      end
    end
  end
  def controller_issues_destroy(context={})
    Rails.logger.error('issue is destroyd')
    Rails.logger.error(context[:issue])
    
    if !Setting.plugin_redmine_updates_notifier[:ignore_api_changes] or !context[:params][:format] or 'xml' != context[:params][:format]
      if context[:issue]
        currentUser = User.current
        Thread.new(currentUser, context) { |currentUser, context|
          UpdatesNotifier.send_update('issue-destroy', currentUser, context[:issue])
        }.run
      end
    end
  end
  def controller_projects_new_after_save(context={})
    Rails.logger.error("### issue new project, hook is run!")
    Rails.logger.error("### new entry for listener. Context:")
    Rails.logger.error(context.inspect)
    Rails.logger.error(context[:params][:format])
    Rails.logger.error(context[:project])
    if !Setting.plugin_redmine_updates_notifier[:ignore_api_changes] or !context[:params][:format] or 'xml' != context[:params][:format]
      if context[:project] 
        currentUser = User.current
        Thread.new(currentUser, context) { |currentUser, context|
        Rails.logger.error("### project new safe after, inside thread!")
          UpdatesNotifier.send_update('project-new', currentUser, context[:project])
        }.run
      end
    end
  end
end

