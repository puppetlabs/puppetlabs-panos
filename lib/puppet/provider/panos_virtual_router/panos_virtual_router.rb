require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_virtual_router type using the Resource API.
class Puppet::Provider::PanosVirtualRouter::PanosVirtualRouter < Puppet::Provider::PanosProvider
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
      if [
        should[:ad_static], should[:ad_static_ipv6],
        should[:ad_ospf_int], should[:ad_ospf_ext],
        should[:ad_ospfv3_int], should[:ad_ospfv3_ext],
        should[:ad_ibgp], should[:ad_ebgp],
        should[:ad_rip]
      ].all?
        builder.__send__('admin-dists') do
          builder.static(should[:ad_static]) if should[:ad_static]
          builder.__send__('static-ipv6', should[:ad_static_ipv6]) if should[:ad_static_ipv6]
          builder.__send__('ospf-int', should[:ad_ospf_int]) if should[:ad_ospf_int]
          builder.__send__('ospf-ext', should[:ad_ospf_ext]) if should[:ad_ospf_ext]
          builder.__send__('ospfv3-int', should[:ad_ospfv3_int]) if should[:ad_ospfv3_int]
          builder.__send__('ospfv3-ext', should[:ad_ospfv3_ext]) if should[:ad_ospfv3_ext]
          builder.ibgp(should[:ad_ibgp]) if should[:ad_ibgp]
          builder.ebgp(should[:ad_ebgp]) if should[:ad_ebgp]
          builder.rip(should[:ad_rip]) if should[:ad_rip]
        end
      end
    end
  end
end
