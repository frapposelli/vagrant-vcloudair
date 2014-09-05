module VagrantPlugins
  module VCloudAir
    module Action
      class DisconnectVCloudAir
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new(
            'vagrant_vcloudair::action::disconnect_vcloud'
          )
        end

        def call(env)
          @logger.info('Disconnecting from vCloud Air...')

          # Fetch the global vCloud Air connection handle
          cnx = env[:machine].provider_config.vcloudair_cnx.driver

          # Delete the current vCloud Air Session
          cnx.logout

          # If session key doesn't exist, we are disconnected
          if !cnx.auth_key
            @logger.info('Disconnected from vCloud Air successfully!')
          else
            fail Errors::VCloudAirGenericError, :message => e.message
          end
        end
      end
    end
  end
end
