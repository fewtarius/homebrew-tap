# typed: false
# frozen_string_literal: true

class Dosdoor < Formula
  desc "Lightweight DOS emulator for running BBS door games"
  homepage "https://github.com/fewtarius/dosdoor"
  url "https://github.com/fewtarius/dosdoor/archive/refs/tags/20260318.1.tar.gz"
  sha256 "7bebb693d986503e748ed5c57625974b11aab611e72f2be0ee9156c64c5b8961"
  license "GPL-2.0-or-later"

  depends_on "s-lang"

  def install
    # build with HOMEBREW_PREFIX so compiled-in paths resolve at runtime
    ENV["PREFIX"] = HOMEBREW_PREFIX.to_s
    system "chmod", "+x", "build.sh", "mkpluginhooks", "bisonpp.pl", "install-sh"
    system "./build.sh"

    # install into the Cellar prefix - Homebrew symlinks into HOMEBREW_PREFIX
    bin.install "build/bin/dosdoor"

    # data files
    (share/"dosdoor/drive_z/dosemu").install Dir["build/commands/*.com"]
    (share/"dosdoor/freedos").install Dir["freedos/*.sys", "freedos/*.com", "freedos/*.bat"]
    (share/"dosdoor/freedos/dosemu").install Dir["freedos/dosemu/*"]
    (share/"dosdoor/freedos/bin").mkpath
    (share/"dosdoor/freedos/tmp").mkpath
    (share/"dosdoor/keymap").install Dir["etc/keymap/*"]

    # config files go to HOMEBREW_PREFIX/etc (persists across upgrades)
    (etc/"dosdoor").install "etc/dosemu.conf"
    (etc/"dosdoor").install "etc/global.conf"
  end

  test do
    assert_match "dosemu-dosdoor", shell_output("#{bin}/dosdoor --version 2>&1", 0)
  end
end
