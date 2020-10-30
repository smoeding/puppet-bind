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
          # Directories
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

            is_expected.to contain_file('/var/lib/bind/primary')
              .with_ensure('directory')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0750')
              .that_comes_before('Bind::Config[named.conf]')

            is_expected.to contain_file('/var/lib/bind/secondary')
              .with_ensure('directory')
              .with_owner('bind')
              .with_group('bind')
              .with_mode('0750')
              .that_comes_before('Bind::Config[named.conf]')

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
              .with_mode('0750')

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
              .with_algorithm('hmac-md5')
              .with_seed('rndc')
              .that_notifies('Service[bind]')
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
              .with_content("  // DNSSEC\n  dnssec-enable     yes;\n  dnssec-validation auto;\n  dnssec-lookaside  no;\n\n  key-directory \"/etc/bind/keys\";\n\n  auth-nxdomain no;\n")

            is_expected.to contain_concat__fragment('named.conf.options-tail')
              .with_target('named.conf.options')
              .with_order('85')
              .with_content("};\n")

            is_expected.to contain_concat__fragment('named.conf.controls')
              .with_target('named.conf.options')
              .with_order('90')
              .with_content("\ncontrols {\n  inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { \"rndc-key\"; };\n};\n")
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

            is_expected.to contain_bind__config('db.localhost')
              .with_source('puppet:///modules/bind/zones/db.localhost')

            is_expected.to contain_bind__config('db.127')
              .with_source('puppet:///modules/bind/zones/db.127')

            is_expected.to contain_bind__config('db.empty')
              .with_source('puppet:///modules/bind/zones/db.empty')
          }

          it {
            is_expected.to contain_bind__zone__hint('.')
              .with_file('/etc/bind/db.root')
              .with_comment('Prime server with knowledge of the root servers')

            is_expected.not_to contain_bind__zone__mirror('.')

            is_expected.to contain_bind__zone__primary('localhost')
              .with_file('/etc/bind/db.localhost')
              .with_order('15')

            is_expected.to contain_bind__zone__primary('127.in-addr.arpa')
              .with_file('/etc/bind/db.127')
              .with_order('15')
          }
        end

        #
        # Service
        #

        case facts[:os]['name']
        when 'Debian'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/bind9')
              .with_line('OPTIONS="-u bind"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        when 'Ubuntu'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/named')
              .with_line('OPTIONS="-u bind"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        end

        it {
          is_expected.to contain_service('bind')
            .with_ensure('running')
            .with_enable(true)
            .with_name('bind9')
            .with_restart('/usr/sbin/rndc reconfig')
        }
      end

      context 'with views_enable => true' do
        let(:params) do
          { views_enable: true }
        end

        case facts[:os]['name']
        when 'Debian', 'Ubuntu'
          it {
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
          }
        end
      end

      context 'with ipv4_enable => false' do
        let(:params) do
          { ipv4_enable: false }
        end

        case facts[:os]['name']
        when 'Debian'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/bind9')
              .with_line('OPTIONS="-u bind -6"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        when 'Ubuntu'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/named')
              .with_line('OPTIONS="-u bind -6"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        end
      end

      context 'with ipv6_enable => false' do
        let(:params) do
          { ipv6_enable: false }
        end

        case facts[:os]['name']
        when 'Debian'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/bind9')
              .with_line('OPTIONS="-u bind -4"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        when 'Ubuntu'
          it {
            is_expected.to contain_file_line('named-options')
              .with_path('/etc/default/named')
              .with_line('OPTIONS="-u bind -4"')
              .with_match('^OPTIONS=')
              .that_requires('Package[bind]')
              .that_notifies('Service[bind]')
          }
        end
      end

      context 'with ipv4_enable => false, ipv6_enable => false' do
        let(:params) do
          { ipv4_enable: false, ipv6_enable: false }
        end

        it {
          is_expected.to compile.and_raise_error(%r{One of ipv4_enable or ipv6_enable must be true})
        }
      end

      context 'with root_hints_enable => false' do
        let(:params) do
          { root_hints_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__hint('.')
        }
      end

      context 'with root_mirror_enable => false' do
        let(:params) do
          { root_mirror_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__mirror('.')
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

      context 'with empty_zones_enable => false' do
        let(:params) do
          { empty_zones_enable: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.options-main')
            .with_content(%r{empty-zones-enable\s+no;})
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
        }
      end
    end
  end
end
