module VagrantPlugins
  module VCloudAir
    module Action
      class MessageAlreadyRunning
        def initialize(app, env)
          @app = app
        end

        def call(env)
          # FIXME: This error should be categorized
          env[:ui].info(I18n.t('vagrant_vcloudair.vm_already_running'))
          @app.call(env)
        end
      end
    end
  end
end
