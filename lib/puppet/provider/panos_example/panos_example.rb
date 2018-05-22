require 'puppet/resource_api/simple_provider'

# Implementation for the panos_example type using the Resource API.
class Puppet::Provider::PanosExample::PanosExample < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.device.get_config("/config/devices/entry/vsys/entry[@name='vsys1']")
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    context.device.set_config("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='#{name}']", should)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    context.device.set_config("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='#{name}']", should)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    context.device.delete_config("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='#{name}']")
  end
end
