# bind

[![Build Status](https://travis-ci.com/smoeding/puppet-bind.svg?branch=master)](https://travis-ci.com/smoeding/puppet-bind)
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

The module uses the `stdlib` and `concat` modules. It is tested on Debian and Ubuntu using Puppet 6.

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

Set up a caching name server that provides recursive name resolution for a local subnet:

```puppet
class { 'bind':
  allow_query       => [ 'localhost', '10/8', ],
  allow_query_cache => [ 'localhost', '10/8', ],
  allow_recursion   => [ 'localhost', '10/8', ],
}
```

Set up a caching name server that provides recursive name resolution for a local subnet and uses forwarders:

```puppet
class { 'bind':
  allow_query       => [ 'localhost', '10/8', ],
  allow_query_cache => [ 'localhost', '10/8', ],
  allow_recursion   => [ 'localhost', '10/8', ],
  forwarders        => [ '10.0.0.53', '10.1.1.53', ],
}
```

Add a primary zone for the `example.com` domain:

```puppet
bind::zone::primary { 'example.com':
  source => 'puppet:///modules/profile/dns/example.com.zone',
}
```

The zone file will be managed on the server as `/var/lib/bind/primary/com/example/db.example.com`. This tree structure is better than a flat directory structure if many zones will be managed by the server.

## Reference

See [REFERENCE.md](https://github.com/smoeding/puppet-bind/blob/master/REFERENCE.md)

## Limitations

Not all BIND features are currently implemented as I started with the options I needed myself. Some options are not yet available and features like DNSSEC inline signing are not well tested.

## Development

You may open Github issues for this module if you need additional options currently not available.

Feel free to send pull requests for new features.
