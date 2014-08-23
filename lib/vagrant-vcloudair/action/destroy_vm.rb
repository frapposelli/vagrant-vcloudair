module VagrantPlugins
  module VCloudAir
    module Action
      class DestroyVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::destroy_vm')
        end

        def call(env)
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver
          vapp_id = env[:machine].get_vapp_id
          vm_id = env[:machine].id

          cfg.org = cnx.get_organization_by_name(cfg.vdc_name)
          cfg.vdc_id = cnx.get_vdc_id_by_name(cfg.org, cfg.vdc_name)

          test_vapp = cnx.get_vapp(vapp_id)

          @logger.debug(
            "Number of VMs in the vApp: #{test_vapp[:vms_hash].count}"
          )

          env[:ui].info(I18n.t('vagrant_vcloudair.vm.destroy_vm'))
          vm_delete_task = cnx.delete_vm(vm_id)
          @logger.debug("VM Delete task id #{vm_delete_task}")
          cnx.wait_task_completion(vm_delete_task)

          env[:machine].id = nil

          @app.call env
        end
      end
    end
  end
end
