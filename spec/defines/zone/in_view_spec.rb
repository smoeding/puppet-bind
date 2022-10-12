require 'spec_helper'

describe 'bind::zone::in_view' do
  let(:pre_condition) do
    'class { "bind":
       views_enable => true,
     }
     Concat::Fragment <| |>'
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

      context 'with view => "bar", in_view => "baz"' do
        let(:params) do
          { view: 'bar', in_view: 'baz' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-bar-50-foo')
            .with_target('named.conf.views')
            .with_content("\n  zone \"foo\" IN {\n    in-view \"baz\";\n  };\n")
            .with_tag(['named.conf.views-bar'])
            .with_order('60')
        }
      end

      context 'with view => "bar", in_view => "baz", class => "CH"' do
        let(:params) do
          { view: 'bar', in_view: 'baz', class: 'CH' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-bar-50-foo')
            .with_target('named.conf.views')
            .with_content("\n  zone \"foo\" CH {\n    in-view \"baz\";\n  };\n")
            .with_tag(['named.conf.views-bar'])
            .with_order('60')
        }
      end

      context 'with view => "bar", in_view => "baz", comment => "comment"' do
        let(:params) do
          { view: 'bar', in_view: 'baz', comment: 'comment' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-bar-50-foo')
            .with_target('named.conf.views')
            .with_content("\n  // comment\n  zone \"foo\" IN {\n    in-view \"baz\";\n  };\n")
            .with_tag(['named.conf.views-bar'])
            .with_order('60')
        }
      end
    end
  end
end
