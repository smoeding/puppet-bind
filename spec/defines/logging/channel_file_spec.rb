# frozen_string_literal: true

require 'spec_helper'

describe 'bind::logging::channel_file' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with logfile => "/log.log"' do
        let(:params) do
          { logfile: '/log.log' }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .with_content("  channel foo {\n    file \"/log.log\";\n    severity notice;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with logfile => "/log.log", channel => "bar"' do
        let(:params) do
          { logfile: '/log.log', channel: 'bar' }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-bar')
            .with_content("  channel bar {\n    file \"/log.log\";\n    severity notice;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with logfile => "/log.log", severity => "info"' do
        let(:params) do
          { logfile: '/log.log', severity: 'info' }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .with_content("  channel foo {\n    file \"/log.log\";\n    severity info;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with logfile => "/log.log", print_category => false' do
        let(:params) do
          { logfile: '/log.log', print_category: false }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .without_content(%r{print-category})
        }
      end

      context 'with logfile => "/log.log", print_severity => false' do
        let(:params) do
          { logfile: '/log.log', print_severity: false }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .without_content(%r{print-severity})
        }
      end

      context 'with logfile => "/log.log", print_time => false' do
        let(:params) do
          { logfile: '/log.log', print_time: false }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .without_content(%r{print-time})
        }
      end

      context 'with logfile => "/log.log", size => "1m"' do
        let(:params) do
          { logfile: '/log.log', size: '1m' }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .with_content("  channel foo {\n    file \"/log.log\" size 1m;\n    severity notice;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with logfile => "/log.log", version => 9' do
        let(:params) do
          { logfile: '/log.log', versions: 9 }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0640')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .with_content("  channel foo {\n    file \"/log.log\" versions 9;\n    severity notice;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with logfile => "/log.log", mode => "0642"' do
        let(:params) do
          { logfile: '/log.log', mode: '0642' }
        end

        it {
          is_expected.to contain_file('/log.log')
            .with_ensure('file')
            .with_owner('bind')
            .with_group('bind')
            .with_mode('0642')
            .that_comes_before('Concat[named.conf.logging]')

          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('30-foo')
            .with_content("  channel foo {\n    file \"/log.log\";\n    severity notice;\n    print-category yes;\n    print-severity yes;\n    print-time yes;\n  };\n\n")
        }
      end
    end
  end
end
