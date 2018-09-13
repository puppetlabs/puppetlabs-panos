require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_virtual_router type using the Resource API.
class Puppet::Provider::PanosVirtualRouter::PanosVirtualRouter < Puppet::Provider::PanosProvider
  def munge(entry)
    entry[:ad_static] = '10' if entry[:ad_static].nil?
    entry[:ad_static_ipv6] = '10' if entry[:ad_static_ipv6].nil?
    entry[:ad_ospf_int] = '30' if entry[:ad_ospf_int].nil?
    entry[:ad_ospf_ext] = '110' if entry[:ad_ospf_ext].nil?
    entry[:ad_ospfv3_int] = '30' if entry[:ad_ospfv3_int].nil?
    entry[:ad_ospfv3_ext] = '110' if entry[:ad_ospfv3_ext].nil?
    entry[:ad_ibgp] = '200' if entry[:ad_ibgp].nil?
    entry[:ad_ebgp] = '20' if entry[:ad_ebgp].nil?
    entry[:ad_rip] = '120' if entry[:ad_rip].nil?
    entry
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      if should[:interfaces]
        builder.interface do
          should[:interfaces].each do |interface|
            builder.member(interface)
          end
        end
      end
      builder.__send__('admin-dists') do
        builder.static(should[:ad_static])
        builder.__send__('static-ipv6', should[:ad_static_ipv6])
        builder.__send__('ospf-int', should[:ad_ospf_int])
        builder.__send__('ospf-ext', should[:ad_ospf_ext])
        builder.__send__('ospfv3-int', should[:ad_ospfv3_int])
        builder.__send__('ospfv3-ext', should[:ad_ospfv3_ext])
        builder.ibgp(should[:ad_ibgp])
        builder.ebgp(should[:ad_ebgp])
        builder.rip(should[:ad_rip])
      end
    end
  end
end
