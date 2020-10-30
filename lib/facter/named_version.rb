# named_version.rb -- Get the Bind/named version

Facter.add(:named_version) do
  setcode do
    opt = { on_fail: nil, timeout: 3 }
    cmd = 'named -V'

    begin
      version = Facter::Core::Execution.execute(cmd, opt)
      if version =~ %r{^BIND ([0-9.]+).*$}
        Regexp.last_match(1)
      else
        nil
      end
    rescue Facter::Core::Execution::ExecutionFailure
      nil
    end
  end
end
