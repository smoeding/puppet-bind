require 'spec_helper'

describe 'bind::listen_on' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { '127.0.0.1' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_bind__aml('listen-on')
            .with_target('named.conf.options')
            .with_order('11')
            .with_address_match_list('127.0.0.1')

          is_expected.to contain_concat__fragment('bind::named.conf.options::listen-on')
            .with_target('named.conf.options')
            .with_order('11')
            .with_content("  listen-on { 127.0.0.1; };\n\n")
        }
      end

      context 'with port => 53' do
        let(:params) do
          { port: 53 }
        end

        it {
          is_expected.to contain_bind__aml('listen-on port 53')
            .with_target('named.conf.options')
            .with_order('12')
            .with_address_match_list('127.0.0.1')

          is_expected.to contain_concat__fragment('bind::named.conf.options::listen-on port 53')
            .with_target('named.conf.options')
            .with_order('12')
            .with_content("  listen-on port 53 { 127.0.0.1; };\n\n")
        }
      end

      context 'with address => "192.0.2.42"' do
        let(:params) do
          { address: '192.0.2.42' }
        end

        it {
          is_expected.to contain_bind__aml('listen-on')
            .with_target('named.conf.options')
            .with_order('11')
            .with_address_match_list('192.0.2.42')
        }
      end

      context 'with address => ["192.0.2.42"]' do
        let(:params) do
          { address: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_bind__aml('listen-on')
            .with_target('named.conf.options')
            .with_order('11')
            .with_address_match_list(['192.0.2.42'])
        }
      end

      context 'with address => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { address: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_bind__aml('listen-on')
            .with_target('named.conf.options')
            .with_order('11')
            .with_address_match_list(['192.0.2.42', '192.0.2.69'])
        }
      end
    end
  end
end
