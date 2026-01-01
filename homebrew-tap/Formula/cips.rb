# Homebrew formula for CIPS - Claude Instance Preservation System
# https://github.com/CodeTonight-SA/cips

class Cips < Formula
  desc "Claude Instance Preservation System - AI session continuity and efficiency"
  homepage "https://github.com/CodeTonight-SA/cips"
  url "https://github.com/CodeTonight-SA/cips/releases/download/v4.1.0/cips-4.1.0.tar.gz"
  sha256 "0b9ee8a2a7f59fbce895fe9b34864ced245ae644d561df9b46cc425994bfae39"
  license "Apache-2.0"
  version "4.1.0"

  depends_on "python@3.11"
  depends_on "jq"

  def install
    bin.install "bin/cips"
    (share/"cips").install Dir["share/cips/*"]
  end

  def caveats
    <<~EOS
      CIPS v#{version} installed!

      Run 'cips' to begin. First run will:
        - Create ~/.claude/ directory
        - Copy CIPS infrastructure (46 skills, 28 agents, 55+ libraries)
        - Guide you through identity setup

      Team members: Set your team password in ~/.claude/.env
        echo 'CIPS_TEAM_PASSWORD="your-password"' >> ~/.claude/.env

      Quick commands after setup:
        cips              # Auto-resume or fresh session
        cips resume latest # Resume last session
        cips fresh        # Start fresh session
        cips list         # List available sessions

      Documentation: https://github.com/CodeTonight-SA/cips
    EOS
  end

  test do
    assert_match "CIPS v#{version}", shell_output("#{bin}/cips --version")
  end
end
