module VagrantPlugins
  module VCloudAir
    module Action
      class ConnectVCloudAir
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::connect_vcloud')
        end

        def call(env)
          config = env[:machine].provider_config

          if !config.vcloudair_cnx || !config.vcloudair_cnx.driver.auth_key
            @logger.info('Connecting to vCloud Air...')

            @logger.debug("config.cloud_id: #{config.cloud_id}") unless config.cloud_id.nil?
            @logger.debug("config.username: #{config.username}")
            @logger.debug('config.password: <hidden>')
            @logger.debug("config.vdc_name: #{config.vdc_name}")

            # Create the vcloud-rest connection object with the configuration
            # information.
            config.vcloudair_cnx = Driver::Meta.new(
              config.cloud_id,
              config.username,
              config.password,
              config.vdc_name
            )

            @logger.info('Logging into vCloud Air...')
            # config.vcloudair_cnx.login

            # Check for the vCloud Air authentication token
            if config.vcloudair_cnx.driver.auth_key
              @logger.info('Logged in successfully!')
              @logger.debug(
                "x-vcloud-authorization=#{config.vcloudair_cnx.driver.auth_key}"
              )
            else
              @logger.info("Login failed in to #{config.hostname}.")
              fail Errors::UnauthorizedAccess
            end
          else
            @logger.info('Already logged in, using current session')
            @logger.debug(
                "x-vcloud-authorization=#{config.vcloudair_cnx.driver.auth_key}"
            )
          end
          @app.call env
        end
      end
    end
  end
end
