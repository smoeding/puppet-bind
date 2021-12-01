require 'spec_helper'

describe 'bind::dnssec_policy' do
  let(:pre_condition) do
    'class { "bind": }'
  end

  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content("\ndnssec-policy \"foo\" {\n};\n")
        }
      end

      context 'with nsec3_enable => true' do
        let(:params) do
          { nsec3_enable: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  nsec3param;})
        }
      end

      context 'with nsec3_enable => true, nsec3param_iterations => 1' do
        let(:params) do
          { nsec3_enable: true, nsec3param_iterations: 1 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  nsec3param iterations 1;})
        }
      end

      context 'with nsec3_enable => true, nsec3param_optout => true' do
        let(:params) do
          { nsec3_enable: true, nsec3param_optout: true }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  nsec3param optout yes;})
        }
      end

      context 'with nsec3_enable => true, nsec3param_optout => false' do
        let(:params) do
          { nsec3_enable: true, nsec3param_optout: false }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  nsec3param optout no;})
        }
      end

      context 'with nsec3_enable => true, nsec3param_salt_length => 7' do
        let(:params) do
          { nsec3_enable: true, nsec3param_salt_length: 7 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  nsec3param salt-length 7;})
        }
      end

      context 'with dnskey_ttl => P1Y' do
        let(:params) do
          { dnskey_ttl: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  dnskey-ttl P1Y;})
        }
      end

      context 'with purge_keys => P1Y' do
        let(:params) do
          { purge_keys: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  purge-keys P1Y;})
        }
      end

      context 'with publish_safety => P1Y' do
        let(:params) do
          { publish_safety: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  publish-safety P1Y;})
        }
      end

      context 'with retire_safety => P1Y' do
        let(:params) do
          { retire_safety: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  retire-safety P1Y;})
        }
      end

      context 'with signatures_refresh => P1Y' do
        let(:params) do
          { signatures_refresh: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  signatures-refresh P1Y;})
        }
      end

      context 'with signatures_validity => P1Y' do
        let(:params) do
          { signatures_validity: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  signatures-validity P1Y;})
        }
      end

      context 'with signatures_validity_dnskey => P1Y' do
        let(:params) do
          { signatures_validity_dnskey: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  signatures-validity-dnskey P1Y;})
        }
      end

      context 'with max_zone_ttl => P1Y' do
        let(:params) do
          { max_zone_ttl: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  max-zone-ttl P1Y;})
        }
      end

      context 'with zone_propagation_delay => P1Y' do
        let(:params) do
          { zone_propagation_delay: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  zone-propagation-delay P1Y;})
        }
      end

      context 'with parent_ds_ttl => P1Y' do
        let(:params) do
          { parent_ds_ttl: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  parent-ds-ttl P1Y;})
        }
      end

      context 'with parent_propagation_delay => P1Y' do
        let(:params) do
          { parent_propagation_delay: 'P1Y' }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^  parent-propagation-delay P1Y;})
        }
      end

      context 'with CSK key' do
        let(:params) do
          { csk_lifetime: 'P1Y', csk_algorithm: 'hmac-sha512', csk_keysize: 1 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^    csk lifetime P1Y algorithm hmac-sha512 1;})
        }
      end

      context 'with KSK key' do
        let(:params) do
          { ksk_lifetime: 'P1Y', ksk_algorithm: 'hmac-sha512', ksk_keysize: 1 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^    ksk lifetime P1Y algorithm hmac-sha512 1;})
        }
      end

      context 'with ZSK key' do
        let(:params) do
          { zsk_lifetime: 'P1Y', zsk_algorithm: 'hmac-sha512', zsk_keysize: 1 }
        end

        it {
          is_expected.to contain_concat__fragment('named.conf.policies-foo')
            .with_target('named.conf.policies')
            .with_content(%r{^    zsk lifetime P1Y algorithm hmac-sha512 1;})
        }
      end
    end
  end
end
