#
#  Copyright 2012 Stefano Tortarolo
#  Copyright 2013 Fabio Rapposelli and Timo Sugliani
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#   limitations under the License.
#

require 'forwardable'
require 'log4r'
require 'nokogiri'
require 'httpclient'

require File.expand_path('../base', __FILE__)

module VagrantPlugins
  module VCloudAir
    module Driver
      class Meta < Base
        # We use forwardable to do all our driver forwarding
        extend Forwardable
        attr_reader :driver

        def initialize(cloud_id, username, password, vdc_name)
          # Setup the base
          super()

          @username = username
          @password = password

          @logger = Log4r::Logger.new('vagrant::provider::vcloudair::meta')

          # Logging into vCloud Air
          params = {
            'method'  => :post,
            'command' => '/vchs/sessions'
          }

          _response, headers = send_vcloudair_request(params)

          unless headers.key?('x-vchs-authorization')
            fail Errors::InvalidRequestError,
                 :message => 'Failed to authenticate: ' \
                             'missing x-vchs-authorization header'
          end

          @vcloudair_auth_key = headers['x-vchs-authorization']

          # Get Services available
          params = {
            'method'  => :get,
            'command' => '/vchs/services'
          }

          response, _headers = send_vcloudair_request(params)
          services = response.css('Services Service')

          service_id = cloud_id || vdc_name
          services.each do |service|
            if service['serviceId'] == service_id
              @compute_id = URI(service['href']).path.gsub('/api', '')
            end
          end

          fail Errors::ServiceNotFound if @compute_id.nil?

          # Get Service Link to vCloud Director
          params = {
            'method'  => :get,
            'command' => @compute_id
          }

          response, _headers = send_vcloudair_request(params)

          vdcs = response.css('Compute VdcRef')

          vdcs.each do |vdc|
            if vdc['name'] == vdc_name
              @vdc_id = URI(vdc['href']).path.gsub('/api', '')
            end
          end

          fail Errors::VdcNotFound, :message => vdc_name if @vdc_id.nil?

          # Authenticate to vCloud Director
          params = {
            'method'  => :post,
            'command' => "#{@vdc_id}/vcloudsession"
          }

          response, _headers = send_vcloudair_request(params)

          vdclinks = response.css('VCloudSession VdcLink')

          vdclinks.each do |vdclink|
            if vdclink['name'] == service_id
              uri = URI(vdclink['href'])
              @api_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/api"
              @host_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
              @auth_key = vdclink['authorizationToken']
            end
          end

          fail Errors::ObjectNotFound,
               :message => 'Cannot find link to backend \
               vCloud Director Instance' if @api_url.nil?

          @org_name = vdc_name

          # Read and assign the version of vCloud Air we know which
          # specific driver to instantiate.
          @logger.debug("Asking API Version with host_url: #{@host_url}")
          @version = get_api_version(@host_url) || ''

          # Instantiate the proper version driver for vCloud Air
          @logger.debug("Finding driver for vCloud Air version: #{@version}")
          driver_map   = {
            '5.1' => Version_5_1,
            '5.5' => Version_5_1,
            '5.6' => Version_5_1,
            '5.7' => Version_5_1
          }

          if @version.start_with?('0.9') ||
             @version.start_with?('1.0') ||
             @version.start_with?('1.5')
            # We only support vCloud Air 5.1 or higher.
            fail Errors::VCloudAirOldVersion, :version => @version
          end

          driver_klass = nil
          driver_map.each do |key, klass|
            if @version.start_with?(key)
              driver_klass = klass
              break
            end
          end

          unless driver_klass
            supported_versions = driver_map.keys.sort.join(', ')
            fail Errors::VCloudAirInvalidVersion,
                 :supported_versions => supported_versions
          end

          @logger.info("Using vCloud Air driver: #{driver_klass}")
          @driver = driver_klass.new(@api_url, @host_url, @auth_key, @org_name)
        end

        def_delegators  :@driver,
                        :login,
                        :logout,
                        :get_organizations,
                        :get_organization_id_by_name,
                        :get_organization_by_name,
                        :get_organization,
                        :get_catalog,
                        :get_catalog_id_by_name,
                        :get_catalog_by_name,
                        :get_vdc,
                        :get_vdc_id_by_name,
                        :get_vdc_by_name,
                        :get_catalog_item,
                        :get_catalog_item_by_name,
                        :get_vapp,
                        :delete_vapp,
                        :poweroff_vapp,
                        :suspend_vapp,
                        :reboot_vapp,
                        :reset_vapp,
                        :poweron_vapp,
                        :create_vapp_from_template,
                        :compose_vapp_from_vm,
                        :get_vapp_template,
                        :set_vapp_port_forwarding_rules,
                        :get_vapp_port_forwarding_rules,
                        :get_vapp_edge_public_ip,
                        :upload_ovf,
                        :get_task,
                        :wait_task_completion,
                        :set_vapp_network_config,
                        :set_vm_network_config,
                        :set_vm_guest_customization,
                        :get_vm,
                        :send_request,
                        :upload_file,
                        :convert_vapp_status

        protected

      end
    end
  end
end
