require 'spec_helper'

describe 'bind::config' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_owner('root')
            .with_group('bind')
            .with_mode('0640')
            .without_source
            .without_content
            .that_notifies('Service[bind]')
        }
      end

      context 'with ensure => absent' do
        let(:params) do
          { ensure: 'absent' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('absent')
            .that_notifies('Service[bind]')
        }
      end

      context 'with file => "bar"' do
        let(:params) do
          { file: 'bar' }
        end

        it {
          is_expected.to contain_file('/etc/bind/bar')
            .that_notifies('Service[bind]')
        }
      end

      context 'with owner => "foo"' do
        let(:params) do
          { owner: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_owner('foo')
            .that_notifies('Service[bind]')
        }
      end

      context 'with group => "foo"' do
        let(:params) do
          { group: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_group('foo')
            .that_notifies('Service[bind]')
        }
      end

      context 'with mode => "0642"' do
        let(:params) do
          { mode: '0642' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_mode('0642')
            .that_notifies('Service[bind]')
        }
      end

      context 'with source => "puppet://foo/bar"' do
        let(:params) do
          { source: 'puppet://foo/bar' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_source('puppet://foo/bar')
            .that_notifies('Service[bind]')
        }
      end

      context 'with content => "foo"' do
        let(:params) do
          { content: 'foo' }
        end

        it {
          is_expected.to contain_file('/etc/bind/foo')
            .with_ensure('file')
            .with_content('foo')
            .that_notifies('Service[bind]')
        }
      end
    end
  end
end
