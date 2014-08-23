module VagrantPlugins
  module VCloudAir
    module Action
      # Override the builtin SSHExec action to show the IP used to connect
      class AnnounceSSHExec < Vagrant::Action::Builtin::SSHExec
        def initialize(app, env)
          @app = app
        end

        def call(env)
          ssh_info = env[:machine].ssh_info
          env[:ui].success(
            I18n.t('vagrant_vcloudair.vm.ssh_announce',
                   machine_name: env[:machine].name,
                   ip: ssh_info[:host])
          )
          super
        end
      end
    end
  end
end
