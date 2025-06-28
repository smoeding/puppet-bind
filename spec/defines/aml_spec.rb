# frozen_string_literal: true

require 'spec_helper'

describe 'bind::aml' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with address_match_list => ""' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: '' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => "any"' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: 'any' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { any; };\n\n")
        }
      end

      context 'with address_match_list => []' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: [] }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => [], omit_empty_list => true' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: [], omit_empty_list: true }
        end

        it {
          is_expected.not_to contain_concat__fragment('bind::bar::foo')
        }
      end

      context 'with address_match_list => [""]' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: [''] }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => ["any"]' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: ['any'] }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { any; };\n\n")
        }
      end

      context 'with address_match_list => ["any", "!none"]' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: ['any', '!none'] }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo {\n    any;\n    !none;\n  };\n\n")
        }
      end

      context 'with address_match_list => " "' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: ' ' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => " any "' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: ' any ' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { any; };\n\n")
        }
      end

      context 'with address_match_list => "", target => "baz"' do
        let(:params) do
          { target: 'baz', order: '10', address_match_list: '' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::baz::foo')
            .with_target('baz')
            .with_order('10')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => "", order => "20"' do
        let(:params) do
          { target: 'bar', order: '20', address_match_list: '' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('20')
            .with_content("  foo { };\n\n")
        }
      end

      context 'with address_match_list => "", indent => "xx"' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: '', indent: 'xx' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("xxfoo { };\n\n")
        }
      end

      context 'with address_match_list => "", comment => "comment"' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: '', comment: 'comment' }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  // comment\n  foo { };\n\n")
        }
      end

      context 'with address_match_list => "any", initial_empty_line => true' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: 'any', initial_empty_line: true }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("\n  foo { any; };\n\n")
        }
      end

      context 'with address_match_list => "any", final_empty_line => false' do
        let(:params) do
          { target: 'bar', order: '10', address_match_list: 'any', final_empty_line: false }
        end

        it {
          is_expected.to contain_concat__fragment('bind::bar::foo')
            .with_target('bar')
            .with_order('10')
            .with_content("  foo { any; };\n")
        }
      end
    end
  end
end
