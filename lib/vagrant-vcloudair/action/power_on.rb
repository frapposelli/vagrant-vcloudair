module VagrantPlugins
  module VCloudAir
    module Action
      class PowerOn
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::power_on')
        end

        def call(env)
          @env = env

          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          env[:ui].info(I18n.t('vagrant_vcloudair.vm.setting_vm_hardware'))

          set_vm_hardware = cnx.set_vm_hardware(env[:machine].id, cfg)
          cnx.wait_task_completion(set_vm_hardware) if set_vm_hardware

          env[:ui].info(I18n.t('vagrant_vcloudair.vm.poweron_vm'))

          unless cfg.nested_hypervisor.nil?
            set_vm_nested_hypervisor = cnx.set_vm_nested_hypervisor(
                                       env[:machine].id, cfg.nested_hypervisor)
            if set_vm_nested_hypervisor
              cnx.wait_task_completion(set_vm_nested_hypervisor)
            end
          end

          poweron_vm = cnx.poweron_vm(env[:machine].id)
          cnx.wait_task_completion(poweron_vm)

          @app.call(env)
        end
      end
    end
  end
end
