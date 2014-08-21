module VagrantPlugins
  module VCloudAir
    module Action
      class Resume
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::resume')
        end

        def call(env)
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          vm_id = env[:machine].id

          env[:ui].info('Powering on VM...')
          task_id = cnx.poweron_vm(vm_id)
          cnx.wait_task_completion(task_id)

          @app.call env
        end
      end
    end
  end
end
