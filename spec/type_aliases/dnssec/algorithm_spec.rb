# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::DNSSEC::Algorithm' do
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
      it { is_expected.to allow_value('dsa') }
      it { is_expected.to allow_value('eccgost') }
      it { is_expected.to allow_value('ecdsap256sha256') }
      it { is_expected.to allow_value('ecdsap384sha384') }
      it { is_expected.to allow_value('ed25519') }
      it { is_expected.to allow_value('ed448') }
      it { is_expected.to allow_value('nsec3dsa') }
      it { is_expected.to allow_value('nsec3rsasha1') }
      it { is_expected.to allow_value('rsamd5') }
      it { is_expected.to allow_value('rsasha1') }
      it { is_expected.to allow_value('rsasha256') }
      it { is_expected.to allow_value('rsasha512') }
    end

    context 'with invalid values' do
      it { is_expected.not_to allow_value('') }
      it { is_expected.not_to allow_value('foo') }
      it { is_expected.not_to allow_value(42) }
      it { is_expected.not_to allow_value([nil, nil]) }
      it { is_expected.not_to allow_value([nil]) }
      it { is_expected.not_to allow_value(nil) }
      it { is_expected.not_to allow_value(true) }
      it { is_expected.not_to allow_value({ 'foo' => 'bar' }) }
      it { is_expected.not_to allow_value({}) }
    end
  end
end
