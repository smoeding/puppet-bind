# frozen_string_literal: true

require 'spec_helper'

describe 'bind::controls::inet' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { '*' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet *;')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with port => 1234' do
        let(:params) do
          { port: 1234 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * port 1234;')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with allow => ["192.0.2.42"]' do
        let(:params) do
          { allow: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * allow { 192.0.2.42; };')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with allow => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { allow: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * allow { 192.0.2.42; 192.0.2.69; };')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with keys => ["key1"]' do
        let(:params) do
          { keys: ['key1'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * keys { "key1"; };')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with keys => ["key1", "key2"]' do
        let(:params) do
          { keys: %w[key1 key2] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * keys { "key1"; "key2"; };')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end

      context 'with read_only => true' do
        let(:params) do
          { read_only: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-inet-*')
            .with_target('named.conf.options')
            .with_order('92')
            .with_content('  inet * read-only yes;')

          is_expected.to contain_concat__fragment('named.conf.controls-head')
            .with_target('named.conf.options')
            .with_order('90')
            .with_content("\ncontrols {\n")

          is_expected.to contain_concat__fragment('named.conf.controls-tail')
            .with_target('named.conf.options')
            .with_order('93')
            .with_content("};\n")
        }
      end
    end
  end
end
