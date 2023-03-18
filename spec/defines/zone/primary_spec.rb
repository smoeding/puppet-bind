require 'spec_helper'

describe 'bind::zone::primary' do
  let(:title) { 'example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'class { "bind": }'
      end

      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
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
            .with_mode('0644')
            .with_replace(true)
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
            .with_mode('0644')
            .with_replace(true)
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
            .with_mode('0644')
            .with_replace(true)
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

      context 'with source => "/file", dnssec_enable => true' do
        let(:params) do
          { source: '/file', dnssec_enable: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{dnssec-enable\s+yes;})
        }
      end

      context 'with source => "/file", auto_dnssec => "maintain"' do
        let(:params) do
          { source: '/file', auto_dnssec: 'maintain' }
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

      context 'with source => "/file", dnssec_policy => "foo"' do
        let(:params) do
          { source: '/file', dnssec_policy: 'foo' }
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
            .with_content(%r{dnssec-policy\s+"foo";\n\s+key-directory\s+"/var/lib/bind/keys";})
        }
      end

      context 'with source => "/file", dnssec_loadkeys_interval => 42' do
        let(:params) do
          { source: '/file', dnssec_loadkeys_interval: 42 }
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

      context 'with source => "/file", dnssec_dnskey_kskonly => true' do
        let(:params) do
          { source: '/file', dnssec_dnskey_kskonly: true }
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

      context 'with source => "/file", dnssec_secure_to_insecure => true' do
        let(:params) do
          { source: '/file', dnssec_secure_to_insecure: true }
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

      context 'with source => "/file", dnssec_update_mode => "maintain"' do
        let(:params) do
          { source: '/file', dnssec_update_mode: 'maintain' }
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

      context 'with source => "/file", dnskey_sig_validity => 42' do
        let(:params) do
          { source: '/file', dnskey_sig_validity: 42 }
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

      context 'with source => "/file", inline_signing => true' do
        let(:params) do
          { source: '/file', inline_signing: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{inline-signing\s+yes;\n\s+key-directory\s+"/var/lib/bind/keys";})
        }
      end

      context 'with source => "/file", notify_secondaries => "explicit"' do
        let(:params) do
          { source: '/file', notify_secondaries: 'explicit' }
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

      context 'with source => "/file", also_notify => ["192.0.2.42"]' do
        let(:params) do
          { source: '/file', also_notify: ['192.0.2.42'] }
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

      context 'with source => "/file", zone_statistics => true' do
        let(:params) do
          { source: '/file', zone_statistics: true }
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

      context 'with update_policy => local' do
        let(:params) do
          { update_policy: 'local' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(false)

          is_expected.not_to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{update-policy\s+local;})
        }
      end

      context 'with update_policy => [grant]' do
        let(:params) do
          { update_policy: ['grant updatekey zonesub any'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(false)

          is_expected.not_to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('20')
            .with_content(%r{grant updatekey zonesub any})
        }
      end

      context 'with append_view => true' do
        let(:params) do
          { append_view: true }
        end

        it {
          is_expected.to compile.and_raise_error(%r{view name must be set if append_view is true})
        }
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'class { "bind": views_enable => true } bind::view { "internal": }'
      end

      let(:facts) { facts }

      context 'with view => "internal"' do
        let(:params) do
          { view: 'internal' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type master;\n    file \"/var/lib/bind/primary/com/example/db.example.com\";\n  };\n")
        }
      end

      context 'with view => "internal", file => "/file"' do
        let(:params) do
          { view: 'internal', file: '/file' }
        end

        it {
          is_expected.not_to contain_file('/file')
          is_expected.not_to contain_exec('bind::reload::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type master;\n    file \"/file\";\n  };\n")
        }
      end

      context 'with view => "internal", source => "/file"' do
        let(:params) do
          { view: 'internal', source: '/file' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
            .with_source('/file')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type master;\n    file \"/var/lib/bind/primary/com/example/db.example.com\";\n  };\n")
        }
      end

      context 'with view => "internal", content => "something"' do
        let(:params) do
          { view: 'internal', content: 'something' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
            .with_content('something')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type master;\n    file \"/var/lib/bind/primary/com/example/db.example.com\";\n  };\n")
        }
      end

      context 'with view => "internal", content => "something", class => "HS"' do
        let(:params) do
          { view: 'internal', content: 'something', class: 'HS' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
            .with_content('something')
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com HS internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" HS {\n    type master;\n    file \"/var/lib/bind/primary/com/example/db.example.com\";\n  };\n")
        }
      end

      context 'with view => "internal", source => "/file", dnssec_enable => true' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_enable: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-enable\s+yes;})
        }
      end

      context 'with view => "internal", source => "/file", auto_dnssec => "maintain"' do
        let(:params) do
          { view: 'internal', source: '/file', auto_dnssec: 'maintain' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{auto-dnssec\s+maintain;})
        }
      end

      context 'with view => "internal", source => "/file", dnssec_policy => "foo"' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_policy: 'foo' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-policy\s+"foo";})
            .with_content(%r{dnssec-policy\s+"foo";\n  \s+key-directory\s+"/var/lib/bind/keys";})
        }
      end

      context 'with view => "internal", source => "/file", dnssec_loadkeys_interval => 42' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_loadkeys_interval: 42 }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-loadkeys-interval\s+42;})
        }
      end

      context 'with view => "internal", source => "/file", dnssec_dnskey_kskonly => true' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_dnskey_kskonly: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-dnskey-kskonly\s+yes;})
        }
      end

      context 'with view => "internal", source => "/file", dnssec_secure_to_insecure => true' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_secure_to_insecure: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-secure-to-insecure\s+yes;})
        }
      end

      context 'with view => "internal", source => "/file", dnssec_update_mode => "maintain"' do
        let(:params) do
          { view: 'internal', source: '/file', dnssec_update_mode: 'maintain' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnssec-update-mode\s+maintain;})
        }
      end

      context 'with view => "internal", source => "/file", dnskey_sig_validity => 42' do
        let(:params) do
          { view: 'internal', source: '/file', dnskey_sig_validity: 42 }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{dnskey-sig-validity\s+42;})
        }
      end

      context 'with view => "internal", source => "/file", inline_signing => true' do
        let(:params) do
          { view: 'internal', source: '/file', inline_signing: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{inline-signing\s+yes;\n  \s+key-directory\s+"/var/lib/bind/keys";})
        }
      end

      context 'with view => "internal", source => "/file", notify_secondaries => "explicit"' do
        let(:params) do
          { view: 'internal', source: '/file', notify_secondaries: 'explicit' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{notify\s+explicit;})
        }
      end

      context 'with view => "internal", source => "/file", also_notify => ["192.0.2.42"]' do
        let(:params) do
          { view: 'internal', source: '/file', also_notify: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{also-notify {\n  \s+192.0.2.42;\n  \s+};})
        }
      end

      context 'with view => "internal", source => "/file", zone_statistics => true' do
        let(:params) do
          { view: 'internal', source: '/file', zone_statistics: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')

          is_expected.to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{zone-statistics\s+yes;})
        }
      end

      context 'with view => "internal", update_policy => local' do
        let(:params) do
          { view: 'internal', update_policy: 'local' }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(false)

          is_expected.not_to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{update-policy\s+local;})
        }
      end

      context 'with view => "internal", update_policy => [grant]' do
        let(:params) do
          { view: 'internal', update_policy: ['grant updatekey zonesub any'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(false)

          is_expected.not_to contain_exec('bind::reload::internal::example.com')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content(%r{grant updatekey zonesub any})
        }
      end

      context 'with view => "internal", append_view => true' do
        let(:params) do
          { view: 'internal', append_view: true }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/primary/com')
          is_expected.to contain_file('/var/lib/bind/primary/com/example')
          is_expected.to contain_file('/var/lib/bind/primary/com/example/db.example.com_internal')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0644')
            .with_replace(true)
            .with_validate_cmd('/usr/sbin/named-checkzone -k fail -m fail -M fail -n fail example.com %')
            .that_requires('Concat[named.conf.zones]')

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_subscribes_to('File[/var/lib/bind/primary/com/example/db.example.com_internal]')
            .that_requires('Service[bind]')

          is_expected.to contain_concat__fragment('named.conf.views-internal-50-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type master;\n    file \"/var/lib/bind/primary/com/example/db.example.com_internal\";\n  };\n")
        }
      end
    end
  end
end
