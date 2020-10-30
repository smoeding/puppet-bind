require 'spec_helper'

describe 'bind::logging::category' do
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

      context 'with channels => "chan1"' do
        let(:params) do
          { channels: 'chan1' }
        end

        it {
          is_expected.to contain_concat__fragment('bind-logging-category-foo')
            .with_target('named.conf.logging')
            .with_order('60-50-foo')
            .with_content('  category foo { chan1; };')
        }
      end

      context 'with channels => ["chan1"]' do
        let(:params) do
          { channels: ['chan1'] }
        end

        it {
          is_expected.to contain_concat__fragment('bind-logging-category-foo')
            .with_target('named.conf.logging')
            .with_order('60-50-foo')
            .with_content('  category foo { chan1; };')
        }
      end

      context 'with channels => ["chan1", "chan2"]' do
        let(:params) do
          { channels: ['chan1', 'chan2'] }
        end

        it {
          is_expected.to contain_concat__fragment('bind-logging-category-foo')
            .with_target('named.conf.logging')
            .with_order('60-50-foo')
            .with_content('  category foo { chan1; chan2; };')
        }
      end

      context 'with channels => ["chan1"], order => "99"' do
        let(:params) do
          { channels: ['chan1'], order: '99' }
        end

        it {
          is_expected.to contain_concat__fragment('bind-logging-category-foo')
            .with_target('named.conf.logging')
            .with_order('60-99-foo')
            .with_content('  category foo { chan1; };')
        }
      end

      context 'with channels => ["chan1"], category => "bar"' do
        let(:params) do
          { channels: ['chan1'], category: 'bar' }
        end

        it {
          is_expected.to contain_concat__fragment('bind-logging-category-bar')
            .with_target('named.conf.logging')
            .with_order('60-50-bar')
            .with_content('  category bar { chan1; };')
        }
      end
    end
  end
end
