# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Auto_dnssec' do
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
      it { is_expected.to allow_value('allow') }
      it { is_expected.to allow_value('maintain') }
      it { is_expected.to allow_value('off') }
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
