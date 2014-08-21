require 'log4r'
require 'vagrant'

module VagrantPlugins
  module VCloudAir
    class Provider < Vagrant.plugin('2', :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        env = @machine.action('read_ssh_info')
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action('read_state')

        state_id = env[:machine_state_id]

        # Translate into short/long descriptions
        short = state_id.to_s.gsub('_', ' ')
        long  = I18n.t("vagrant_vcloudair.states.#{state_id}")

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? 'new' : @machine.id
        "vCloud Air (#{id})"
      end
    end
  end
end
