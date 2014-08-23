module VagrantPlugins
  module VCloudAir
    module Action
      class MessageCannotSuspend
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_vcloudair.vm.vm_halted_cannot_suspend'))
          @app.call(env)
        end
      end
    end
  end
end
