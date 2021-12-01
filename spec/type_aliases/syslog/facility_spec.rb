# coding: utf-8

require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Bind::Syslog::Facility' do
    describe 'valid handling' do
      [
        'auth',
        'authpriv',
        'cron',
        'daemon',
        'ftp',
        'kern',
        'local0',
        'local1',
        'local2',
        'local3',
        'local4',
        'local5',
        'local6',
        'local7',
        'lpr',
        'mail',
        'news',
        'syslog',
        'user',
        'uucp',
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end

    describe 'invalid handling' do
      context 'with garbage inputs' do
        [
          nil,
          [nil],
          [nil, nil],
          { 'foo' => 'bar' },
          {},
          true,
          '',
          'foo',
        ].each do |value|
          describe value.inspect do
            it { is_expected.not_to allow_value(value) }
          end
        end
      end
    end
  end
end
