# coding: utf-8

require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Bind::Duration' do
    describe 'valid handling' do
      [
        'P1Y2M3DT4H5M6S',
        'P1Y2M3DT4H5M',
        'P1Y2M3DT4H',
        'P1Y2M3DT',
        'P1Y2M',
        'P1Y',
        'P2M3DT4H5M6S',
        'P1Y3DT4H5M6S',
        'P1Y2MT4H5M6S',
        'P1Y2M3DT5M6S',
        'P1Y2M3DT4H6S',
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
