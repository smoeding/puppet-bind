require 'spec_helper'

describe 'bind::view' do
  let(:pre_condition) do
    'class { "bind":
       views_enable => true,
     }'
  end

  let(:title) { 'internal' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n")
            .with_order('10')

          is_expected.not_to contain_bind__zone__hint('internal/.')
          is_expected.not_to contain_bind__zone__mirror('internal/.')

          is_expected.to contain_bind__zone__primary('internal/localhost')
            .with_zone('localhost')
            .with_view('internal')
            .with_file('/etc/bind/db.localhost')
            .with_order('15')

          is_expected.to contain_bind__zone__primary('internal/127.in-addr.arpa')
            .with_zone('127.in-addr.arpa')
            .with_view('internal')
            .with_file('/etc/bind/db.127')
            .with_order('15')

          is_expected.to contain_concat__fragment('named.conf.views-internal-99')
            .with_target('named.conf.views')
            .with_content('};')
            .with_order('10')
        }
      end

      context 'with order => "20"' do
        let(:params) do
          { order: '20' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n")
            .with_order('20')

          is_expected.to contain_concat__fragment('named.conf.views-internal-99')
            .with_target('named.conf.views')
            .with_content('};')
            .with_order('20')
        }
      end

      context 'with match_clients => ["none"]' do
        let(:params) do
          { match_clients: ['none'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content(%r{match-clients {\n    none;\n  };\n})
            .with_order('10')
        }
      end

      context 'with match_destinations => ["none"]' do
        let(:params) do
          { match_destinations: ['none'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n  match_destinations {\n    none;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n")
            .with_order('10')
        }
      end

      context 'with match_recursive_only => true' do
        let(:params) do
          { match_recursive_only: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n  match-recursive-only yes;\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n")
            .with_order('10')
        }
      end

      context 'with allow_query => ["none"]' do
        let(:params) do
          { allow_query: ['none'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    none;\n  };\n\n  recursion yes;\n")
            .with_order('10')
        }
      end

      context 'with allow_query_on => ["eth0"]' do
        let(:params) do
          { allow_query_on: ['eth0'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  allow-query-on {\n    eth0;\n  };\n\n  recursion yes;\n")
            .with_order('10')
        }
      end

      context 'with recursion => false' do
        let(:params) do
          { recursion: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion no;\n")
            .with_order('10')
        }
      end

      context 'with allow_recursion => ["any"]' do
        let(:params) do
          { allow_recursion: ['any'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n\n  allow-recursion {\n    any;\n  };\n")
            .with_order('10')
        }
      end

      context 'with allow_recursion_on => ["eth0"]' do
        let(:params) do
          { allow_recursion_on: ['eth0'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n\n  allow-recursion-on {\n    eth0;\n  };\n")
            .with_order('10')
        }
      end

      context 'with allow_query_cache => ["any"]' do
        let(:params) do
          { allow_query_cache: ['any'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n\n  allow-query-cache {\n    any;\n  };\n")
            .with_order('10')
        }
      end

      context 'with allow_query_cache_on => ["eth0"]' do
        let(:params) do
          { allow_query_cache_on: ['eth0'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n\n  allow-query-cache-on {\n    eth0;\n  };\n")
            .with_order('10')
        }
      end

      context 'with allow_transfer => ["any"]' do
        let(:params) do
          { allow_transfer: ['any'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.views-internal-00')
            .with_target('named.conf.views')
            .with_content("\nview \"internal\" {\n  match-clients {\n    any;\n  };\n\n  allow-query {\n    any;\n  };\n\n  recursion yes;\n\n  allow-transfer {\n    any;\n  };\n")
            .with_order('10')
        }
      end

      context 'with root_hints_enable => true' do
        let(:params) do
          { root_hints_enable: true }
        end

        it {
          is_expected.to contain_bind__zone__hint('internal/.')
            .with_zone('.')
            .with_view('internal')
            .with_file('/etc/bind/db.root')
            .with_comment('Prime server with knowledge of the root servers')
        }
      end

      context 'with root_hints_enable => false' do
        let(:params) do
          { root_hints_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__hint('internal/.')
        }
      end

      context 'with localhost_forward_enable => true' do
        let(:params) do
          { localhost_forward_enable: true }
        end

        it {
          is_expected.to contain_bind__zone__primary('internal/localhost')
            .with_zone('localhost')
            .with_view('internal')
            .with_file('/etc/bind/db.localhost')
            .with_order('15')
        }
      end

      context 'with localhost_forward_enable => false' do
        let(:params) do
          { localhost_forward_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__primary('internal/localhost')
        }
      end

      context 'with localhost_reverse_enable => true' do
        let(:params) do
          { localhost_reverse_enable: true }
        end

        it {
          is_expected.to contain_bind__zone__primary('internal/127.in-addr.arpa')
            .with_zone('127.in-addr.arpa')
            .with_view('internal')
            .with_file('/etc/bind/db.127')
            .with_order('15')
        }
      end

      context 'with localhost_reverse_enable => false' do
        let(:params) do
          { localhost_reverse_enable: false }
        end

        it {
          is_expected.not_to contain_bind__zone__primary('internal/127.in-addr.arpa')
        }
      end
    end
  end
end
