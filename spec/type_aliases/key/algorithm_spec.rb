# frozen_string_literal: true

require 'spec_helper'

describe 'Bind::Key::Algorithm' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'valid handling' do
        %w[hmac-md5
           hmac-sha1
           hmac-sha224
           hmac-sha256
           hmac-sha384
           hmac-sha512].each do |value|
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
