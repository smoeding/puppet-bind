# bind

[![Build Status](https://github.com/smoeding/puppet-bind/actions/workflows/CI.yaml/badge.svg)](https://github.com/smoeding/puppet-bind/actions/workflows/CI.yaml)
[![Puppet Forge](http://img.shields.io/puppetforge/v/stm/bind.svg)](https://forge.puppetlabs.com/stm/bind)
[![License](https://img.shields.io/github/license/smoeding/puppet-bind.svg)](https://raw.githubusercontent.com/smoeding/puppet-bind/master/LICENSE)

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with bind](#setup)
    * [What bind affects](#what-bind-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with bind](#beginning-with-bind)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module manages the BIND Name Server on Debian and Ubuntu. The module supports setting up a Caching Name Server or an Authoritative Name Server using primary and secondary zones.

## Setup

### What bind affects

The module manages the `named` process and related service files. It also managed the configuration and zone files. On Debian and Ubuntu these files are below the `/etc/bind`, `/var/lib/bind` and `/var/cache/bind` directories. The module uses a multi-level directory tree below `/var/lib/bind` to separate primary and secondary zone files.

### Setup Requirements

The module uses the `stdlib` and `concat` modules. It is tested on Debian and Ubuntu using Puppet 7.

### Beginning with bind

Set up a caching name server on localhost:

```puppet
class { 'bind':
  listen_on         => [ '127.0.0.1', ],
  listen_on_v6      => [ 'none', ],
  allow_query       => [ 'localhost', ],
  allow_query_cache => [ 'localhost', ],
  allow_recursion   => [ 'localhost', ],
}
```

## Usage

### Caching name server

Set up a caching name server that provides recursive name resolution for a local subnet:

```puppet
class { 'bind':
  allow_query       => [ 'localhost', '10/8', ],
  allow_query_cache => [ 'localhost', '10/8', ],
  allow_recursion   => [ 'localhost', '10/8', ],
}
```

### Caching name server with forwarders

Set up a caching name server that provides recursive name resolution for a local subnet and uses forwarders:

```puppet
class { 'bind':
  allow_query       => [ 'localhost', '10/8', ],
  allow_query_cache => [ 'localhost', '10/8', ],
  allow_recursion   => [ 'localhost', '10/8', ],
  forwarders        => [ '10.0.0.53', '10.1.1.53', ],
}
```

### Manage a primary zone

Add a primary zone for the `example.com` domain and manage the zone using Puppet:

```puppet
bind::zone::primary { 'example.com':
  source => 'puppet:///modules/profile/dns/example.com.zone',
}
```

The zone file will be managed on the server as `/var/lib/bind/primary/com/example/db.example.com`. This tree structure is better than a flat directory structure if many zones will be managed by the server.

### Manage a primary zone with dynamic updates

Add a primary zone for the `example.com` domain and allow dynamic updates using a generated key called `nsupdate`:

```puppet
bind::key { 'nsupdate':
  secret  => 'TopSecret',
  keyfile => '/etc/bind/nsupdate.key',
}

bind::zone::primary { 'example.com':
  update_policy  => ['grant nsupdate zonesub any'],
}
```

In this case the zone file will also be stored on the server as `/var/lib/bind/primary/com/example/db.example.com`. It can't be managed by Puppet as `named` will periodically update the zone file using the dynamic updates. You need to use `rndc freeze example.com` and `rndc thaw example.com` when editing the zone file manually.

### Define a DNSSEC policy for a zone

Create a new DNSSEC policy named `standard` with a Combined Signing Key (CSK) and use the key to create a DNSSEC signed zone:

```puppet
bind::dnssec_policy { 'standard':
  csk_lifetime  => 'unlimited',
  csk_algorithm => 'ecdsap256sha256',
}

bind::zone::primary { 'example.net':
  dnssec         => true,
  inline_signing => true,
  dnssec_policy  => 'standard',
}
```

## Reference

See [REFERENCE.md](https://github.com/smoeding/puppet-bind/blob/master/REFERENCE.md)

## Limitations

Not all BIND features are currently implemented as I started with the options I needed myself. Some options are not yet available and features like DNSSEC inline signing are not well tested.

## Development

You may open Github issues for this module if you need additional options currently not available.

Feel free to send pull requests for new features.
