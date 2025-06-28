# frozen_string_literal: true

Facter.add(:named_version) do
  setcode do
    opt = { on_fail: nil, timeout: 3 }
    cmd = 'named -V'

    begin
      version = Facter::Core::Execution.execute(cmd, opt)
      Regexp.last_match(1) if version =~ %r{^BIND ([0-9.]+).*$}
    rescue Facter::Core::Execution::ExecutionFailure
      nil
    end
  end
end
