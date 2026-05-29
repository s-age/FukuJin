cask "fukujin" do
  version "1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/s-age/FukuJin/releases/download/v#{version}/FukuJin-#{version}.dmg",
      verified: "github.com/s-age/FukuJin/"
  name "FukuJin"
  desc "Menu bar app that pins other apps' windows as live floating overlays"
  homepage "https://github.com/s-age/FukuJin"

  depends_on macos: ">= :sequoia"

  app "FukuJin.app"

  zap trash: [
    "~/Library/Application Support/com.fukujin.app",
    "~/Library/Preferences/com.fukujin.app.plist",
    "~/.fuku-jin",
  ]
end
