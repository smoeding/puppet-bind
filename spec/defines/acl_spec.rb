# frozen_string_literal: true

require 'spec_helper'

describe 'bind::acl' do
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

      context 'with address_match_list => ["192.0.2.42"]' do
        let(:params) do
          { address_match_list: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.acl.foo')
            .with_target('named.conf.acls')
            .with_order('10')
            .with_content("\nacl \"foo\" {\n  192.0.2.42;\n};\n")
        }
      end

      context 'with address_match_list => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { address_match_list: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.acl.foo')
            .with_target('named.conf.acls')
            .with_order('10')
            .with_content("\nacl \"foo\" {\n  192.0.2.42;\n  192.0.2.69;\n};\n")
        }
      end

      context 'with address_match_list => ["192.0.2.42"], order => "20"' do
        let(:params) do
          { address_match_list: ['192.0.2.42'], order: '20' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.acl.foo')
            .with_target('named.conf.acls')
            .with_order('20')
            .with_content("\nacl \"foo\" {\n  192.0.2.42;\n};\n")
        }
      end

      context 'with address_match_list => ["192.0.2.42"], comment => "bar"' do
        let(:params) do
          { address_match_list: ['192.0.2.42'], comment: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.acl.foo')
            .with_target('named.conf.acls')
            .with_order('10')
            .with_content("\nacl \"foo\" {\n  // bar\n  192.0.2.42;\n};\n")
        }
      end
    end
  end
end
