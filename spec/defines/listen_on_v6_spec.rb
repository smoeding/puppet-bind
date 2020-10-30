require 'spec_helper'

describe 'bind::listen_on_v6' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { '::1' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_bind__aml('listen-on-v6')
            .with_target('named.conf.options')
            .with_order('13')
            .with_address_match_list('::1')
        }
      end

      context 'with port => 53' do
        let(:params) do
          { port: 53 }
        end

        it {
          is_expected.to contain_bind__aml('listen-on-v6 port 53')
            .with_target('named.conf.options')
            .with_order('14')
            .with_address_match_list('::1')
        }
      end

      context 'with address => "2001:db8::dead:beef"' do
        let(:params) do
          { address: '2001:db8::dead:beef' }
        end

        it {
          is_expected.to contain_bind__aml('listen-on-v6')
            .with_target('named.conf.options')
            .with_order('13')
            .with_address_match_list('2001:db8::dead:beef')
        }
      end

      context 'with address => ["2001:db8::dead:beef"]' do
        let(:params) do
          { address: ['2001:db8::dead:beef'] }
        end

        it {
          is_expected.to contain_bind__aml('listen-on-v6')
            .with_target('named.conf.options')
            .with_order('13')
            .with_address_match_list(['2001:db8::dead:beef'])
        }
      end

      context 'with address => ["2001:db8::dead:beef", "2001:db8::babe:face"]' do
        let(:params) do
          { address: ['2001:db8::dead:beef', '2001:db8::babe:face'] }
        end

        it {
          is_expected.to contain_bind__aml('listen-on-v6')
            .with_target('named.conf.options')
            .with_order('13')
            .with_address_match_list(['2001:db8::dead:beef', '2001:db8::babe:face'])
        }
      end
    end
  end
end
