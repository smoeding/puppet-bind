# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::DNSSEC::Validation' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'valid handling' do
        %w[yes no auto].each do |value|
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
