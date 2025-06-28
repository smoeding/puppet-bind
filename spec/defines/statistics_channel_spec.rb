# frozen_string_literal: true

require 'spec_helper'

describe 'bind::statistics_channel' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { '127.0.0.1' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.statistics-127.0.0.1')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\nstatistics-channels {\n  inet 127.0.0.1;\n};\n\n")
        }
      end

      context 'with ip => 10.11.12.13' do
        let(:params) do
          { ip: '10.11.12.13' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.statistics-127.0.0.1')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\nstatistics-channels {\n  inet 10.11.12.13;\n};\n\n")
        }
      end

      context 'with port => 5353' do
        let(:params) do
          { port: 5353 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.statistics-127.0.0.1')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\nstatistics-channels {\n  inet 127.0.0.1 port 5353;\n};\n\n")
        }
      end

      context 'with allow => ["x"]' do
        let(:params) do
          { allow: ['x'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.statistics-127.0.0.1')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\nstatistics-channels {\n  inet 127.0.0.1 allow { x; };\n};\n\n")
        }
      end

      context 'with allow => ["x","y"]' do
        let(:params) do
          { allow: %w[x y] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.statistics-127.0.0.1')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\nstatistics-channels {\n  inet 127.0.0.1 allow { x; y; };\n};\n\n")
        }
      end
    end
  end
end
