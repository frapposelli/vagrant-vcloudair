require 'vagrant'

module VagrantPlugins
  module VCloudAir
    module Errors
      # Generic Errors during Vagrant execution
      class VCloudAirGenericError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_vcloudair.errors')
      end
      class VCloudAirOldVersion < VCloudAirGenericError
        error_key(:vcloud_old_version)
      end
      class CatalogAddError < VCloudAirGenericError
        error_key(:catalog_add_error)
      end
      class UnauthorizedAccess < VCloudAirGenericError
        error_key(:unauthorized_access)
      end
      class StopVAppError < VCloudAirGenericError
        error_key(:stop_vapp_error)
      end
      class ComposeVAppError < VCloudAirGenericError
        error_key(:compose_vapp_error)
      end
      class InvalidNetSpecification < VCloudAirGenericError
        error_key(:invalid_network_specification)
      end
      class WontCreate < VCloudAirGenericError
        error_key(:wont_create)
      end
      # Config Error that are caught during Vagrant execution
      class VCloudAirConfigError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_vcloudair.errors.config')
      end
      class ServiceNotFound < VCloudAirConfigError
        error_key(:service_not_found)
      end
      class VdcNotFound < VCloudAirConfigError
        error_key(:vdc_not_found)
      end
      class EdgeGWNotFound < VCloudAirConfigError
        error_key(:edgegw_not_found)
      end
      class EdgeGWIPNotFound < VCloudAirConfigError
        error_key(:edgegw_ip_not_found)
      end
      class EdgeGWNotConnected < VCloudAirConfigError
        error_key(:edgegw_not_connected)
      end
      class ForwardPortCollision < VCloudAirConfigError
        error_key(:forward_port_collision)
      end
      # Errors in the REST API communication
      class VCloudAirRestError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_vcloudair.errors.rest_errors')
      end
      class ObjectNotFound < VCloudAirRestError
        error_key(:object_not_found)
      end
      class InvalidConfigError < VCloudAirRestError
        error_key(:invalid_config_error)
      end
      class InvalidStateError < VCloudAirRestError
        error_key(:invalid_state_error)
      end
      class InvalidRequestError < VCloudAirRestError
        error_key(:invalid_request_error)
      end
      class UnattendedCodeError < VCloudAirRestError
        error_key(:unattended_code_error)
      end
      class EndpointUnavailable < VCloudAirRestError
        error_key(:endpoint_unavailable)
      end
    end
  end
end
