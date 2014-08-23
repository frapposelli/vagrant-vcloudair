require 'vagrant'
require 'netaddr'

module VagrantPlugins
  module VCloudAir
    class Config < Vagrant.plugin('2', :config)
      # login attributes

      # The Dedicated Cloud to log in to (optional)
      #
      # @return [String]
      attr_accessor :cloud_id

      # The username used to log in
      #
      # @return [String]
      attr_accessor :username

      # The password used to log in
      #
      # @return [String]
      attr_accessor :password

      # Catalog Name where the item resides
      #
      # @return [String]
      attr_accessor :catalog_name

      # Catalog Item to be used as a template
      #
      # @return [String]
      # attr_accessor :catalog_item_name

      # Chunksize for upload in bytes (default 1048576 == 1M)
      #
      # @return [Integer]
      attr_accessor :upload_chunksize

      # Virtual Data Center to be used
      #
      # @return [String]
      attr_accessor :vdc_name

      # Virtual Data Center Network to be used
      #
      # @return [String]
      attr_accessor :vdc_network_name

      # Virtual Data Center Network Id to be used
      #
      # @return [String]
      attr_accessor :vdc_network_id

      # IP allocation type
      #
      # @return [String]
      attr_accessor :ip_allocation_type

      # IP subnet
      #
      # @return [String]
      attr_accessor :ip_subnet

      # DNS
      #
      # @return [Array]
      attr_accessor :ip_dns

      # Bridge Mode
      #
      # @return [Bool]
      attr_accessor :network_bridge

      # Port forwarding rules
      #
      # @return [Hash]
      # attr_reader :port_forwarding_rules

      # Name of the edge gateway [optional]
      #
      # @return [String]
      attr_accessor :vdc_edge_gateway

      # Public IP of the edge gateway [optional, required if :vdc_edge_gateway
      # is specified]
      #
      # @return [String]
      attr_accessor :vdc_edge_gateway_ip

      # Name of the vApp prefix [optional, defaults to 'Vagrant' ]
      #
      # @return [String]
      attr_accessor :vapp_prefix

      ##
      ## vCloud Air config runtime values
      ##

      # connection handle
      attr_accessor :vcloudair_cnx

      # org object (Hash)
      attr_accessor :org

      # org id (String)
      attr_accessor :org_id

      # vdc object (Hash)
      attr_accessor :vdc

      # vdc id (String)
      attr_accessor :vdc_id

      # catalog object (Hash)
      attr_accessor :catalog

      # catalog id (String)
      attr_accessor :catalog_id

      # catalog item object (Hash)
      attr_accessor :catalog_item

      # vApp Name (String)
      attr_accessor :vAppName

      # vApp Id (String)
      attr_accessor :vAppId

      # VM memory size in MB (Integer)
      attr_accessor :memory

      # VM number of cpus (Integer)
      attr_accessor :cpus

      # NestedHypervisor (Bool)
      attr_accessor :nested_hypervisor

      def validate(machine)
        errors = _detected_errors

        errors << I18n.t('vagrant_vcloudair.errors.config.username') if username.nil?
        errors << I18n.t('vagrant_vcloudair.errors.config.password') if password.nil?

        unless ip_dns.nil?
          if ip_dns.kind_of?(Array)
            ip_dns.each do |dns|
              begin
                cidr = NetAddr::CIDR.create(dns)
              rescue NetAddr::ValidationError
                errors << I18n.t('vagrant_vcloudair.errors.config.dns_not_valid')
              end
              if cidr && cidr.bits < 32
                errors << I18n.t('vagrant_vcloudair.errors.config.dns_specified_as_subnet')
              end
            end
          else
            errors << I18n.t('vagrant_vcloudair.errors.config.ip_dns')
          end
        end

        unless vdc_edge_gateway_ip.nil?
          begin
            cidr = NetAddr::CIDR.create(vdc_edge_gateway_ip)
          rescue NetAddr::ValidationError
            errors << I18n.t('vagrant_vcloudair.errors.config.edge_gateway_ip_not_valid')
          end
          if cidr && cidr.bits < 32
            errors << I18n.t('vagrant_vcloudair.errors.config.edge_gateway_ip_specified_as_subnet')
          end
        end

        unless ip_subnet.nil?
          begin
            cidr = NetAddr::CIDR.create(ip_subnet)
          rescue NetAddr::ValidationError
            errors << I18n.t('vagrant_vcloudair.errors.config.ip_subnet_not_valid')
          end
          if cidr && cidr.bits > 30
            errors << I18n.t('vagrant_vcloudair.errors.config.ip_subnet_too_small')
          end
        end

        if catalog_name.nil?
          errors << I18n.t('vagrant_vcloudair.errors.config.catalog_name')
        end

        errors << I18n.t('vagrant_vcloudair.errors.config.vdc_name') if vdc_name.nil?

        if vdc_network_name.nil?
          errors << I18n.t('vagrant_vcloudair.errors.config.vdc_network_name')
        end

        if network_bridge == true && (!vdc_edge_gateway.nil? || !vdc_edge_gateway_ip.nil?)
          errors << I18n.t('vagrant_vcloudair.errors.config.mixed_bridge')
        end

        if (vdc_edge_gateway.nil? && !vdc_edge_gateway_ip.nil?) || (!vdc_edge_gateway.nil? && vdc_edge_gateway_ip.nil?)
          errors << I18n.t('vagrant_vcloudair.errors.config.wrong_edge_configuration')
        end

        { 'VCloudAir Provider' => errors }
      end
    end
  end
end
