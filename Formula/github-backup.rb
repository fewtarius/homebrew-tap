# typed: false
# frozen_string_literal: true

# version: 1.0.4
class GithubBackup < Formula
  desc "Comprehensive GitHub backup tool for repos, gists, orgs, and metadata"
  homepage "https://github.com/fewtarius/github-backup"
  url "https://github.com/fewtarius/github-backup/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "d2c67dccf7593436ea05445b29493ad7754c75835c22c68df8dd72b3146e7f4f"
  license "MIT"

  depends_on "python@3.13" => :build
  uses_from_macos "git"

  def install
    # Create virtual environment
    ENV.prepend_path "PYTHONPATH", "#{libexec}/lib/python3.13/site-packages"

    system "python3", "-m", "venv", libexec.to_s
    system "#{libexec}/bin/pip", "install", "-r", "requirements.txt"

    # Install main script
    bin.install "github-backup"

    # Create wrapper that invokes the python module
    (bin/"github-backup").write <<~WRAPPER
      #!/bin/bash
      SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
      exec "#{libexec}/bin/python3" -m github_backup "$@"
    WRAPPER
    chmod 0755, bin/"github-backup"
  end

  test do
    # Verify the command is available and runs
    assert_match "github-backup", shell_output("#{bin}/github-backup --help 2>&1", 0)
  end
end