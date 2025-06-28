# frozen_string_literal: true

require 'spec_helper'

describe 'bind::zone::hint' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with file => "/foo/bar"' do
        let(:params) do
          { file: '/foo/bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type hint;\n  file \"/foo/bar\";\n};\n")
            .with_order('10')
        }
      end

      context 'with file => "/foo/bar", comment => "foo"' do
        let(:params) do
          { file: '/foo/bar', comment: 'foo' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\n// foo\nzone \"foo\" IN {\n  type hint;\n  file \"/foo/bar\";\n};\n")
            .with_order('10')
        }
      end

      context 'with file => "/foo/bar", zone => "bar"' do
        let(:params) do
          { file: '/foo/bar', zone: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-bar')
            .with_target('named.conf.zones')
            .with_content("\nzone \"bar\" IN {\n  type hint;\n  file \"/foo/bar\";\n};\n")
            .with_order('10')
        }
      end

      context 'with file => "/foo/bar", class => "HS"' do
        let(:params) do
          { file: '/foo/bar', class: 'HS' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" HS {\n  type hint;\n  file \"/foo/bar\";\n};\n")
            .with_order('10')
        }
      end

      context 'with file => "/foo/bar", order => "99"' do
        let(:params) do
          { file: '/foo/bar', order: '99' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type hint;\n  file \"/foo/bar\";\n};\n")
            .with_order('99')
        }
      end
    end
  end
end
