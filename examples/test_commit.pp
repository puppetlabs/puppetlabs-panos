# bundle exec puppet device --modulepath spec/fixtures/modules/ --deviceconfig spec/fixtures/device.conf --target pavm --verbose --trace --apply tests/test_commit.pp

panos_address {
  'address-3':
    ip_range => '192.168.0.1-192.168.0.16'
}

panos_commit {
  'commit':
    commit => true
}
