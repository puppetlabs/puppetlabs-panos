# bundle exec puppet device --modulepath spec/fixtures/modules/ --deviceconfig spec/fixtures/device.conf --target pavm --verbose --trace --apply tests/test_commit.pp

panos_address {
  'minimal':
    ensure      => 'present',
    ip_range    => '192.168.0.1-192.168.0.17';
  'address-3':
    ip_range    => '192.168.0.1-192.168.0.17',
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
    fqdn => 'google-public-dns-a.google.com';
}

panos_address_group {
  # namespace overlap with panos_address: '<![CDATA[ address-group -> minimal 'minimal' is already in use]]>'
  'minimal address group':
    ensure         => 'present',
    type           => 'static',
    static_members => ['minimal'];
  'full':
    description    => 'address group with static contents',
    type           => 'static',
    static_members => ['address-3'];
    # tags           => ['tests'];
  'dynamic group':
    description    => 'address group with dynamic contents',
    type           => 'dynamic',
    dynamic_filter => "'tag1' or 'tag2'";
    # tags           => ['tests'],
}

panos_admin {
  'minimal':
    ensure => 'present',
    role   => 'superuser';
  'tester':
    # password_hash => pw_hash('thepassword', 'MD5', 'ulcyeqla'),
    password_hash           => '$1$ulcyeqla$aRLxytbonTjxFMNW96UOL0',
    client_certificate_only => false,
    ssh_key                 => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/qU86rQHw+iwX1714ZrntMz0BAsxgrsxHjQF2SHZhJ1MP541y0tSId8ZnVxATIfI3JADv9cw5wFq09fWzi7BQBd4p2UO7mMx0wxzSrONWb62lzpspCAe27kZfrtedc7x5GVGtns4bQxloTDFHXcvtQrC8j3avBb1ZdAs6TMvYAX8eSZ8UOcMIGHY6Go2QbhDnnh1+oDBqqQZNjAJas5PS5bvX9C6/dWYlfjJkPpsoG7tTKkAq2otFCcqq70kAEOlQ6VDyZsOzJjKZ/C6o9mosg+v5CXrp2cdo2Gc6p9ezEAcZb+vzQDwXJeGcp4ewIyX0x03kiMr8BUE/cpJwsg6D david@davids',
    role                    => 'superuser';
    # role_profile          => 'custom_profile',
}

panos_service {
  # namespace overlap with panos_address: '<![CDATA[ minimal 'minimal' is already in use]]>'
  'minimal service group':
    ensure   => 'present',
    protocol => 'tcp',
    src_port => '21';
  'Application':
    ensure      => 'present',
    description => 'Demo App',
    protocol    => 'tcp',
    dest_port   => '3478-3479',
    src_port    => '12345',
    tags        => [];
  'Comms':
    ensure      => 'present',
    description => 'Voice Chat',
    protocol    => 'udp',
    dest_port   => '8888,8881,8882',
    src_port    => '1234,3214,5432',
    tags        => [];
  'ftp':
    ensure      => 'present',
    description => 'ftp server',
    protocol    => 'tcp',
    dest_port   => '21',
    tags        => [];
}

panos_service_group {
  'minimal':
    ensure   => 'present',
    services => ['ftp'];
  'test group 1':
    ensure   => 'present',
    services => ['ftp'],
    tags     => [],
}

panos_arbitrary_commands {
  'network/interface/ethernet':
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
                  <entry name="ethernet1/5">
                    <layer3/>
                  </entry>
                  <entry name="ethernet1/10">
                    <tap/>
                  </entry>
                </ethernet>';
}

panos_zone {
  'minimal':
    ensure                     => 'present';
  'tap':
    ensure                     => 'present',
    network                    => 'tap',
    interfaces                 => ['ethernet1/10'];
  'virtual-wire':
    ensure                     => 'present',
    network                    => 'virtual-wire',
    interfaces                 => ['ethernet1/2'];
  'layer2':
    ensure                     => 'present',
    network                    => 'layer2',
    interfaces                 => ['ethernet1/1'];
  'layer3':
    ensure                     => 'present',
    network                    => 'layer3',
    interfaces                 => ['ethernet1/3', 'ethernet1/5'];
  'included lists':
    ensure                     => 'present',
    include_list               => ['10.10.10.10', '192.168.1.1'];
  'excluded lists':
    ensure                     => 'present',
    exclude_list               => ['10.10.10.10', '192.168.1.1'];
  'user identification':
    ensure                     => 'present',
    enable_user_identification => true;
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
  'minimal':
    ensure => 'present';
  'Test Tag':
    ensure   => 'present',
    color    => 'red',
    comments => 'comments 123',
}

panos_nat_policy {
  'minimal':
    ensure => 'present';
  'FullTestNATPolicy':
      ensure                         => 'present',
      source_translation_type        => 'dynamic-ip',
      source_translated_address      => ['SAT_address'],
      description                    => 'something interesting',
      destination_translated_address => 'DAT_address',
      destination_translated_port    => '5',
      fallback_address_type          => 'translated-address',
      fallback_address               => ['fallback_address'],
      source_zones                   => ['source_zone'],
      destination_zones              => ['destination_zone'],
      source_address                 => ['source_address'],
      destination_address            => ['destination_address'],
      service                        => 'ftp',
      # destination_interface          => 'vlan.2',
      tags                           => ['Test Tag'];
  'StaticIPSATPolicy':
      ensure                           => 'present',
      source_translation_type          => 'static-ip',
      source_translated_static_address => 'SAT_static_address',
      bi_directional                   => true,
      source_zones                     => ['source_zone'],
      destination_zones                => ['destination_zone'],
      source_address                   => ['source_address'],
      destination_address              => ['destination_address'],
      service                          => 'any',
      destination_interface            => 'any';
  'DynamicIPandPortPolicy':
      ensure                    => 'present',
      source_zones              => ['source_zone'],
      destination_zones         => ['destination_zone'],
      service                   => 'any',
      source_address            => ['source_address'],
      destination_address       => ['destination_address'],
      source_translation_type   => 'dynamic-ip-and-port',
      source_translated_address => ['SAT_address'];
  'UnsetSourceTranslationType':
      ensure                  => 'present',
      source_zones            => ['source_zone'],
      destination_zones       => ['destination_zone'],
      service                 => 'any',
      source_address          => ['source_address'],
      destination_address     => ['destination_address'],
      source_translation_type => 'none';
}

panos_security_policy_rule  {
  'minimal':
    ensure => 'present';
  'description':
    ensure      => 'present',
    description => 'This is managed by Puppet.';
  'universal':
    ensure    => 'present',
    rule_type => 'universal';
  'intrazone':
    ensure    => 'present',
    rule_type => 'intrazone';
  'interzone':
    ensure    => 'present',
    rule_type => 'interzone';
  'tags':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    # tags         =>  ['puppet', 'managed'],
    rule_type   => 'universal';
  'sources':
    ensure         => 'present',
    description    => 'This is managed by Puppet.',
    # source_zones => ['custom zone 1', 'custom zone 2'],
    source_address => ['0.0.0.0-0.255.255.255', '10.0.0.0-10.255.255.255'],
    rule_type      => 'universal';
  'destination':
    ensure              => 'present',
    description         => 'This is managed by Puppet.',
    destination_zones   => ['multicast'],
    # destination_zones => ['custom zone 3', 'custom zone 4'],
    source_address      => ['0.0.0.0-0.255.255.255', '10.0.0.0-10.255.255.255'],
    destination_address => ['0.0.0.0-0.255.255.255', '10.0.0.0-10.255.255.255'],
    rule_type           => 'universal';
  'users':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    source_users => ['pre-logon'],
    # source_users  =>  ['custom user 1', 'customer user 2'],
    rule_type    => 'universal';
  'hip-profiles':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    # tags         =>  ['puppet', 'managed'],
    hip_profiles => ['no-hip'],
    # hip_profiles  =>  ['custom profile 1', 'custom profile 2'],
    rule_type    => 'universal';
  'applications':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    hip_profiles => ['no-hip'],
    applications => ['1c-enterprise', '1und1-mail', '4shared'],
    rule_type    => 'universal';
  'services':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    services    => ['any'],
    categories  => ['adult', 'auctions', 'content-delivery-networks'],
    rule_type   => 'universal';
  'actions':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    action      => 'deny',  
    rule_type   => 'universal';
  'log-settings':
    ensure      => 'present',
    description => 'This is managed by Puppet.',
    log_start   => true,
    log_end     => false;
    # log_setting   => 'custom log forwarding profile';
  'profile-setting-profiles':
    ensure                => 'present',
    description           => 'This is managed by Puppet.',
    profile_type          => 'profiles',
    anti_virus_profile    => 'default',
    vulnerability_profile => 'strict',
    spyware_profile       => 'strict',
    url_filtering_profile => 'default';
    # file_blocking_profile => 'custom file blocking profile',
    # data_filtering_profile  =>  'custom data filtering profile',
    # wildfire_analysis_profile  =>  'custom analysis profile';
  'profile-setting-group':
    ensure       => 'present',
    description  => 'This is managed by Puppet.',
    profile_type => 'group';
    # group_profile => 'custom group profile';
  'other-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    # schedule_profile  => 'custom schedule profile',
    qos_type                            => 'follow-c2s-flow',
    disable_server_response_inspection  =>  true;
  'ip-dscp-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    qos_type                            => 'ip-dscp',
    ip_dscp                             =>  'cs0',
    disable_server_response_inspection  =>  true;
  'ip-precedence-settings':
    ensure                              =>  'present',
    description                         =>  'This is managed by Puppet.',
    qos_type                            =>  'ip-precedence',
    ip_precedence                       =>  'cs0',
    disable_server_response_inspection  =>  true;
}

panos_commit {
  'commit':
    commit => true
}
