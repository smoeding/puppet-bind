# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::AddressMatchList' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'valid handling' do
        ['', 'foo', [''], ['foo']].each do |value|
          describe value.inspect do
            it { is_expected.to allow_value(value) }
          end
        end
      end

      describe 'invalid handling' do
        context 'with garbage inputs' do
          [
            { 'foo' => 'bar' },
            {},
            true,
            42
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
