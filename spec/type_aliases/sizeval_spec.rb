# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Sizeval' do
  debian = {
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => '13',
      },
    ],
  }

  on_supported_os(debian).each do |_os, facts|
    let(:facts) { facts }

    context 'with valid values' do
      it { is_expected.to allow_value(0) }
      it { is_expected.to allow_value(1) }
      it { is_expected.to allow_value(123_456_789) }
      it { is_expected.to allow_value('0') }
      it { is_expected.to allow_value('1k') }
      it { is_expected.to allow_value('2M') }
      it { is_expected.to allow_value('4G') }
    end

    context 'with invalid values' do
      it { is_expected.not_to allow_value('') }
      it { is_expected.not_to allow_value('foo') }
      it { is_expected.not_to allow_value([nil, nil]) }
      it { is_expected.not_to allow_value([nil]) }
      it { is_expected.not_to allow_value(nil) }
      it { is_expected.not_to allow_value(true) }
      it { is_expected.not_to allow_value({ 'foo' => 'bar' }) }
      it { is_expected.not_to allow_value({}) }
    end
  end
end
