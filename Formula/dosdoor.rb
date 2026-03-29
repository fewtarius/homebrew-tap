# typed: false
# frozen_string_literal: true

class Dosdoor < Formula
  desc "Lightweight DOS emulator for running BBS door games"
  homepage "https://github.com/fewtarius/dosdoor"
  url "https://github.com/fewtarius/dosdoor/archive/refs/tags/20260328.4.tar.gz"
  sha256 "50a9c3835da236b07f99f9bf9f8e6b69867992e6cf45c50c2ccf66831d72cea7"
  license "GPL-2.0-or-later"

  depends_on "s-lang"

  def install
    # build with HOMEBREW_PREFIX so compiled-in paths resolve at runtime
    ENV["PREFIX"] = HOMEBREW_PREFIX.to_s
    system "chmod", "+x", "build.sh", "mkpluginhooks", "bisonpp.pl", "install-sh"
    system "./build.sh"

    # stage via the project install target so Homebrew packaging matches
    # the source install logic exactly
    stage = buildpath/"stage"
    staged_prefix = stage/HOMEBREW_PREFIX.relative_path_from(Pathname("/"))
    cellar_share = prefix/"share"/"dosdoor"
    system "make", "install", "DESTDIR=#{stage}"

    bin.install staged_prefix/"bin"/"dosdoor"
    cellar_share.mkpath
    system "cp", "-R", "#{staged_prefix}/share/dosdoor/.", cellar_share

    # Homebrew drops empty directories during staged copies. Seed the default
    # C: drive from the bundled FreeDOS boot tree so first launch works
    # without mutating the Cellar at runtime.
    system "mkdir", "-p", "#{prefix}/share/dosdoor/drives/c"
    system "cp", "-R", "#{prefix}/share/dosdoor/freedos/.", "#{prefix}/share/dosdoor/drives/c"
    system "mkdir", "-p", "#{prefix}/share/dosdoor/drives/c/tmp"
    system "touch", "#{prefix}/share/dosdoor/drives/c/tmp/.keep"
    system "mkdir", "-p", "#{prefix}/share/dosdoor/freedos/tmp"
    system "touch", "#{prefix}/share/dosdoor/freedos/tmp/.keep"

    # config files go to HOMEBREW_PREFIX/etc (persists across upgrades)
    (etc/"dosdoor").install Dir[staged_prefix/"etc"/"dosdoor"/"*"]
  end

  test do
    assert_match "dosemu-dosdoor", shell_output("#{bin}/dosdoor --version 2>&1", 0)
  end
end
