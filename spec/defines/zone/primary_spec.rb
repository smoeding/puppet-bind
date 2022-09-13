require 'spec_helper'

describe 'bind::zone::primary' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content("\nzone \"example.com\" IN {\n  type master;\n  file \"/var/lib/bind/primary/com/example/db.example.com\";\n};\n")
        }
      end

      context 'with file => "/file"' do
        let(:params) do
          { file: '/file' }
        end

        it {
          is_expected.not_to contain_file('/file')
          is_expected.not_to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content("\nzone \"example.com\" IN {\n  type master;\n  file \"/file\";\n};\n")
        }
      end

      context 'with source => "/file"' do
        let(:params) do
          { source: '/file' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .with_source('/file')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content("\nzone \"example.com\" IN {\n  type master;\n  file \"/var/lib/bind/primary/com/example/db.example.com\";\n};\n")
        }
      end

      context 'with content => "something"' do
        let(:params) do
          { content: 'something' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .with_content('something')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content("\nzone \"example.com\" IN {\n  type master;\n  file \"/var/lib/bind/primary/com/example/db.example.com\";\n};\n")
        }
      end

      context 'with content => "something", class => "HS"' do
        let(:params) do
          { content: 'something', class: 'HS' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .with_content('something')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com HS')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content("\nzone \"example.com\" HS {\n  type master;\n  file \"/var/lib/bind/primary/com/example/db.example.com\";\n};\n")
        }
      end

      context 'with source => "/file", dnssec => true' do
        let(:params) do
          { source: '/file', dnssec: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-enable\s+yes;\n\s+auto-dnssec\s+off;\n\s+inline-signing\s+no;\n\s+key-directory\s+"/etc/bind/keys";})
        }
      end

      context 'with source => "/file", dnssec => true, auto_dnssec => "maintain"' do
        let(:params) do
          { source: '/file', dnssec: true, auto_dnssec: 'maintain' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{auto-dnssec\s+maintain;})
        }
      end

      context 'with source => "/file", dnssec => true, dnssec_policy => "foo"' do
        let(:params) do
          { source: '/file', dnssec: true, dnssec_policy: 'foo' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-policy\s+"foo";})
        }
      end

      context 'with source => "/file", dnssec => true, dnssec_loadkeys_interval => 42' do
        let(:params) do
          { source: '/file', dnssec: true, dnssec_loadkeys_interval: 42 }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-loadkeys-interval\s+42;})
        }
      end

      context 'with source => "/file", dnssec => true, dnssec_dnskey_kskonly => true' do
        let(:params) do
          { source: '/file', dnssec: true, dnssec_dnskey_kskonly: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-dnskey-kskonly\s+yes;})
        }
      end

      context 'with source => "/file", dnssec => true, dnssec_secure_to_insecure => true' do
        let(:params) do
          { source: '/file', dnssec: true, dnssec_secure_to_insecure: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-secure-to-insecure\s+yes;})
        }
      end

      context 'with source => "/file", dnssec => true, dnssec_update_mode => "maintain"' do
        let(:params) do
          { source: '/file', dnssec: true, dnssec_update_mode: 'maintain' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-update-mode\s+maintain;})
        }
      end

      context 'with source => "/file", dnssec => true, dnskey_sig_validity => 42' do
        let(:params) do
          { source: '/file', dnssec: true, dnskey_sig_validity: 42 }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnskey-sig-validity\s+42;})
        }
      end

      context 'with source => "/file", dnssec => true, inline_signing => true' do
        let(:params) do
          { source: '/file', dnssec: true, inline_signing: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{inline-signing\s+yes;})
        }
      end

      context 'with source => "/file", dnssec => true, notify_secondaries => "explicit"' do
        let(:params) do
          { source: '/file', dnssec: true, notify_secondaries: 'explicit' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{notify\s+explicit;})
        }
      end

      context 'with source => "/file", dnssec => true, also_notify => ["192.0.2.42"]' do
        let(:params) do
          { source: '/file', dnssec: true, also_notify: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{also-notify {\n\s+192.0.2.42;\n\s+};})
        }
      end

      context 'with source => "/file", dnssec => true, zone_statistics => true' do
        let(:params) do
          { source: '/file', dnssec: true, zone_statistics: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{zone-statistics\s+yes;})
        }
      end
    end
  end
end
