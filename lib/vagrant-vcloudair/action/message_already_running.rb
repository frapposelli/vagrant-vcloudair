module VagrantPlugins
  module VCloudAir
    module Action
      class MessageAlreadyRunning
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_vcloudair.vm.vm_already_running'))
          @app.call(env)
        end
      end
    end
  end
end
