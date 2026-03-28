# typed: false
# frozen_string_literal: true

class Dosdoor < Formula
  desc "Lightweight DOS emulator for running BBS door games"
  homepage "https://github.com/fewtarius/dosdoor"
  url "https://github.com/fewtarius/dosdoor/archive/refs/tags/20260328.2.tar.gz"
  sha256 "0d7931fbc0194057de84ccc316471d4e6fff68e3820485cf40b988996af00dd8"
  license "GPL-2.0-or-later"

  depends_on "s-lang"

  def install
    # build with HOMEBREW_PREFIX so compiled-in paths resolve at runtime
    ENV["PREFIX"] = HOMEBREW_PREFIX.to_s
    system "chmod", "+x", "build.sh", "mkpluginhooks", "bisonpp.pl", "install-sh"
    system "./build.sh"

    # install into the Cellar prefix - Homebrew symlinks into HOMEBREW_PREFIX
    bin.install "build/bin/dosdoor"

    # Z: drive - system drive with command.com, built commands, and FreeDOS utilities
    (share/"dosdoor/drive_z").install "freedos/command.com"
    # Install real .com files (not symlinks) from built commands
    Dir["build/commands/*.com"].reject { |f| File.symlink?(f) }.each do |f|
      (share/"dosdoor/drive_z/dosemu").install f
    end
    # Create symlinks for command aliases (dpmi.com, cmdline.com -> generic.com)
    Dir["build/commands/*.com"].select { |f| File.symlink?(f) }.each do |f|
      ln_sf "generic.com", share/"dosdoor/drive_z/dosemu"/File.basename(f)
    end
    # FreeDOS utilities (fossil.com, emufs.sys, ems.sys, etc.)
    (share/"dosdoor/drive_z/dosemu").install Dir["freedos/dosemu/*"]
    # FreeDOS boot image (for hdimage boot path)
    (share/"dosdoor/freedos").install Dir["freedos/*.sys", "freedos/*.com", "freedos/*.bat"]
    (share/"dosdoor/freedos/dosemu").install Dir["freedos/dosemu/*"]
    (share/"dosdoor/freedos/tmp").mkpath
    (share/"dosdoor/drives/c/tmp").mkpath
    (share/"dosdoor/keymap").install Dir["etc/keymap/*"]

    # config files go to HOMEBREW_PREFIX/etc (persists across upgrades)
    (etc/"dosdoor").install "etc/dosemu.conf"
    (etc/"dosdoor").install "etc/global.conf"
  end

  test do
    assert_match "dosemu-dosdoor", shell_output("#{bin}/dosdoor --version 2>&1", 0)
  end
end
