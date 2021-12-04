# coding: utf-8

require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Bind::DNSSEC::Algorithm' do
    describe 'valid handling' do
      [
        'dsa',
        'eccgost',
        'ecdsap256sha256',
        'ecdsap384sha384',
        'ed25519',
        'ed448',
        'nsec3dsa',
        'nsec3rsasha1',
        'rsamd5',
        'rsasha1',
        'rsasha256',
        'rsasha512',
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
          42,
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
