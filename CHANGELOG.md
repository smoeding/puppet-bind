## 2025-11-10 - Release 2.1.0

### Bugfix

- The path to the checkzone program has been fixed on Debian-13.

### Features

- The main class supports a new optional parameter logdir to manage the log directory.

## 2025-09-12 - Release 2.0.0

### Features

- Add support for Debian-13 Trixie.
- Add support for Response Policy Zones (RPZ).

### Breaking changes

- Drop support for Debian-10 Buster.
- Drop support for Puppet; add support for OpenVox.

## 2025-01-02 - Release 1.3.0

### Features

- Add class parameters to manage most settings using Hiera.

## 2024-10-22 - Release 1.2.0

### Features

- Add support for ED25519 & ED448 keys to the dnssec_key type.

## 2024-03-21 - Release 1.1.0

### Features

- Add support for Debian-12, Ubuntu-22.04 and Ubuntu-24.04

## 2023-07-08 - Release 1.0.0

### Breaking changes

- Drop support for Puppet 6
- Require Stdlib 9.x

### Features

- Add support for Puppet 8
- Add support for Concat 9.x

## 2023-04-20 - Release 0.12.1

### Features

- Add support for Concat 8.x

## 2023-03-18 - Release 0.12.0

### Breaking changes

- The directory for DNSSEC keys managed internally by Bind (e.g. using inline-signing) has been changed from `/etc/bind/keys` to `/var/lib/bind/keys`. This is necessary to manage the keys when Bind is running on a host where AppArmor is enabled. Copy all keys managed by Bind from `/etc/bind/keys` to `/var/lib/bind/keys` before updating this module!

### Features

- The defined type `bind::logging::channel_file` has a new parameter `mode` to set the file mode of the log file. The default value for the parameter is `0640`.
- A new boolean parameter `append_view` has been added to the defined types `bind::zone::primary` and `bind::zone::secondary`. The file name of the zone file includes the view name if you set this parameter to `true`. Enable this if you have the same zone in different views to prevent zones in different views to reference the same zone file.

## 2022-11-24 - Release 0.11.0

### Breaking changes

- The defined type parameter `dnssec` has been renamed to `dnssec_enable` to match the main class parameter.
- All DNSSEC related zone parameters have been made optional. The config parameter `dnssec-enable` has been made obsolete with Bind 9.16 so that is no longer a prerequisite to activate other config options in the template. Make sure your Puppet code defines all parameters for your DNSSEC enabled primary zones.
- A primary zone using dynamic updates can now have a `content` or `source` parameter. The content of the zone file is created if the file does not exist. Subsequent puppet runs will not update the zone file as long as dynamic updates are used and the parameter `update_policy` is set for the zone.

## 2022-10-13 - Release 0.10.0

### Bugfix

- A syntax error with the in-view option has been fixed.

### Feature

- The path to the `named-checkzone` binary is a class option now.

## 2022-09-24 - Release 0.9.0

### Breaking changes

- The default for `root_hints_enable` has been changed from `true` to `false`. Normally a root hints file is no longer used since Bind includes an internal list of root name servers.

## 2022-09-20 - Release 0.8.0

### Bugfix

- Fix path of options file on Debian-11.

## 2022-09-17 - Release 0.7.0

### Breaking changes

- The class `bind::rate_limit` has been removed. All rate limit settings can be configured using the main class `bind`.

## 2022-09-15 - Release 0.6.0

### Features

- Implement `update-policy` for primary zones to manage dynamic zones.

### Breaking changes

- Drop Debian 9 support

## 2022-09-10 - Release 0.5.0

### Feature

- Add defined type `bind::dnssec_policy`.

## 2021-11-30 - Release 0.4.0

### Feature

- Add explicit class parameter `dnssec_lookaside`.
- Add explicit class parameter `dnssec_validation`.
- The parameters `dnssec_enable` and `dnssec_lookaside` are obsolete with Bind 9.16.0 or later. They will be removed from the configuration file when a applicable Bind version is detected.

## 2021-08-29 - Release 0.3.1

### Enhancements

- Allow stdlib 8.0.0

## 2021-03-04 - Release 0.3.0

### Feature

- Implement `custom_options` parameter to set unusual configuration options that are not implemented in the main class.

## 2021-01-05 - Release 0.2.0

### Features

- Implement `purge`, `prepublish`, `revoke` and `retire` parameters for `dnssec_key` type.
- Implement user defined logfile mode for defined type `bind::logging::channel_file`.

## 2020-11-02 - Release 0.1.0

Initial release
