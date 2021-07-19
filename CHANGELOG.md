# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-panos/tree/v2.0.0) (2021-07-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/v1.2.1...v2.0.0)

### Changed

- \(IAC-1604\) Removal of puppet5 and resource api module [\#131](https://github.com/puppetlabs/puppetlabs-panos/pull/131) ([pmcmaw](https://github.com/pmcmaw))
- \(IAC-999\) - Removal of inappropriate terminology [\#123](https://github.com/puppetlabs/puppetlabs-panos/pull/123) ([david22swan](https://github.com/david22swan))

### Added

- pdksync - \(feat\) Add support for Puppet 7 [\#125](https://github.com/puppetlabs/puppetlabs-panos/pull/125) ([daianamezdrea](https://github.com/daianamezdrea))

### Fixed

- \(maint\) Improve transport schema docs \[no-ci\] [\#109](https://github.com/puppetlabs/puppetlabs-panos/pull/109) ([DavidS](https://github.com/DavidS))

## [v1.2.1](https://github.com/puppetlabs/puppetlabs-panos/tree/v1.2.1) (2019-07-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/v1.2.0...v1.2.1)

### Fixed

- \(maint\) fixing up the fingerprint hexdigest in the initialize [\#105](https://github.com/puppetlabs/puppetlabs-panos/pull/105) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- Update README.md [\#89](https://github.com/puppetlabs/puppetlabs-panos/pull/89) ([kylehansel](https://github.com/kylehansel))

## [v1.2.0](https://github.com/puppetlabs/puppetlabs-panos/tree/v1.2.0) (2019-06-10)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/v1.1.0...v1.2.0)

### Added

- \(FM-8107\) Add `insert\_after` attribute for policy rule ordering [\#96](https://github.com/puppetlabs/puppetlabs-panos/pull/96) ([da-ar](https://github.com/da-ar))
- \(FM-8111\) increase system facts [\#94](https://github.com/puppetlabs/puppetlabs-panos/pull/94) ([shermdog](https://github.com/shermdog))
- \(FM-8104\) Add implicit default values [\#92](https://github.com/puppetlabs/puppetlabs-panos/pull/92) ([shermdog](https://github.com/shermdog))

### Fixed

- \(FM-8109\) Don't munge nil values unless profile\_type is set [\#97](https://github.com/puppetlabs/puppetlabs-panos/pull/97) ([da-ar](https://github.com/da-ar))
- \(FM-8110\) fix panos\_nat\_policy source address translation [\#93](https://github.com/puppetlabs/puppetlabs-panos/pull/93) ([shermdog](https://github.com/shermdog))
- \(FM-8097\) fix store\_config task metadata for Bolt and RSAPI transports [\#90](https://github.com/puppetlabs/puppetlabs-panos/pull/90) ([shermdog](https://github.com/shermdog))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-panos/tree/v1.1.0) (2019-04-26)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/1.0.0...v1.1.0)

### Added

- \(FM-7973\) Adding hands on labs for bolt and puppet device [\#80](https://github.com/puppetlabs/puppetlabs-panos/pull/80) ([davinhanlon](https://github.com/davinhanlon))

### Fixed

- \(maint\) updating the ssl\_fingerprint to accept spaced and colon SHA25… [\#83](https://github.com/puppetlabs/puppetlabs-panos/pull/83) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(FM-7971\) backwards compatibility with PE 2019.0 [\#82](https://github.com/puppetlabs/puppetlabs-panos/pull/82) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-panos/tree/1.0.0) (2019-03-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/0.2.0...1.0.0)

### Added

- \(FM-7625\) implement finegrained configuration support for SSL verification [\#76](https://github.com/puppetlabs/puppetlabs-panos/pull/76) ([Thomas-Franklin](https://github.com/Thomas-Franklin))
- \(FM-7602\) Implement Resource API transports for bolt and ACE [\#73](https://github.com/puppetlabs/puppetlabs-panos/pull/73) ([DavidS](https://github.com/DavidS))

### Fixed

- \(maint\) add resource\_api install module as a dependency [\#72](https://github.com/puppetlabs/puppetlabs-panos/pull/72) ([DavidS](https://github.com/DavidS))

## [0.2.0](https://github.com/puppetlabs/puppetlabs-panos/tree/0.2.0) (2018-10-23)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-panos/compare/0.1.0...0.2.0)

### Added

- Allow color numbers instead of descriptive names [\#68](https://github.com/puppetlabs/puppetlabs-panos/pull/68) ([DavidS](https://github.com/DavidS))
- \(PDK-1143\) changes to work with composite namevars from simple provider [\#65](https://github.com/puppetlabs/puppetlabs-panos/pull/65) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

### Fixed

- \(FM-7496\) fix for running apply runs from a PE/PS installation [\#66](https://github.com/puppetlabs/puppetlabs-panos/pull/66) ([Thomas-Franklin](https://github.com/Thomas-Franklin))

## 0.1.0

**Features**

**Bugfixes**

**Known Issues**


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
