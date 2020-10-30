require 'spec_helper'

describe 'bind::zone::mirror' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os} without bind" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.not_to contain_concat__fragment('named.conf.zones-foo')
        }
      end
    end

    context "on #{os} with bind 9.11.0" do
      let(:facts) { facts.merge(named_version: '9.11.0') }

      context 'with default parameters' do
        it {
          is_expected.not_to contain_concat__fragment('named.conf.zones-foo')
        }
      end
    end

    context "on #{os} with bind 9.14.0" do
      let(:facts) { facts.merge(named_version: '9.14.0') }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type mirror;\n};\n")
            .with_order('50')
        }
      end

      context 'with comment => "comment"' do
        let(:params) do
          { comment: 'comment' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\n// comment\nzone \"foo\" IN {\n  type mirror;\n};\n")
            .with_order('50')
        }
      end

      context 'with zone => "bar"' do
        let(:params) do
          { zone: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-bar')
            .with_target('named.conf.zones')
            .with_content("\nzone \"bar\" IN {\n  type mirror;\n};\n")
            .with_order('50')
        }
      end

      context 'with class => "HS"' do
        let(:params) do
          { class: 'HS' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" HS {\n  type mirror;\n};\n")
            .with_order('50')
        }
      end

      context 'with order => "99"' do
        let(:params) do
          { order: '99' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.zones-foo')
            .with_target('named.conf.zones')
            .with_content("\nzone \"foo\" IN {\n  type mirror;\n};\n")
            .with_order('99')
        }
      end
    end
  end
end
