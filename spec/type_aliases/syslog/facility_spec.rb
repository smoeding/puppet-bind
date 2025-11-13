# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Syslog::Facility' do
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
      it { is_expected.to allow_value('auth') }
      it { is_expected.to allow_value('authpriv') }
      it { is_expected.to allow_value('cron') }
      it { is_expected.to allow_value('daemon') }
      it { is_expected.to allow_value('ftp') }
      it { is_expected.to allow_value('kern') }
      it { is_expected.to allow_value('local0') }
      it { is_expected.to allow_value('local1') }
      it { is_expected.to allow_value('local2') }
      it { is_expected.to allow_value('local3') }
      it { is_expected.to allow_value('local4') }
      it { is_expected.to allow_value('local5') }
      it { is_expected.to allow_value('local6') }
      it { is_expected.to allow_value('local7') }
      it { is_expected.to allow_value('lpr') }
      it { is_expected.to allow_value('mail') }
      it { is_expected.to allow_value('news') }
      it { is_expected.to allow_value('syslog') }
      it { is_expected.to allow_value('user') }
      it { is_expected.to allow_value('uucp') }
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
