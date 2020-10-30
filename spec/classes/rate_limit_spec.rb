require 'spec_helper'

describe 'bind::rate_limit' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.not_to contain_concat__fragment('named.conf.rate-limit')
        }
      end

      context 'with all_per_second => 1000' do
        let(:params) do
          { all_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with errors_per_second => 1000' do
        let(:params) do
          { errors_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    errors-per-second    1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with responses_per_second => 1000' do
        let(:params) do
          { responses_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    responses-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with referrals_per_second => 1000' do
        let(:params) do
          { referrals_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    referrals-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with nodata_per_second => 1000' do
        let(:params) do
          { nodata_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    nodata-per-second    1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with nxdomains_per_second => 1000' do
        let(:params) do
          { nxdomains_per_second: 1000 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    nxdomains-per-second 1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with qps_scale => 10' do
        let(:params) do
          { qps_scale: 10 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    qps_scale 10;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with slip => 10' do
        let(:params) do
          { slip: 10 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    slip      10;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, window => 3600' do
        let(:params) do
          { all_per_second: 1000, window: 3600 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    window    3600;\n    all-per-second       1000;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, ipv4_prefix_length => 16' do
        let(:params) do
          { all_per_second: 1000, ipv4_prefix_length: 16 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    // default: 24\n    ipv4-prefix-length 16;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, ipv6_prefix_length => 16' do
        let(:params) do
          { all_per_second: 1000, ipv6_prefix_length: 16 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    // default: 56\n    ipv6-prefix-length 16;\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, log_only => true' do
        let(:params) do
          { all_per_second: 1000, log_only: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, exempt_clients => ["192.0.2.42"]' do
        let(:params) do
          { all_per_second: 1000, exempt_clients: ['192.0.2.42'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    exempt-clients { 192.0.2.42; };\n\n    //log-only yes;\n  };\n")
        }
      end

      context 'with all_per_second => 1000, exempt_clients => ["192.0.2.42", "192.0.2.69"]' do
        let(:params) do
          { all_per_second: 1000, exempt_clients: ['192.0.2.42', '192.0.2.69'] }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.rate-limit')
            .with_target('named.conf.options')
            .with_order('80')
            .with_content("\n  rate-limit {\n    all-per-second       1000;\n\n    exempt-clients {\n      192.0.2.42;\n      192.0.2.69;\n    };\n\n    //log-only yes;\n  };\n")
        }
      end
    end
  end
end
