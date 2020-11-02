require 'spec_helper'

describe 'bind::controls::unix' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { '/run/named.ctl' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to compile.and_raise_error(%r{expects a value for parameter})
        }
      end

      context 'with owner => 0, group => 0, perm => "0640"' do
        let(:params) do
          { owner: 0, group: 0, perm: '0640' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 0 perm 0640;')

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

      context 'with owner => 42, group => 0, perm => "0640"' do
        let(:params) do
          { owner: 42, group: 0, perm: '0640' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 42 group 0 perm 0640;')

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

      context 'with owner => 0, group => 42, perm => "0640"' do
        let(:params) do
          { owner: 0, group: 42, perm: '0640' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 42 perm 0640;')

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

      context 'with owner => 0, group => 0, perm => "0666"' do
        let(:params) do
          { owner: 0, group: 0, perm: '0666' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 0 perm 0666;')

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

      context 'with owner => 0, group => 0, perm => "0640", keys => ["key1"]' do
        let(:params) do
          { owner: 0, group: 0, perm: '0640', keys: ['key1'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 0 perm 0640 keys { "key1"; };')

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

      context 'with owner => 0, group => 0, perm => "0640", keys => ["key1", "key2"]' do
        let(:params) do
          { owner: 0, group: 0, perm: '0640', keys: ['key1', 'key2'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 0 perm 0640 keys { "key1"; "key2"; };')

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

      context 'with owner => 0, group => 0, perm => "0640", read_only => true' do
        let(:params) do
          { owner: 0, group: 0, perm: '0640', read_only: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.controls-unix-/run/named.ctl')
            .with_target('named.conf.options')
            .with_order('91')
            .with_content('  unix "/run/named.ctl" owner 0 group 0 perm 0640 read-only yes;')

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
