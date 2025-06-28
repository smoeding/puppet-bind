# frozen_string_literal: true

require 'spec_helper'
require 'facter/named_version'

describe 'named_version', type: :fact do
  before { Facter.clear }
  after { Facter.clear }

  context 'when named version is 9.11.5' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('named -V', { on_fail: nil, timeout: 3 })
        .and_return('BIND 9.11.5-P4-5.1+deb10u2-Debian (Extended Support Version) <id:998753c>')
    end

    it {
      expect(Facter.fact(:named_version).value).to eq('9.11.5')
    }
  end

  context 'when named version is 9.16.1' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('named -V', { on_fail: nil, timeout: 3 })
        .and_return('BIND 9.16.1-Ubuntu (Stable Release) <id:d497c32>')
    end

    it {
      expect(Facter.fact(:named_version).value).to eq('9.16.1')
    }
  end
end
