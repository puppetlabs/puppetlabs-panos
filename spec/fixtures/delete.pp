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
  'Default security policy rule':
    ensure => absent;
}

panos_commit {
  'commit':
    commit => true
}
