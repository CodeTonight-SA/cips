# Homebrew formula for CIPS - Claude Instance Preservation System
# https://github.com/CodeTonight-SA/cips

class Cips < Formula
  desc "Claude Instance Preservation System - AI session continuity and efficiency"
  homepage "https://github.com/CodeTonight-SA/cips"
  url "https://github.com/CodeTonight-SA/cips/releases/download/v4.2.0/cips-4.2.0.tar.gz"
  sha256 "3b12616e2382519e5bf8f59167000d2dd0fa6913d5e06dad2425f84e2866436e"
  license "Apache-2.0"
  version "4.2.0"

  depends_on "node"
  depends_on "python@3.11"
  depends_on "jq"

  def install
    bin.install "bin/cips"
    (share/"cips").install Dir["share/cips/*"]
  end

  def caveats
    <<~EOS
      CIPS v#{version} installed!

      Requires Claude Code. CIPS will offer to install it on first run, or:
        npm install -g @anthropic-ai/claude-code

      Run 'cips' to begin. First run will:
        - Install Claude Code (if needed)
        - Create ~/.claude/ directory
        - Copy CIPS infrastructure (53 skills, 29 agents)
        - Guide you through identity setup

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
