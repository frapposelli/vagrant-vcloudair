module VagrantPlugins
  module VCloudAir
    module Action
      class PowerOffVApp
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::poweroff_vapp')
        end

        def call(env)
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          vapp_id = env[:machine].get_vapp_id

          test_vapp = cnx.get_vapp(vapp_id)

          @logger.debug(
            "Number of VMs in the vApp: #{test_vapp[:vms_hash].count}"
          )

          # this is a helper to get vapp_edge_ip into cache for later destroy
          # of edge gateway rules
          vapp_edge_ip = cnx.get_vapp_edge_public_ip(vapp_id) if cfg.network_bridge.nil?

          # Poweroff vApp
          env[:ui].info(I18n.t('vagrant_vcloudair.vapp.poweroff_vapp'))
          vapp_stop_task = cnx.poweroff_vapp(vapp_id)
          vapp_stop_wait = cnx.wait_task_completion(vapp_stop_task)

          unless vapp_stop_wait[:errormsg].nil?
            fail Errors::StopVAppError, :message => vapp_stop_wait[:errormsg]
          end

          @app.call env
        end
      end
    end
  end
end
