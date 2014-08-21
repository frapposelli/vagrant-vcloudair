require 'vagrant'

module VagrantPlugins
  module VCloudAir
    module Errors
      class VCloudAirError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_vcloudair.errors')
      end
      class RsyncError < VCloudAirError
        error_key(:rsync_error)
      end
      class MkdirError < VCloudAirError
        error_key(:mkdir_error)
      end
      class VCloudAirOldVersion < VCloudAirError
        error_key(:vcloud_old_version)
      end
      class CatalogAddError < VCloudAirError
        error_key(:catalog_add_error)
      end
      class UnauthorizedAccess < VCloudAirError
        error_key(:unauthorized_access)
      end
      class StopVAppError < VCloudAirError
        error_key(:stop_vapp_error)
      end
      class ComposeVAppError < VCloudAirError
        error_key(:compose_vapp_error)
      end
      class InvalidNetSpecification < VCloudAirError
        error_key(:invalid_network_specification)
      end
      class WontCreate < VCloudAirError
        error_key(:wont_create)
      end
      class ForwardPortCollision < VCloudAirError
        error_key(:forward_port_collision)
      end
      class SubnetErrors < VCloudAirError
        error_namespace('vagrant_vcloudair.errors.subnet_errors')
      end
      class InvalidSubnet < SubnetErrors
        error_key(:invalid_subnet)
      end
      class SubnetTooSmall < SubnetErrors
        error_key(:subnet_too_small)
      end
      class RestError < VCloudAirError
        error_namespace('vagrant_vcloudair.errors.rest_errors')
      end
      class ObjectNotFound < RestError
        error_key(:object_not_found)
      end
      class InvalidConfigError < RestError
        error_key(:invalid_config_error)
      end
      class InvalidStateError < RestError
        error_key(:invalid_state_error)
      end
      class InvalidRequestError < RestError
        error_key(:invalid_request_error)
      end
      class UnattendedCodeError < RestError
        error_key(:unattended_code_error)
      end
      class EndpointUnavailable < RestError
        error_key(:endpoint_unavailable)
      end
      class ServiceNotFound < RestError
        error_key(:service_not_found)
      end
      class VdcNotFound < RestError
        error_key(:vdc_not_found)
      end
      class EdgeGWNotFound < RestError
        error_key(:edgegw_not_found)
      end
      class EdgeGWIPNotFound < RestError
        error_key(:edgegw_ip_not_found)
      end
      class EdgeGWNotConnected < RestError
        error_key(:edgegw_not_connected)
      end
      class SyncError < VCloudAirError
        error_key(:sync_error)
      end
    end
  end
end
