require 'puppet/util/network_device/simple/device'

module Puppet::Util::NetworkDevice::Panos
  # The main connection class to a PAN-OS API endpoint
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def facts
      {}
    end

    def get_config(xpath)
      # https://<firewall>/api/?key=apikey&type=config&action=get&xpath=<path-to-config-node>
    end

    def set_config(xpath, element)
      # https://<firewall>/api/?key=apikey&type=config&action=set&xpath=xpath-value&element=element-value
    end

    def delete_config(xpath)
      # https://<firewall>/api/?key=apikey&type=config&action=delete&xpath=xpath-value
    end
  end
end
