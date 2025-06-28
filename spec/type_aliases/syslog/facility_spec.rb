# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Syslog::Facility' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'valid handling' do
        %w[auth authpriv cron daemon ftp kern
           local0 local1 local2 local3 local4 local5 local6 local7
           lpr mail news syslog user uucp].each do |value|
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
            'foo'
          ].each do |value|
            describe value.inspect do
              it { is_expected.not_to allow_value(value) }
            end
          end
        end
      end
    end
  end
end
