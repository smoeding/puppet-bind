# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Percentage' do
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
      it { is_expected.to allow_value('0%') }
      it { is_expected.to allow_value('50%') }
      it { is_expected.to allow_value('100%') }
      it { is_expected.to allow_value('200%') }
    end

    context 'with invalid values' do
      it { is_expected.not_to allow_value('') }
      it { is_expected.not_to allow_value('1') }
      it { is_expected.not_to allow_value('foo') }
      it { is_expected.not_to allow_value(0) }
      it { is_expected.not_to allow_value([nil, nil]) }
      it { is_expected.not_to allow_value([nil]) }
      it { is_expected.not_to allow_value(nil) }
      it { is_expected.not_to allow_value(true) }
      it { is_expected.not_to allow_value({ 'foo' => 'bar' }) }
      it { is_expected.not_to allow_value({}) }
    end
  end
end
