require 'rubygems'
require 'json'

require 'net/http'
require 'uri'

class UpdatesNotifier < ActiveRecord::Base
  def self.send_update(type, user, entity, journal = false)
    Rails.logger.debug(journal)
    entityId = entity.id
    changes = []
    notes = ''
    if journal
      notes = journal.notes
      journal.details.each do |j|
        changes.push({
          "property" => j.prop_key,
          "value" => j.value
        })
      end
    end
    Rails.logger.debug('going to send some updates!')
    u = {"email" => user.mail, "firstname" => user.firstname, "lastname" => user.lastname}
    post_to_server({
        "type" => type,
        "user" => u,
        "entityId" => entityId,
        "entity" => entity.attributes,
        "comment" => notes,
        "changes" => changes,
    })
  end
private
  def self.callback_url()
    return Setting.plugin_redmine_updates_notifier['callback_url']
  end
  def self.post_to_server(data)
    post_url = URI.parse self.callback_url
    client = Net::HTTP.new post_url.host, post_url.port
    client.use_ssl = (post_url.scheme == "https")

    request = Net::HTTP::Post.new(File.join(post_url.request_uri),{'Content-Type' =>'application/json'})
    request.body = data.to_json
    request['content-type'] = 'application/json'

    Rails.logger.debug("UPDATES_NOTIFIER: Posting update back to " + self.callback_url + ": " + data.to_json)
    begin
      resp = client.request request
    rescue => e
      Rails.logger.error("--------------------------------")
      Rails.logger.error("UPDATES_NOTIFIER: Posting failed: " + e.inspect)
      Rails.logger.error(self.callback_url)
      Rails.logger.error(data.to_s)
      return false
    end

    Rails.logger.debug("UPDATES_NOTIFIER: Response code from " + self.callback_url + ": " + resp.code.to_s)
    return resp
  end
end
