require 'spec_helper'

describe 'bind::zonefile_path' do
  context 'with zone => local' do
    it {
      is_expected.to run.with_params('local').and_return('local/db.local')
    }
  end

  context 'with zone => foo.local' do
    it {
      is_expected.to run.with_params('foo.local').and_return('local/foo/db.foo.local')
    }
  end

  context 'with zone => foo.local and view => internal' do
    it {
      is_expected.to run.with_params('foo.local', 'internal').and_return('local/foo/db.foo.local_internal')
    }
  end

  context 'with zone => foo.bar.local' do
    it {
      is_expected.to run.with_params('foo.bar.local').and_return('local/bar/db.foo.bar.local')
    }
  end

  context 'with zone => 10.in-addr.arpa' do
    it {
      is_expected.to run.with_params('10.in-addr.arpa').and_return('arpa/in-addr/db.10')
    }
  end

  context 'with zone => 11.10.in-addr.arpa' do
    it {
      is_expected.to run.with_params('11.10.in-addr.arpa').and_return('arpa/in-addr/db.10.11')
    }
  end

  context 'with zone => 12.11.10.in-addr.arpa' do
    it {
      is_expected.to run.with_params('12.11.10.in-addr.arpa').and_return('arpa/in-addr/db.10.11.12')
    }
  end

  context 'with zone => 12.11.10.in-addr.arpa and view => internal' do
    it {
      is_expected.to run.with_params('12.11.10.in-addr.arpa', 'internal').and_return('arpa/in-addr/db.10.11.12_internal')
    }
  end
end
