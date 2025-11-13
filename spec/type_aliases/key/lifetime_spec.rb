# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Key::Lifetime' do
  # we only need to test this on one os
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
      it { is_expected.to allow_value('P1Y') }
      it { is_expected.to allow_value('P1Y2M') }
      it { is_expected.to allow_value('P1Y2M3DT') }
      it { is_expected.to allow_value('P1Y2M3DT4H') }
      it { is_expected.to allow_value('P1Y2M3DT4H5M') }
      it { is_expected.to allow_value('P1Y2M3DT4H5M6S') }
      it { is_expected.to allow_value('P1Y2M3DT4H6S') }
      it { is_expected.to allow_value('P1Y2M3DT5M6S') }
      it { is_expected.to allow_value('P1Y2MT4H5M6S') }
      it { is_expected.to allow_value('P1Y3DT4H5M6S') }
      it { is_expected.to allow_value('P2M3DT4H5M6S') }
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
