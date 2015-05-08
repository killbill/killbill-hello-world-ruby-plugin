module Killbill::HelloWorld
  class Initializer
    include Singleton

    attr_reader :listener

    def initialize!(conf_dir, kb_apis, logger)
      # Parse the config file
      begin
        @config = YAML.load_file("#{conf_dir}/helloworld.yml") || {}
      rescue Errno::ENOENT
        logger.warn "Unable to find the config file #{conf_dir}/helloworld.yml"
        return
      end

      logger.log_level = Logger::DEBUG if (@config[:logger] || {})[:debug]

      initialize_active_record(@config[:database], logger)

      @listener = UserListener.new(kb_apis, logger)
    end

    def initialized?
      !@listener.nil?
    end

    private

    def initialize_active_record(db_config, logger)
      begin
        require 'active_record'
        require 'arjdbc' if defined?(JRUBY_VERSION)

        if db_config.nil?
          # Sane defaults for running as a Kill Bill plugin
          db_config = {
              :adapter              => :mysql,
              # See KillbillActivator#KILLBILL_OSGI_JDBC_JNDI_NAME
              :jndi                 => 'killbill/osgi/jdbc',
              # See https://github.com/kares/activerecord-bogacs
              :pool                 => false,
              # Since AR-JDBC 1.4, to disable session configuration
              :configure_connection => false
          }
        end

        if defined?(JRUBY_VERSION) && db_config.is_a?(Hash)
          if db_config[:jndi]
            # Lookup the DataSource object once, for performance reasons
            begin
              db_config[:data_source] = Java::JavaxNaming::InitialContext.new.lookup(db_config[:jndi].to_s)
              db_config.delete(:jndi)
            rescue Java::javax.naming.NamingException => e
              # See https://github.com/killbill/killbill-plugin-framework-ruby/issues/39
              logger.warn "Unable to lookup JNDI DataSource (yet?): #{e}" unless defined?(JBUNDLER_CLASSPATH)
            end
          end

          # we accept a **pool: false** configuration in which case we
          # the built-in pool is replaced with a false one (under JNDI) :
          if db_config[:pool] == false && ( db_config[:jndi] || db_config[:data_source] )
            begin; require 'active_record/bogacs'
            pool_class = ::ActiveRecord::Bogacs::FalsePool
            ::ActiveRecord::ConnectionAdapters::ConnectionHandler.connection_pool_class = pool_class
            rescue LoadError
              db_config.delete(:pool) # do not confuse AR's built-in pool
              logger.warn "ActiveRecord-Bogacs missing, will use default (built-in) AR pool."
            end
          end
        end
        ::ActiveRecord::Base.establish_connection(db_config)
        ::ActiveRecord::Base.logger = logger
      rescue => e
        logger.warn "Unable to establish a database connection: #{e}"
      end
    end
  end
end
