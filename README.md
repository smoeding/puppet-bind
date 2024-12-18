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

The module manages the `named` process and related service files. It also managed the configuration and zone files. On Debian and Ubuntu these files are below the `/etc/bind`, `/var/lib/bind` and `/var/cache/bind` directories. The module uses a multi-level directory tree below `/var/lib/bind` and `/var/cache/bind` to separate primary and secondary zone files.

### Setup Requirements

The module uses the `stdlib` and `concat` modules. It is tested on Debian and Ubuntu using Puppet 8.

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
Or with hiera
```puppet
bind::listen_on: 127.0.0.1
bind::listen_on_v6: none
bind::allow_query: localhost
bind::allow_query_cache: localhost
bind::allow_recursion: localhost
```

## Usage

### Caching name server

Set up a caching name server that provides recursive name resolution for a local subnet:

```puppet
class { 'bind':
  allow_query       => [ 'localhost', 'lan', ],
  allow_query_cache => [ 'localhost', 'lan', ],
  allow_recursion   => [ 'localhost', 'lan', ],
}

bind::acl { 'lan':
  address_match_list => [ '192.168.10.0/24' ],
}
```
Or with hiera
```puppet
bind::allow_query:
  - localhost
  - lan
bind::allow_query_cache:
  - localhost
  - lan
bind::allow_recursion:
  - localhost
  - lan

bind::acls:
  lan:
    address_match_list: 192.168.10.0/24
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
Or with hiera
```puppet
bind::allow_query:
  - localhost
  - 10/8
bind::allow_query_cache:
  - localhost
  - 10/8
bind::allow_recursion:
  - localhost
  - 10/8
bind::forwarders:
  - 10.0.0.53
  - 10.1.1.53
```

### Manage a primary zone

Add a primary zone for the `example.com` domain and manage the zone file using Puppet:

```puppet
bind::zone::primary { 'example.com':
  source => 'puppet:///modules/profile/dns/example.com.zone',
}
```
Or with hiera
```puppet
bind::zone::primaries:
  example.com:
    source: 'puppet:///modules/profile/dns/example.com.zone'
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
  update_policy => ['grant nsupdate zonesub any'],
  content       => epp("profile/dynamic-zone-template.epp", $params),
}
```
Or with hiera
```puppet
bind::keys:
  nsupdate:
    secret: TopSecret
    keyfile: /etc/bind/nsupdate.key

bind::zone::primaries:
  example.com:
    update_policy: grant nsupdate zonesub any
    content: 'epp("profile/dynamic-zone-template.epp", $params)'
```

If the zone file `/var/lib/bind/primary/com/example/db.example.com` does not exist on the name server, a new file will be created using the specified template. After that the file content can not be managed by Puppet as `named` will periodically need to update the zone file when processing dynamic updates. The `source` or `content` parameters are ignored in this case.

Manual updates to the zone file will have to be done locally on the name server. Remember that you need to use `rndc freeze example.com` and `rndc thaw example.com` when editing the zone file manually.

### Define a DNSSEC policy for a zone

Create a new DNSSEC policy named `standard` with a Combined Signing Key (CSK) and use the policy to create a DNSSEC signed zone:

```puppet
bind::dnssec_policy { 'standard':
  csk_lifetime  => 'unlimited',
  csk_algorithm => 'ecdsap256sha256',
}

bind::zone::primary { 'example.net':
  dnssec_policy  => 'standard',
  inline_signing => true,
  source         => 'puppet:///modules/profile/dns/example.net.zone',
}
```
Or with hiera
```puppet
bind::dnssec_policies:
  standard:
    csk_lifetime: unlimited
    csk_algorithm: ecdsap256sha256

bind::zone::primaries:
  example.net:
    dnssec_policy: standard
    inline_signing: true
    source: 'puppet:///modules/profile/dns/example.net.zone'
}
```

DNSSEC policies are available with Bind 9.16 and later.

### Create views for internal and external access

The view `internal` allow recursive DNS resolution for all hosts on the local network.

```puppet
bind::view { 'internal':
  match_clients   => [ 'localnets', ],
  allow_query     => [ 'localnets', ],
  allow_recursion => [ 'localnets', ],
  recursion       => true,
  order           => '10',
}
```
Or with hiera
```puppet
bind::views:
  internal:
    match_clients: localnets
    allow_query: localnets
    allow_recursion: localnets
    recursion: true
    order: 10
```

The view `external` is for all other hosts and should only be used for your primary or secondary zones.

```puppet
bind::view { 'external':
  match_clients            => [ 'any', ],
  allow_query              => [ 'any', ],
  recursion                => false,
  localhost_forward_enable => false,
  localhost_reverse_enable => false,
  order                    => '20',
}
```
Or with hiera
```puppet
bind::views:
  external:
    match_clients: any
    allow_query: any
    recursion: false
    localhost_forward_enable: false
    localhost_reverse_enable: false
    order: 20
```

The defined types `bind::zone::primary` and `bind::zone::secondary` can be used to add zones to this view.

## Reference

See [REFERENCE.md](https://github.com/smoeding/puppet-bind/blob/master/REFERENCE.md)

## Limitations

Not all BIND features are currently implemented as I started with the options I needed myself. Some options are not yet available and features like DNSSEC are not well tested.

Creating DNSSEC keys manually using the `dnssec_key` type with automatic rollover is discouraged. The defined type `bind::dnssec_policy` should be used instead.

## Development

You may open Github issues for this module if you need additional options currently not available.

Feel free to send pull requests for new features.
