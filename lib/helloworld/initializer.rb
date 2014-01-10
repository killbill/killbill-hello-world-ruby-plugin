module Killbill::HelloWorld
  class Initializer
    include Singleton

    attr_reader :listener

    def initialize!(conf_dir, kb_apis, logger)
      # Parse the config file
      begin
        @config = YAML.load_file("#{conf_dir}/helloworld.yml")
      rescue Errno::ENOENT
        logger.warn "Unable to find the config file #{conf_dir}/helloworld.yml"
        return
      end

      logger.log_level = Logger::DEBUG if (@config[:logger] || {})[:debug]

      if defined?(JRUBY_VERSION)
        # See https://github.com/jruby/activerecord-jdbc-adapter/issues/302
        require 'jdbc/mysql'
        Jdbc::MySQL.load_driver(:require) if Jdbc::MySQL.respond_to?(:load_driver)
      end

      ActiveRecord::Base.establish_connection(@config[:database])
      ActiveRecord::Base.logger = logger

      @listener = UserListener.new(kb_apis, logger)
    end

    def initialized?
      !@listener.nil?
    end
  end
end
