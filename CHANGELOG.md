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
