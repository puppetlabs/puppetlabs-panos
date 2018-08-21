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
}

panos_address_group {
  'full':
    description    => 'address group with static contents',
    type           => 'static',
    static_members => ['source_address'];
    # tags           => ['tests'];
  'empty':
    description    => 'address group with dynamic contents',
    type           => 'dynamic',
    dynamic_filter => "'tag1' or 'tag2'";
    # tags           => ['tests'],
}

panos_admin {
  'tester':
    client_certificate_only => true,
    ssh_key                 => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/qU86rQHw+iwX1714ZrntMz0BAsxgrsxHjQF2SHZhJ1MP541y0tSId8ZnVxATIfI3JADv9cw5wFq09fWzi7BQBd4p2UO7mMx0wxzSrONWb62lzpspCAe27kZfrtedc7x5GVGtns4bQxloTDFHXcvtQrC8j3avBb1ZdAs6TMvYAX8eSZ8UOcMIGHY6Go2QbhDnnh1+oDBqqQZNjAJas5PS5bvX9C6/dWYlfjJkPpsoG7tTKkAq2otFCcqq70kAEOlQ6VDyZsOzJjKZ/C6o9mosg+v5CXrp2cdo2Gc6p9ezEAcZb+vzQDwXJeGcp4ewIyX0x03kiMr8BUE/cpJwsg6D david@davids',
    role                    => 'superuser';
    # role_profile          => 'custom_profile',
}

panos_service {
  'Application':
    ensure      => 'present',
    description => 'Demo App',
    protocol    => 'tcp',
    dest_port   => '3478-3480',
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
  'test group 1':
    ensure   => 'present',
    services => ['ftp', 'Comms'],
    tags     => [],
}

panos_zone {
  'source_zone':
    ensure                     => 'present',
    network                    => 'layer3',
    # interfaces                 => ['vlan'],
    #  zone_protection_profile => 'zoneProtectionProfile',
    # log_setting             => 'logSetting',
    enable_user_identification => false,
    # nsx_service_profile        => false;
  'destination_zone':
    ensure                     => 'present',
    network                    => 'layer3',
    # interfaces                 => ['vlan.3'],
    enable_user_identification => true,
    # nsx_service_profile        => $facts['osversion'] ? { '8.1' => true, default => false };
}

# TODO:
if $::facts['osversion'] == '8.1' {
  Panos_zone['destination_zone'] {
    nsx_service_profile => true
  }
}

panos_tag {
  'Test Tag':
    ensure   => 'present',
    color    => 'green',
    comments => 'comments 123',
}

panos_nat_policy {
  'FullTestNATPolicy':
      ensure                         => 'present',
      source_translation_type        => 'dynamic-ip',
      source_translated_address      => ['SAT_address'],
      description                    => 'something boring',
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
  'Default security policy rule':
    ensure       =>  'present';
  'Adding a group policy value':
    ensure       =>  'present',
    action       =>  'allow',
    profile_type =>  'group',
    # group_profile       => 'Custom profile type',
    log_start    =>  true,
    qos_type     =>  'ip-dscp',
    ip_dscp      =>  'af11';
  'Adding custom profiles':
    ensure                    =>  'present',
    profile_type              =>  'profiles',
    anti_virus_profile        =>  'none',
    vulnerability_profile     =>  'default',
    spyware_profile           =>  'default',
    url_filtering_profile     =>  'default',
    file_blocking_profile     =>  'none',
    # data_filtering_profile  =>  'Custom profile type',
    wildfire_analysis_profile =>  'default';
  'QoS Marking settings':
    ensure   =>  'present',
    qos_type =>  'follow-c2s-flow';
  'All the options':
    ensure                             => 'present',
    rule_type                          => 'interzone',
    description                        => 'This is managed by Puppet.',
    # tags         => ['puppet', 'test', 'all', 'options'],
    # source_zones => ['Custom Zone 1', 'Custom Zone 2'],
    source_address                     =>  ['0.0.0.0-0.255.255.255', '10.0.0.0-10.255.255.255'],
    # source_users    => ['Custom User', 'Custom User 2'],
    # hip_profiles      => ['Custom HIP 1', 'Customer HIP 2'],
    # destination_zones => ['Custom Zone 1', 'Custom Zone 2'],
    destination_address                =>  ['0.0.0.0-0.255.255.255', '10.0.0.0-10.255.255.255'],
    applications                       => ['activesync'],
    services                           => ['service-http'],
    categories                         => ['games', 'home-and-garden'],
    action                             => 'reset-client',
    icmp_unreachable                   => false,
    # log_setting         => 'custom log settings',
    # schedule_profile    => 'custom schedule',
    disable_server_response_inspection =>  false;
  'Disable a Security Policy Rule':
    ensure  => 'present',
    disable =>  true;
}

panos_arbitrary_commands  {
  'application-group':
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

panos_commit {
  'commit':
    commit => true
}
