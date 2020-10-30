require 'spec_helper'

describe 'bind::logging::channel_syslog' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   daemon;\n    severity notice;\n  };\n\n")
        }
      end

      context 'with channel => "bar"' do
        let(:params) do
          { channel: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-bar')
            .with_content("  channel bar {\n    syslog   daemon;\n    severity notice;\n  };\n\n")
        }
      end

      context 'with facility => "local0"' do
        let(:params) do
          { facility: 'local0' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   local0;\n    severity notice;\n  };\n\n")
        }
      end

      context 'with severity => "debug"' do
        let(:params) do
          { severity: 'debug' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   daemon;\n    severity debug;\n  };\n\n")
        }
      end

      context 'with print_category => true' do
        let(:params) do
          { print_category: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   daemon;\n    severity notice;\n    print-category yes;\n  };\n\n")
        }
      end

      context 'with print_category => false' do
        let(:params) do
          { print_category: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .without_content(%r{print-category})
        }
      end

      context 'with print_severity => true' do
        let(:params) do
          { print_severity: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   daemon;\n    severity notice;\n    print-severity yes;\n  };\n\n")
        }
      end

      context 'with print_severity => false' do
        let(:params) do
          { print_severity: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .without_content(%r{print-severity})
        }
      end

      context 'with print_time => true' do
        let(:params) do
          { print_time: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .with_content("  channel foo {\n    syslog   daemon;\n    severity notice;\n    print-time yes;\n  };\n\n")
        }
      end

      context 'with print_time => false' do
        let(:params) do
          { print_time: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf-channel-foo')
            .with_target('named.conf.logging')
            .with_order('20-foo')
            .without_content(%r{print-time})
        }
      end
    end
  end
end
