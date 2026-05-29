# Homebrew Cask distribution

FukuJin is distributed through a **personal tap** (`s-age/homebrew-fukujin`) as
a notarized DMG. End users install with:

```bash
brew tap s-age/fukujin      # shorthand for the s-age/homebrew-fukujin repo
brew install --cask fukujin
```

## One-time setup

### 1. Notarization credentials

Create a keychain profile so `Scripts/release.sh` can notarize without
prompting (requires an Apple Developer Program membership):

```bash
xcrun notarytool store-credentials "fukujin-notary" \
  --apple-id "<your-apple-id>" \
  --team-id  "7VF2T8G76X" \
  --password "<app-specific-password>"
```

Generate the app-specific password at <https://account.apple.com> →
**Sign-In and Security → App-Specific Passwords**.

### 2. The tap repository

The tap lives at **`s-age/homebrew-fukujin`** (the `homebrew-` prefix is what
makes `brew tap s-age/fukujin` resolve). Place the cask at `Casks/fukujin.rb`.

## Cutting a release

```bash
# 1. Bump the version in Resources/Info.plist
#    (CFBundleShortVersionString and CFBundleVersion).

# 2. Build the signed + notarized + stapled DMG.
./Scripts/release.sh
#    → prints the artifact path, version, and sha256.

# 3. Create a GitHub release tagged v<version> on s-age/FukuJin and upload
#    the FukuJin-<version>.dmg artifact.
gh release create "v<version>" "FukuJin-<version>.dmg" \
  --repo s-age/FukuJin --title "v<version>" --generate-notes

# 4. Update packaging/homebrew/fukujin.rb with the new version + sha256,
#    then copy it into the tap repo and push:
cp packaging/homebrew/fukujin.rb /path/to/homebrew-fukujin/Casks/fukujin.rb
#    (commit & push in the tap repo)

# 5. Verify end to end:
brew update
brew upgrade --cask fukujin   # or: brew install --cask fukujin
```

## Notes

- The DMG is signed with **Developer ID Application** and notarized, so
  Gatekeeper opens it cleanly — no `--no-quarantine` workaround is needed.
- Releases are hosted on `s-age/FukuJin`; the cask is published from a separate
  `s-age/homebrew-fukujin` repo. Adjust the URLs in `fukujin.rb` and this file if
  you publish under different repository names.
- Promotion to the official `Homebrew/homebrew-cask` tap later requires the
  repo to meet notability criteria (e.g. 30+ days old or 75+ stars). The cask
  here is already compatible with the official format.
