require 'spec_helper'

describe 'bind::key' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with key => "bar"' do
        let(:params) do
          { key: 'bar' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/bar.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"bar\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/bar.key";')
            .with_order('10')
        }
      end

      context 'with algorithm => "hmac-md5"' do
        let(:params) do
          { algorithm: 'hmac-md5' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-md5;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with owner => "foo"' do
        let(:params) do
          { owner: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('foo')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with group => "foo"' do
        let(:params) do
          { group: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('foo')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with mode => "0642"' do
        let(:params) do
          { mode: '0642' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0642')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with keyfile => "/foo/bar/baz.key"' do
        let(:params) do
          { keyfile: '/foo/bar/baz.key' }
        end

        it {
          is_expected.to contain_file('/foo/bar/baz.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"[a-zA-Z0-9=]+\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/foo/bar/baz.key";')
            .with_order('10')
        }
      end

      context 'with base64_secret => "deadbeef"' do
        let(:params) do
          { base64_secret: 'deadbeef' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"deadbeef\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with secret => "deadbeef"' do
        let(:params) do
          { secret: 'deadbeef' }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(%r{key \"foo\" {\n\s+algorithm hmac-sha256;\n\s+secret\s+\"ZGVhZGJlZWY=\";\n}})
            .that_notifies('Service[bind]')
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with manage_content => false' do
        let(:params) do
          { manage_content: false }
        end

        it {
          is_expected.to contain_file('/etc/bind/keys/foo.key')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .with_content(nil)
            .that_comes_before('Concat::Fragment[bind::key::foo]')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end

      context 'with manage_keyfile => false' do
        let(:params) do
          { manage_keyfile: false }
        end

        it {
          is_expected.not_to contain_file('/etc/bind/keys/foo.key')

          is_expected.to contain_concat__fragment('bind::key::foo')
            .with_target('named.conf.keys')
            .with_content('include "/etc/bind/keys/foo.key";')
            .with_order('10')
        }
      end
    end
  end
end
