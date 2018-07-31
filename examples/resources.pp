# bundle exec puppet device --modulepath spec/fixtures/modules/ --deviceconfig spec/fixtures/device.conf --target pavm --verbose --trace --apply tests/test_commit.pp

panos_address {
  'address-3':
    ip_range    => '192.168.0.1-192.168.0.17',
    description => '<eas&lt;yxss/>',
}

panos_address_group {
  'full':
    description    => 'address group with static contents',
    type           => 'static',
    static_members => ['address-3'];
    # tags           => ['tests'];
  'empty':
    description    => 'address group with dynamic contents',
    type           => 'dynamic',
    dynamic_filter => "'tag1' or 'tag2'";
    # tags           => ['tests'],
}

panos_admin {
  'tester':
    # password_hash => pw_hash('thepassword', 'MD5', 'ulcyeqla'),
    password_hash           => '$1$ulcyeqla$aRLxytbonTjxFMNW96UOL0',
    client_certificate_only => false,
    ssh_key                 => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/qU86rQHw+iwX1714ZrntMz0BAsxgrsxHjQF2SHZhJ1MP541y0tSId8ZnVxATIfI3JADv9cw5wFq09fWzi7BQBd4p2UO7mMx0wxzSrONWb62lzpspCAe27kZfrtedc7x5GVGtns4bQxloTDFHXcvtQrC8j3avBb1ZdAs6TMvYAX8eSZ8UOcMIGHY6Go2QbhDnnh1+oDBqqQZNjAJas5PS5bvX9C6/dWYlfjJkPpsoG7tTKkAq2otFCcqq70kAEOlQ6VDyZsOzJjKZ/C6o9mosg+v5CXrp2cdo2Gc6p9ezEAcZb+vzQDwXJeGcp4ewIyX0x03kiMr8BUE/cpJwsg6D david@davids',
    role                    => 'superuser';
}

panos_service {
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
  'test group 1':
    ensure   => 'present',
    services => ['ftp'],
    tags     => [],
}

panos_zone {
  'test zone':
    ensure                     => 'present',
    network                    => 'layer3',
    interfaces                 => ['vlan'],
    #  zone_protection_profile => 'zoneProtectionProfile',
    # log_setting             => 'logSetting',
    enable_user_identification => true,
    # nsx_service_profile      => true,
    include_list               => ['192.35.26.32', '192.63.95.86'],
    exclude_list               => ['175.65.98.36', '175.82.36.96'],
}

panos_commit {
  'commit':
    commit => true
}
