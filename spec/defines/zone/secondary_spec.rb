require 'spec_helper'

describe 'bind::zone::secondary' do
  let(:title) { 'example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'class { "bind": }'
      end

      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with masters => ["192.0.2.42"]' do
        let(:params) do
          { masters: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/secondary/com')
          is_expected.to contain_file('/var/lib/bind/secondary/com/example')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('30')
            .with_content("\nzone \"example.com\" IN {\n  type slave;\n  masters { 192.0.2.42; };\n  file \"/var/lib/bind/secondary/com/example/db.example.com\";\n};\n")

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_requires('Service[bind]')
        }
      end

      context 'with masters => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { masters: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/secondary/com')
          is_expected.to contain_file('/var/lib/bind/secondary/com/example')

          is_expected.to contain_concat__fragment('named.conf.zones-example.com')
            .with_target('named.conf.zones')
            .with_order('30')
            .with_content("\nzone \"example.com\" IN {\n  type slave;\n  masters { 192.0.2.42; 192.0.2.69; };\n  file \"/var/lib/bind/secondary/com/example/db.example.com\";\n};\n")

          is_expected.to contain_exec('bind::reload::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_requires('Service[bind]')
        }
      end
    end
  end

  on_supported_os.each do |os, facts|
    let(:pre_condition) do
      'class { "bind": views_enable => true } bind::view { "internal": }'
    end

    context "on #{os}" do
      let(:facts) { facts }

      context 'with view => "internal"' do
        let(:params) do
          { view: 'internal' }
        end

        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with view => "internal", masters => ["192.0.2.42"]' do
        let(:params) do
          { view: 'internal', masters: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/secondary/com')
          is_expected.to contain_file('/var/lib/bind/secondary/com/example')

          is_expected.to contain_concat__fragment('named.conf.views-internal-60-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type slave;\n    masters { 192.0.2.42; };\n    file \"/var/lib/bind/secondary/com/example/db.example.com\";\n  };\n")

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_requires('Service[bind]')
        }
      end

      context 'with view => "internal", masters => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { view: 'internal', masters: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_file('/var/lib/bind/secondary/com')
          is_expected.to contain_file('/var/lib/bind/secondary/com/example')

          is_expected.to contain_concat__fragment('named.conf.views-internal-60-example.com')
            .with_target('named.conf.views')
            .with_order('10')
            .with_content("\n  zone \"example.com\" IN {\n    type slave;\n    masters { 192.0.2.42; 192.0.2.69; };\n    file \"/var/lib/bind/secondary/com/example/db.example.com\";\n  };\n")

          is_expected.to contain_exec('bind::reload::internal::example.com')
            .with_command('/usr/sbin/rndc reload example.com IN internal')
            .with_user('root')
            .with_cwd('/')
            .with_refreshonly(true)
            .that_requires('Service[bind]')
        }
      end
    end
  end
end
