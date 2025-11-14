# frozen_string_literal: true

require 'spec_helper'

describe 'bind' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        case facts[:os]['name']
        when 'Debian', 'Ubuntu'
          it {
            is_expected.to contain_package('bind')
              .with_ensure('installed')
              .with_name('bind9')
          }

          #
          # Directories & Files
          #

          it {
            is_expected.to contain_file('/etc/bind')
              .with_ensure('directory')
              .with_owner('root')
              .with_group('bind')
              .with_mode('2755')
              .that_requires('Package[bind]')

            is_expected.to contain_file('/var/lib/bind')
              .with_ensure('directory')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0775')
              .that_requires('Package[bind]')

            is_expected.to contain_file('/var/lib/bind/keys')
              .with_ensure('directory')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0750')
              .that_comes_before('Bind::Config[named.conf]')

            is_expected.to contain_file('/var/lib/bind/primary')
              .with_ensure('directory')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0750')
              .that_comes_before('Bind::Config[named.conf]')

            is_expected.to contain_file('/var/lib/bind/primary/README')
              .with_ensure('file')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0444')
              .with_source('puppet:///modules/bind/README.primary')

            is_expected.to contain_file('/var/lib/bind/secondary')
              .with_ensure('directory')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0750')
              .that_comes_before('Bind::Config[named.conf]')

            is_expected.to contain_file('/var/lib/bind/secondary/README')
              .with_ensure('file')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0444')
              .with_source('puppet:///modules/bind/README.secondary')

            is_expected.to contain_file('/var/cache/bind')
              .with_ensure('directory')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0775')
              .that_requires('Package[bind]')
              .that_comes_before('Bind::Config[named.conf]')
          }

          #
          # Keys
          #

          it {
            is_expected.to contain_file('/etc/bind/keys')
              .with_ensure('directory')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0770')

            is_expected.to contain_concat('named.conf.keys')
              .with_path('/etc/bind/named.conf.keys')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')

            is_expected.to contain_bind__key('rndc-key')
              .with_keyfile('/etc/bind/rndc.key')
              .with_manage_content(false)
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')

            is_expected.to contain_file('/etc/bind/rndc.key')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .that_comes_before('Concat::Fragment[bind::key::rndc-key]')
              .that_notifies('Service[bind]')

            is_expected.to contain_concat__fragment('bind::key::rndc-key')
              .with_target('named.conf.keys')
              .with_order('10')
              .with_content('include "/etc/bind/rndc.key";')
          }

          #
          # Logging
          #

          it {
            is_expected.to contain_concat('named.conf.logging')
              .with_path('/etc/bind/named.conf.logging')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')

            is_expected.to contain_concat__fragment('named.conf.logging-start')
              .with_target('named.conf.logging')
              .with_order('00')
              .with_content("\nlogging {\n")

            is_expected.to contain_concat__fragment('named.conf.logging-end')
              .with_target('named.conf.logging')
              .with_order('99')
              .with_content("};\n")
          }

          #
          # ACLs
          #

          it {
            is_expected.to contain_concat('named.conf.acls')
              .with_path('/etc/bind/named.conf.acls')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')
          }

          #
          # Views
          #

          it {
            is_expected.to contain_concat('named.conf.views')
              .with_ensure('absent')
              .with_path('/etc/bind/named.conf.views')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')
          }

          #
          # Rate Limiting
          #

          it {
            is_expected.not_to contain_concat__fragment('named.conf.rate-limit')
          }

          #
          # DNSSEC policies
          #

          it {
            is_expected.not_to contain_concat('named.conf.policies')
          }

          #
          # Zones
          #

          it {
            is_expected.to contain_concat('named.conf.zones')
              .with_path('/etc/bind/named.conf.zones')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')
          }

          #
          # Options
          #

          it {
            is_expected.to contain_concat('named.conf.options')
              .with_path('/etc/bind/named.conf.options')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')

            is_expected.to contain_concat__fragment('named.conf.options-head')
              .with_target('named.conf.options')
              .with_order('10')
              .with_content("\noptions {\n  directory \"/var/cache/bind\";\n\n")

            is_expected.to contain_concat__fragment('named.conf.options-main')
              .with_target('named.conf.options')
              .with_order('75')
              .with_content("\n  // DNSSEC\n  dnssec-enable     yes;\n  dnssec-validation auto;\n  dnssec-lookaside  no;\n\n  key-directory \"/etc/bind/keys\";\n\n  auth-nxdomain no;\n")

            is_expected.to contain_concat__fragment('named.conf.options-tail')
              .with_target('named.conf.options')
              .with_order('85')
              .with_content("};\n")
          }

          #
          # Listen-on
          #

          it {
            is_expected.not_to contain_bind__listen_on('bind::listen-on')
            is_expected.not_to contain_bind__listen_on_v6('bind::listen-on-v6')
          }

          #
          # Options
          #

          it {
            is_expected.not_to contain_bind__aml('forwarders')
            is_expected.not_to contain_concat__fragment('named.conf.options-forward')
          }

          it {
            is_expected.not_to contain_bind__aml('blackhole')
          }

          it {
            is_expected.not_to contain_bind__aml('allow-query')
            is_expected.not_to contain_bind__aml('allow-query-cache')
          }

          it {
            is_expected.to contain_concat__fragment('named.conf.options-recursion')
              .with_target('named.conf.options')
              .with_order('35')
              .with_content('  recursion no;')

            is_expected.not_to contain_bind__aml('allow-recursion')
          }

          #
          # Main Configuration
          #

          it {
            is_expected.to contain_bind__config('named.conf')

            is_expected.to contain_file('/etc/bind/named.conf')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')

            is_expected.to contain_file('/etc/bind/named.conf.local')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_replace(false)
              .with_source('puppet:///modules/bind/named.conf.local')
              .that_comes_before('Service[bind]')
          }

          it {
            is_expected.to contain_bind__config('db.root')
              .with_source('puppet:///modules/bind/zones/db.root')

            is_expected.to contain_file('/etc/bind/db.root')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_source('puppet:///modules/bind/zones/db.root')
              .that_notifies('Service[bind]')

            is_expected.to contain_bind__config('db.localhost')
              .with_source('puppet:///modules/bind/zones/db.localhost')

            is_expected.to contain_file('/etc/bind/db.localhost')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_source('puppet:///modules/bind/zones/db.localhost')
              .that_notifies('Service[bind]')

            is_expected.to contain_bind__config('db.127')
              .with_source('puppet:///modules/bind/zones/db.127')

            is_expected.to contain_file('/etc/bind/db.127')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_source('puppet:///modules/bind/zones/db.127')
              .that_notifies('Service[bind]')

            is_expected.to contain_bind__config('db.empty')
              .with_source('puppet:///modules/bind/zones/db.empty')

            is_expected.to contain_file('/etc/bind/db.empty')
              .with_ensure('file')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_source('puppet:///modules/bind/zones/db.empty')
              .that_notifies('Service[bind]')
          }

          it {
            is_expected.not_to contain_bind__zone__hint('.')

            is_expected.not_to contain_bind__zone__mirror('.')

            is_expected.to contain_bind__zone__primary('localhost')
              .with_file('/etc/bind/db.localhost')
              .with_order('15')

            is_expected.to contain_concat__fragment('named.conf.zones-localhost')

            is_expected.to contain_bind__zone__primary('127.in-addr.arpa')
              .with_file('/etc/bind/db.127')
              .with_order('15')

            is_expected.to contain_concat__fragment('named.conf.zones-127.in-addr.arpa')
          }
        end

        #
        # Options
        #
        case "#{facts[:os]['name']}-#{facts[:os]['release']['major']}"
        when 'Debian-10'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/bind9')
              .with_line('OPTIONS="-u bind"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        else
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/named')
              .with_line('OPTIONS="-u bind"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        end

        #
        # Service
        #

        it {
          case "#{facts[:os]['name']}-#{facts[:os]['release']['major']}"
          when 'Debian-10'
            is_expected.to contain_service('bind')
              .with_ensure('running')
              .with_enable(true)
              .with_name('bind9')
              .with_restart('/usr/sbin/rndc reconfig')
          else
            is_expected.to contain_service('bind')
              .with_ensure('running')
              .with_enable(true)
              .with_name('named')
              .with_restart('/usr/sbin/rndc reconfig')
          end
        }
      end

      context 'with views_enable => true' do
        let(:params) do
          { views_enable: true }
        end

        it {
          case facts[:os]['name']
          when 'Debian', 'Ubuntu'
            is_expected.to contain_concat('named.conf.views')
              .with_ensure('present')
              .with_path('/etc/bind/named.conf.views')
              .with_owner('root')
              .with_group('bind')
              .with_mode('0640')
              .with_ensure_newline(true)
              .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
              .that_requires('File[/etc/bind]')
              .that_notifies('Service[bind]')

            is_expected.not_to contain_bind__zone__hint('.')
            is_expected.not_to contain_bind__zone__mirror('.')
            is_expected.not_to contain_bind__zone__primary('localhost')
            is_expected.not_to contain_bind__zone__primary('127.in-addr.arpa')
          end
        }
      end

      context 'with ipv4_enable => false' do
        let(:params) do
          { ipv4_enable: false }
        end

        it {
          case facts[:os]['name']
          when 'Debian'
            is_expected.to contain_file_line('named-options')
              .with_line('OPTIONS="-u bind -6"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          when 'Ubuntu'
            is_expected.to contain_file_line('named-options')
              .with_line('OPTIONS="-u bind -6"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          end
        }
      end

      context 'with ipv6_enable => false' do
        let(:params) do
          { ipv6_enable: false }
        end

        it {
          case facts[:os]['name']
          when 'Debian'
            is_expected.to contain_file_line('named-options')
              .with_line('OPTIONS="-u bind -4"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          when 'Ubuntu'
            is_expected.to contain_file_line('named-options')
              .with_line('OPTIONS="-u bind -4"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          end
        }
      end

      context 'with ipv4_enable => false, ipv6_enable => false' do
        let(:params) do
          { ipv4_enable: false, ipv6_enable: false }
        end

        it {
          is_expected.to compile.and_raise_error(%r{One of ipv4_enable or ipv6_enable must be true})
        }
      end

      context 'with root_hints_enable => true' do
        let(:params) do
          { root_hints_enable: true }
        end

        it {
          is_expected.to contain_bind__zone__hint('.')
            .with_file('/etc/bind/db.root')
            .with_comment('Prime server with knowledge of the root servers')

          is_expected.to contain_concat__fragment('named.conf.zones-.')
        }
      end

      context 'with root_mirror_enable => true' do
        let(:params) do
          { root_mirror_enable: true }
        end

        it {
          is_expected.to contain_bind__zone__mirror('.')
            .with_comment('Local copy of the root zone (see RFC 7706)')
            .with_order('11')
        }
      end

      context 'with localhost_forward_enable => false' do
        let(:params) do
          { localhost_forward_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__primary('localhost')
        }
      end

      context 'with localhost_reverse_enable => false' do
        let(:params) do
          { localhost_reverse_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__primary('127.in-addr.arpa')
        }
      end

      context 'with dnssec_enable => false' do
        let(:params) do
          { dnssec_enable: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{dnssec-enable\s+no;})
        }
      end

      context 'with dnssec_lookaside => false' do
        let(:params) do
          { dnssec_lookaside: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{dnssec-lookaside\s+no;})
        }
      end

      context 'with dnssec_validation => yes' do
        let(:params) do
          { dnssec_validation: 'yes' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{dnssec-validation\s+yes;})
        }
      end

      context 'with dnssec_validation => no' do
        let(:params) do
          { dnssec_validation: 'no' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{dnssec-validation\s+no;})
        }
      end

      context 'with empty_zones_enable => false' do
        let(:params) do
          { empty_zones_enable: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{empty-zones-enable\s+no;})
        }
      end

      context 'with trust_anchor_telemetry => false' do
        let(:params) do
          { trust_anchor_telemetry: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{trust-anchor-telemetry\s+no;})
        }
      end

      context 'with listen_on => ["any"]' do
        let(:params) do
          { listen_on: ['any'] }
        end

        it {
          is_expected.to contain_bind__listen_on('bind::listen-on')
            .with_address(['any'])
        }
      end

      context 'with listen_on_v6 => ["any"]' do
        let(:params) do
          { listen_on_v6: ['any'] }
        end

        it {
          is_expected.to contain_bind__listen_on_v6('bind::listen-on-v6')
            .with_address(['any'])
        }
      end

      context 'with forwarders => ["192.0.2.42"]' do
        let(:params) do
          { forwarders: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_bind__aml('forwarders')
            .with_address_match_list(['192.0.2.42'])
            .with_target('named.conf.options')
            .with_order('20')
            .with_omit_empty_list(true)
            .with_final_empty_line(false)

          is_expected.to contain_concat__fragment('bind::named.conf.options::forwarders')
            .with_target('named.conf.options')
            .with_order('20')

          is_expected.to contain_concat__fragment('named.conf.options-forward')
            .with_target('named.conf.options')
            .with_order('21')
            .with_content("  forward first;\n\n")
        }
      end

      context 'with forwarders => ["192.0.2.42"], forward => "only"' do
        let(:params) do
          { forwarders: ['192.0.2.42'], forward: 'only' }
        end

        it {
          is_expected.to contain_bind__aml('forwarders')
            .with_address_match_list(['192.0.2.42'])
            .with_target('named.conf.options')
            .with_order('20')
            .with_omit_empty_list(true)
            .with_final_empty_line(false)

          is_expected.to contain_concat__fragment('named.conf.options-forward')
            .with_target('named.conf.options')
            .with_order('21')
            .with_content("  forward only;\n\n")
        }
      end

      context 'with blackhole => ["192.0.2.42"]' do
        let(:params) do
          { blackhole: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_bind__aml('blackhole')
            .with_address_match_list(['192.0.2.42'])
            .with_target('named.conf.options')
            .with_order('40')
            .with_initial_empty_line(true)
            .with_final_empty_line(false)

          is_expected.to contain_concat__fragment('bind::named.conf.options::blackhole')
            .with_target('named.conf.options')
            .with_order('40')
            .with_content("\n  blackhole { 192.0.2.42; };\n")
        }
      end

      context 'with allow_query => ["any"]' do
        let(:params) do
          { allow_query: ['any'] }
        end

        it {
          is_expected.to contain_bind__aml('allow-query')
            .with_address_match_list(['any'])
            .with_target('named.conf.options')
            .with_order('30')

          is_expected.to contain_concat__fragment('bind::named.conf.options::allow-query')
            .with_target('named.conf.options')
            .with_order('30')

          is_expected.not_to contain_bind__aml('allow-query-cache')
        }
      end

      context 'with allow_query_cache => ["any"]' do
        let(:params) do
          { allow_query_cache: ['any'] }
        end

        it {
          is_expected.not_to contain_bind__aml('allow-query')

          is_expected.to contain_bind__aml('allow-query-cache')
            .with_address_match_list(['any'])
            .with_target('named.conf.options')
            .with_order('31')

          is_expected.to contain_concat__fragment('bind::named.conf.options::allow-query-cache')
            .with_target('named.conf.options')
            .with_order('31')
        }
      end

      context 'with manage_rndc_keyfile => false' do
        let(:params) do
          { manage_rndc_keyfile: false }
        end

        it {
          is_expected.not_to contain_bind__key('rndc-key')
        }
      end

      context 'with control_channels_enable => false' do
        let(:params) do
          { control_channels_enable: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\n// Disable controls\ncontrols { };\n")
        }
      end

      context 'with custom_options => { foo => 1 }' do
        let(:params) do
          { custom_options: { 'foo' => 1 } }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-custom')
            .with_target('named.conf.options')
            .with_order('83')
            .with_content("  foo 1;\n")
        }
      end

      context 'with custom_options => { foo => "bar" }' do
        let(:params) do
          { custom_options: { 'foo' => 'bar' } }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-custom')
            .with_target('named.conf.options')
            .with_order('83')
            .with_content("  foo bar;\n")
        }
      end

      context 'with custom_options => { foo => ["bar"] }' do
        let(:params) do
          { custom_options: { 'foo' => ['bar'] } }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-custom')
            .with_target('named.conf.options')
            .with_order('83')
            .with_content("  foo { bar; };\n")
        }
      end

      context 'with custom_options => { foo => ["bar", "baz"] }' do
        let(:params) do
          { custom_options: { 'foo' => %w[bar baz] } }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-custom')
            .with_target('named.conf.options')
            .with_order('83')
            .with_content("  foo {\n    bar;\n    baz;\n  };\n")
        }
      end

      context 'with custom_options => { foo => { bar => baz } }' do
        let(:params) do
          { custom_options: { 'foo' => { 'bar' => 'baz' } } }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-custom')
            .with_target('named.conf.options')
            .with_order('83')
            .with_content("  foo {\n    bar baz;\n  };\n")
        }
      end

      context 'with filter_aaaa_on_v4 => yes' do
        let(:params) do
          { filter_aaaa_on_v4: 'yes' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{filter-aaaa-on-v4 yes;})
        }
      end

      context 'with filter_aaaa_on_v4 => no' do
        let(:params) do
          { filter_aaaa_on_v4: 'no' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{filter-aaaa-on-v4 no;})
        }
      end

      context 'with filter_aaaa_on_v4 => break-dnssec' do
        let(:params) do
          { filter_aaaa_on_v4: 'break-dnssec' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{filter-aaaa-on-v4 break-dnssec;})
        }
      end

      context 'with all_per_second => 1000' do
        let(:params) do
          { all_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with errors_per_second => 1000' do
        let(:params) do
          { errors_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    errors-per-second    1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with responses_per_second => 1000' do
        let(:params) do
          { responses_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    responses-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with referrals_per_second => 1000' do
        let(:params) do
          { referrals_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    referrals-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with nodata_per_second => 1000' do
        let(:params) do
          { nodata_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    nodata-per-second    1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with nxdomains_per_second => 1000' do
        let(:params) do
          { nxdomains_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    nxdomains-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with qps_scale => 10' do
        let(:params) do
          { qps_scale: 10 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    qps_scale 10;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with slip => 10' do
        let(:params) do
          { slip: 10 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    slip      10;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, window => 3600' do
        let(:params) do
          { all_per_second: 1000, window: 3600 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    window    3600;\n    all-per-second       1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, ipv4_prefix_length => 16' do
        let(:params) do
          { all_per_second: 1000, ipv4_prefix_length: 16 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    // default: 24\n    ipv4-prefix-length 16;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, ipv6_prefix_length => 16' do
        let(:params) do
          { all_per_second: 1000, ipv6_prefix_length: 16 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    // default: 56\n    ipv6-prefix-length 16;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, log_only => true' do
        let(:params) do
          { all_per_second: 1000, log_only: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, exempt_clients => ["192.0.2.42"]' do
        let(:params) do
          { all_per_second: 1000, exempt_clients: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    exempt-clients { 192.0.2.42; };\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, exempt_clients => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { all_per_second: 1000, exempt_clients: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    exempt-clients {\n      192.0.2.42;\n      192.0.2.69;\n    };\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with logdir => /var/log/named' do
        let(:params) do
          { logdir: '/var/log/named' }
        end

        it {
          is_expected.to contain_file('/var/log/named')
            .with_ensure('directory')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0750')
        }
      end

      context 'with max_cache_size => default' do
        let(:params) do
          { max_cache_size: 'default' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{max-cache-size default;})
        }
      end

      context 'with max_cache_size => unlimited' do
        let(:params) do
          { max_cache_size: 'unlimited' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{max-cache-size unlimited;})
        }
      end

      context 'with max_cache_size => 0' do
        let(:params) do
          { max_cache_size: 0 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{max-cache-size 0;})
        }
      end

      context 'with max_cache_size => 10%' do
        let(:params) do
          { max_cache_size: '10%' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{max-cache-size 10%;})
        }
      end

      context 'with max_cache_size => 2g' do
        let(:params) do
          { max_cache_size: '2g' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content(%r{max-cache-size 2g;})
        }
      end

    end

    context "on #{os} with bind 9.16.0" do
      let(:facts) { facts.merge(named_version: '9.16.0') }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .with_content("\n  // DNSSEC\n  dnssec-validation auto;\n\n  key-directory \"/etc/bind/keys\";\n\n  auth-nxdomain no;\n")
        }

        #
        # DNSSEC policies
        #

        it {
          is_expected.to contain_bind__config('named.conf')
            .with_content(%r{named.conf.policies})
        }

        it {
          is_expected.to contain_concat('named.conf.policies')
            .with_path('/etc/bind/named.conf.policies')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_ensure_newline(true)
            .with_warn('// This file is managed by Puppet. DO NOT EDIT.')
            .that_requires('File[/etc/bind]')
            .that_notifies('Service[bind]')
        }
      end

      context 'with filter_aaaa_on_v4 => yes' do
        let(:params) do
          { filter_aaaa_on_v4: 'yes' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .without_content(%r{filter-aaaa-on-v4})
        }
      end

      context 'with filter_aaaa_on_v4 => no' do
        let(:params) do
          { filter_aaaa_on_v4: 'no' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .without_content(%r{filter-aaaa-on-v4})
        }
      end

      context 'with filter_aaaa_on_v4 => break-dnssec' do
        let(:params) do
          { filter_aaaa_on_v4: 'break-dnssec' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_target('named.conf.options')
            .with_order('75')
            .without_content(%r{filter-aaaa-on-v4})
        }
      end
    end
  end
end
