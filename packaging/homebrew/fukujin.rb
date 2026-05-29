cask "fukujin" do
  version "1.0"
  sha256 "f847e434649a620df0c60b11ef2fa8e4d2a9261dd74fbaa36c5a1733759d49a0"

  url "https://github.com/s-age/FukuJin/releases/download/v#{version}/FukuJin-#{version}.dmg"
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
