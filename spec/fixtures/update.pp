# bundle exec puppet device --modulepath spec/fixtures/modules/ --deviceconfig spec/fixtures/device.conf --target pavm --verbose --trace --apply tests/test_commit.pp

panos_address {
  'address-3':
    ip_range    => '192.168.0.1-192.168.0.18',
    description => '<eas&lt;yxss/>';
  'source_address':
    ip_netmask => '10.20.1.0';
  'SAT_address':
    ip_netmask => '10.20.1.1';
  'SAT_static_address':
    ip_netmask => '10.30.1.0/32';
  'fallback_address':
    ip_netmask  => '10.10.1.0';
  'destination_address':
    ip_netmask => '10.30.1.0';
  'DAT_address':
    ip_netmask => '10.30.1.1';
  'fqdn':
    fqdn  =>  'google-public-dns-b.google.com';
}

panos_address_group {
  'full':
    description    => 'address group with static contents, and an existing address group',
    type           => 'static',
    static_members => ['source_address', 'minimal address group'];
    # tags           => ['tests'];
  'dynamic group':
    description    => 'address group with dynamic contents',
    type           => 'dynamic',
    dynamic_filter => "'tag1' or 'tag2' and 'tag3'";
    # tags           => ['tests'],
}

panos_admin {
  'minimal':
    ensure  =>  'present',
    role    =>  'deviceadmin';
  'superreader':
    ensure  =>  'present',
    role    =>  'superreader';
  'deviceadmin':
    ensure  =>  'present',
    role    =>  'deviceadmin';
  'devicereader':
    ensure  =>  'present',
    role    =>  'devicereader';
  'password_hash':
    ensure        =>  'present',
    password_hash =>  '$1$ulcyeqla$aRLxytbonTjxFMNWjjjOL0',
    ssh_key       =>  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/qU86rQHw+iwX1714ZrntMz0BAsxgrsxHjQF2SHZhJ1MP541y0tSId8ZnVxATIfI3JADv9cw5wFq09fWzi7BQBd4p2UO7mMx0wxzSrONWb62lzpspCAe27kZfrtedc7x5GVGtns4bQxloTDFHXcvtQrC8j3avBb1ZdAs6TMvYAX8eSZ8UOcMIGHY6Go2QbhDnnh1+oDBqqQZNjAJas5PS5bvX9C6/dWYlfjJkPpsoG7tTKkAq2otFCcqq70kAEOlQ6VDyZsOzJjKZ/C6o9mosg+v5CXrp2cdo2Gc6p9ezEAcZb+vzQDwXJeGcp4ewIyX0x03kiMr8BUE/cpJwsg6D david@davids',
    role          =>  'devicereader';
  'authentication_profile':
    ensure        =>  'present',
    password_hash =>  '$1$ulcyeqla$aRLxytbonTjxFMNWjjjOL0',
    ssh_key       =>  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/qU86rQHw+iwX1714ZrntMz0BAsxgrsxHjQF2SHZhJ1MP541y0tSId8ZnVxATIfI3JADv9cw5wFq09fWzi7BQBd4p2UO7mMx0wxzSrONWb62lzpspCAe27kZfrtedc7x5GVGtns4bQxloTDFHXcvtQrC8j3avBb1ZdAs6TMvYAX8eSZ8UOcMIGHY6Go2QbhDnnh1+oDBqqQZNjAJas5PS5bvX9C6/dWYlfjJkPpsoG7tTKkAq2otFCcqq70kAEOlQ6VDyZsOzJjKZ/C6o9mosg+v5CXrp2cdo2Gc6p9ezEAcZb+vzQDwXJeGcp4ewIyX0x03kiMr8BUE/cpJwsg6D david@davids',
    role          =>  'superreader';
  'client_certificate_only':
    ensure                  =>  'present',
    client_certificate_only =>  false,
    password_hash           =>  '$1$ulcyeqla$aRLxytbonTjxFMNWjjjOL0',
    role                    =>  'devicereader';
  'custom_profile':
    ensure                  =>  'present',
    client_certificate_only =>  true,
    role                    =>  'custom',
    role_profile            =>  'cryptoadmin';
}

panos_service {
  'minimal':
    ensure    => 'present',
    protocol  => 'udp',
    port      => '21';
  'description':
    ensure      => 'present',
    port        => '220',
    description => 'This is managed by Puppet.';
  'source port':
    ensure      => 'present',
    port        => '201',
    src_port    => '259',
    description => 'This is managed by Puppet.';
  'udp_description':
    ensure      => 'present',
    port        => '220',
    protocol    => 'udp',
    description => 'This is managed by Puppet.';
  'udp_source port':
    ensure      => 'present',
    port        => '213',
    src_port    => '220',
    protocol    => 'udp',
    description => 'This is managed by Puppet.';
  'csv ports':
    ensure      => 'present',
    port        => '201, 23, 220',
    src_port    => '212, 38, 312',
    description => 'This is managed by Puppet.';
  'udp_csv ports':
    ensure      => 'present',
    port        => '213, 23, 220',
    src_port    => '56, 38, 47',
    protocol    => 'udp',
    description => 'This is managed by Puppet.';
  'range ports':
    ensure      => 'present',
    port        => '212-312',
    src_port    => '23-50',
    description => 'This is managed by Puppet.';
  'udp_range ports':
    ensure      => 'present',
    port        => '212-312',
    src_port    => '17-22',
    protocol    => 'udp',
    description => 'This is managed by Puppet.';
}

panos_service_group {
  'minimal service group':
    ensure   => 'present',
    services => ['source port'];
  'test group 1':
    ensure   => 'present',
    services => ['udp_range ports', 'csv ports', 'minimal service group'],
    tags     => [];
}

panos_arbitrary_commands {
  'devices/entry/network/interface/ethernet':
    ensure  => 'present',
    xml     => '<ethernet>
                  <entry name="ethernet1/1">
                    <layer2/>
                  </entry>
                  <entry name="ethernet1/2">
                    <virtual-wire>
                      <lldp>
                        <enable>no</enable>
                      </lldp>
                    </virtual-wire>
                  </entry>
                  <entry name="ethernet1/3">
                    <layer3/>
                  </entry>
                  <entry name="ethernet1/4">
                    <virtual-wire>
                      <lldp>
                        <enable>no</enable>
                      </lldp>
                    </virtual-wire>
                  </entry>
                  <entry name="ethernet1/5">
                    <layer3/>
                  </entry>
                  <entry name="ethernet1/6">
                    <tap/>
                  </entry>
                  <entry name="ethernet1/7">
                    <layer2/>
                  </entry>
                  <entry name="ethernet1/8">
                    <tap/>
                  </entry>
                </ethernet>';
}

panos_zone {
  'tap':
    ensure                     => 'present',
    network                    => 'tap',
    interfaces                 => ['ethernet1/6'];
  'virtual-wire':
    ensure                     => 'present',
    network                    => 'virtual-wire',
    interfaces                 => ['ethernet1/4'];
  'layer2':
    ensure                     => 'present',
    network                    => 'layer2',
    interfaces                 => ['ethernet1/7'];
  'layer3':
    ensure                     => 'present',
    network                    => 'layer3',
    interfaces                 => ['ethernet1/3', 'ethernet1/5'];
  'included lists':
    ensure                     => 'present',
    include_list               => ['10.10.1.1', '192.168.1.1'];
  'excluded lists':
    ensure                     => 'present',
    exclude_list               => ['10.10.1.1', '192.168.1.1'];
  'user identification':
    ensure                     => 'present',
    enable_user_identification => false;
}

if $::facts['operatingsystemrelease'] == '8.1.0' {
  panos_zone {
    'nsx_service_profile':
      ensure  => 'present',
      network => 'tunnel';
  }
}

if $::facts['operatingsystemrelease'] == '7.1.0' {
  panos_zone {
    'nsx_service_profile':
      ensure              => 'present',
      nsx_service_profile => false;
  }
}

panos_tag {
  'Test Tag':
    ensure   => 'present',
    color    => 'green',
    comments => 'comments 123',
}

panos_nat_policy {
  'minimal':
    ensure => 'present',
    to => ['included lists'];
  'FullTestNATPolicy':
      ensure                         => 'present',
      source_translation_type        => 'dynamic-ip',
      source_translated_address      => ['SAT_address'],
      description                    => 'something boring',
      destination_translated_address => 'DAT_address',
      destination_translated_port    => '5',
      fallback_address_type          => 'translated-address',
      fallback_address               => ['fallback_address'],
      from                           => ['excluded lists'],
      to                             => ['included lists'],
      source                         => ['source_address'],
      destination                    => ['destination_address'],
      service                        => 'source port',
      # destination_interface        => 'vlan.2',
      tags                           => ['Test Tag'];
  'StaticIPSATPolicy':
      ensure                           => 'present',
      source_translation_type          => 'static-ip',
      source_translated_static_address => 'SAT_static_address',
      bi_directional                   => true,
      from                             => ['excluded lists'],
      to                               => ['included lists'],
      source                           => ['source_address'],
      destination                      => ['destination_address'],
      service                          => 'any',
      destination_interface            => 'any';
  'DynamicIPandPortPolicy':
      ensure                    => 'present',
      from                      => ['excluded lists'],
      to                        => ['included lists'],
      service                   => 'any',
      source                    => ['source_address'],
      destination               => ['destination_address'],
      source_translation_type   => 'dynamic-ip-and-port',
      source_translated_address => ['SAT_address'];
  'UnsetSourceTranslationType':
      ensure                  => 'present',
      from                    => ['excluded lists'],
      to                      => ['included lists'],
      service                 => 'any',
      source                  => ['source_address'],
      destination             => ['destination_address'],
      source_translation_type => 'none';
}

panos_security_policy_rule  {
  'minimal':
    ensure => 'present';
  'description':
    ensure      => 'present',
    description => 'This is still managed by Puppet.';
  'universal':
    ensure    => 'present',
    rule_type => 'intrazone';
  'intrazone':
    ensure    => 'present',
    rule_type => 'universal';
  'interzone':
    ensure    => 'present',
    rule_type => 'universal';
  'tags':
    ensure      => 'present',
    description => 'This is still managed by Puppet.',
    # tags         =>  ['puppet', 'managed'],
    rule_type   => 'universal';
  'sources':
    ensure         => 'present',
    description    => 'This is managed by Puppet.',
    # source_zones => ['custom zone 1', 'custom zone 2'],
    source_address => ['0.0.0.0-0.255.255.255'],
    rule_type      => 'universal';
  'destination':
    ensure              => 'present',
    description         => 'This is managed by Puppet.',
    destination_zones   => ['multicast'],
    # destination_zones => ['custom zone 3', 'custom zone 4'],
    source_address      => ['0.0.0.0-0.255.255.255'],
    destination_address => ['0.0.0.0-0.255.255.255'],
    rule_type           => 'universal';
  'users':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    source_users => ['known-user'],
    # source_users  =>  ['custom user 1', 'customer user 2'],
    rule_type    => 'universal';
  'hip-profiles':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    # tags         =>  ['puppet', 'managed'],
    hip_profiles => ['any'],
    # hip_profiles  =>  ['custom profile 1', 'custom profile 2'],
    rule_type    => 'universal';
  'applications':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    hip_profiles => ['no-hip'],
    applications => ['1c-enterprise', '1und1-mail'],
    rule_type    => 'universal';
  'services':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    services    => ['application-default'],
    categories  => ['adult', 'content-delivery-networks'],
    rule_type   => 'universal';
  'actions':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    action      => 'allow',
    rule_type   => 'universal';
  'log-settings':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    log_start   => false,
    log_end     => true;
    # log_setting   => 'custom log forwarding profile';
  'profile-setting-profiles':
    ensure                => 'present',
    description           => 'This is managed by Puppet.',
    profile_type          => 'profiles',
    anti_virus_profile    => 'none',
    vulnerability_profile => 'none',
    spyware_profile       => 'none',
    url_filtering_profile => 'none';
    # file_blocking_profile => 'custom file blocking profile',
    # data_filtering_profile  =>  'custom data filtering profile',
    # wildfire_analysis_profile  =>  'custom analysis profile';
  'profile-setting-group':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    profile_type => 'none';
    # group_profile => 'custom group profile';
  'other-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    # schedule_profile  => 'custom schedule profile',
    qos_type                            => 'none',
    disable_server_response_inspection  =>  true;
  'ip-dscp-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    qos_type                            => 'ip-dscp',
    ip_dscp                             =>  'cs1',
    disable_server_response_inspection  =>  true;
  'ip-precedence-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    qos_type                            =>  'ip-precedence',
    ip_precedence                       =>  'cs1',
    disable_server_response_inspection  =>  true;
}

panos_arbitrary_commands  {
  'devices/entry/vsys/entry/application-group':
    ensure    => 'present',
    xml       => '<application-group>
                    <entry name="Application Group">
                      <members>
                        <member>1c-enterprise</member>
                      </members>
                    </entry>
                  </application-group>';
    # xml       => file('MODULENAME/file.xml');
}

panos_virtual_router { 'example VR':
  ensure => 'present',
  ad_ibgp => '50',
  ad_ebgp => '40',
  ad_rip => '30';
  'default VR':
  ensure => 'present',
  ad_ibgp => '90',
  ad_ebgp => '80',
  ad_rip => '35';
}
panos_static_route { 'example SR-example VR':
  name => 'example SR-example VR',
  ensure => 'present',
  bfd_profile => 'None',
  metric => '25',
  admin_distance => '50',
  destination => '10.8.0.0/32',
  nexthop_type => 'discard',
  vr_name => 'example VR',
  no_install => false,
}
panos_ipv6_static_route {'example ipv6-example VR':
  name => "new ipv6-new example VR",
  ensure=>"present",
  nexthop_type=>"discard",
  bfd_profile=>"None",
  metric=>"100",
  admin_distance=>"16",
  destination=>"21::/16",
  vr_name=>"example VR",
  no_install=>false,
}

panos_commit {
  'commit':
    commit => true
}
