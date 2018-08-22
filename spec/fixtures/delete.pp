# bundle exec puppet device --modulepath spec/fixtures/modules/ --deviceconfig spec/fixtures/device.conf --target pavm --verbose --trace --apply tests/test_commit.pp

panos_address {
  'source_address':
    ensure => absent;
}

panos_address_group {
  'full':
    ensure => absent;
}

panos_admin {
  'tester':
    ensure => absent;
}

panos_service {
  'Application':
    ensure => absent;
}

panos_service_group {
  'test group 1':
    ensure => absent;
}

panos_zone {
  'source_zone':
    ensure => absent;
}

panos_tag {
  'Test Tag':
    ensure => absent;
}

panos_nat_policy {
  'FullTestNATPolicy':
    ensure => absent;
}

panos_security_policy_rule  {
  'minimal':
    ensure => 'absent';
  'description':
    ensure => 'absent';
  'universal':
    ensure => 'absent';
  'intrazone':
    ensure => 'absent';
  'interzone':
    ensure => 'absent';
  'tags':
    ensure => 'absent';
  'sources':
    ensure => 'absent';
  'destination':
    ensure => 'absent';
  'users':
    ensure => 'absent';
  'hip-profiles':
    ensure => 'absent';
  'applications':
    ensure => 'absent';
  'services':
    ensure => 'absent';
  'actions':
    ensure => 'absent';
  'log-settings':
    ensure => 'absent';
  'profile-setting-profiles':
    ensure => 'absent';
  'profile-setting-group':
    ensure => 'absent';
  'other-settings':
    ensure =>  'absent';
  'ip-dscp-settings':
    ensure =>  'absent';
  'ip-precedence-settings':
    ensure =>  'absent';
}

panos_commit {
  'commit':
    commit => true
}
