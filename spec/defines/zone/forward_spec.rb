# frozen_string_literal: true

require 'spec_helper'

describe 'bind::zone::forward' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type forward;\n\n  forwarders { };\n};\n")
            .with_order('40')
        }
      end

      context 'with forwarders => ["192.0.2.42"]' do
        let(:params) do
          { forwarders: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type forward;\n\n  forwarders {\n    192.0.2.42;\n  };\n};\n")
            .with_order('40')
        }
      end

      context 'with forward => "first"' do
        let(:params) do
          { forward: 'first' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type forward;\n\n  forward first;\n  forwarders { };\n};\n")
            .with_order('40')
        }
      end

      context 'with comment => "foo"' do
        let(:params) do
          { comment: 'foo' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\n// foo\nzone \"foo\" IN {\n  type forward;\n\n  forwarders { };\n};\n")
            .with_order('40')
        }
      end

      context 'with zone => "bar"' do
        let(:params) do
          { zone: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-bar')
            .with_target('named.conf.zones')
            .with_content("\nzone \"bar\" IN {\n  type forward;\n\n  forwarders { };\n};\n")
            .with_order('40')
        }
      end

      context 'with class => "HS"' do
        let(:params) do
          { class: 'HS' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" HS {\n  type forward;\n\n  forwarders { };\n};\n")
            .with_order('40')
        }
      end

      context 'with order => "99"' do
        let(:params) do
          { order: '99' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type forward;\n\n  forwarders { };\n};\n")
            .with_order('99')
        }
      end
    end
  end
end
