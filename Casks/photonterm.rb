cask "photonterm" do
  version "20260401.1"
  sha256 :no_check

  url "https://github.com/fewtarius/PhotonTERM/releases/download/#{version}/PhotonTERM-#{version}.dmg"
  name "PhotonTERM"
  desc "BBS terminal client - ANSI/VT100, SSH, Telnet, file transfer"
  homepage "https://github.com/fewtarius/PhotonTERM"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "PhotonTERM.app"

  zap trash: [
    "~/Library/Application Support/PhotonTERM",
    "~/Library/Preferences/org.fewtarius.PhotonTERM.plist",
    "~/Library/Caches/org.fewtarius.PhotonTERM",
  ]
end
