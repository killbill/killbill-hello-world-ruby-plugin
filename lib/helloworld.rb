require 'active_record'
require 'sinatra'

require 'killbill'

require 'helloworld/user'
require 'helloworld/user_listener'
require 'helloworld/initializer'

module Killbill::HelloWorld
  class HelloWorldPlugin < Killbill::Plugin::Notification

    def start_plugin
      super
      @listener = Killbill::HelloWorld::Initializer.instance.initialize!(@conf_dir, @kb_apis, @logger)
    end

    def after_request
      # return DB connections to the Pool if required
      ActiveRecord::Base.connection.close
    end

    def on_event(event)
      @listener.update(event.account_id) if [:ACCOUNT_CREATION, :ACCOUNT_CHANGE].include?(event.event_type)
    end
  end
end
