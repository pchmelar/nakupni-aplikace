# CLAUDE.md

Context for Claude Code sessions on **Nákupní karty**.

Built from **claude-project-template v6**
(<https://github.com/pchmelar/claude-project-template> — fetch its raw
`TEMPLATE.md` to check for a newer version) — read `TEMPLATE.md` first: it
defines the environment (devbox, `.env`, git-over-token), the protection model,
and the working conventions (English artifacts, human-on-the-loop autonomy).

## Project

Native iOS app (SwiftUI, iOS 17+) that bundles the store loyalty cards from
[nakupniaplikace.cz](https://nakupniaplikace.cz/) for offline use: store grid
with search, card detail, custom card photo per store (stored in
`Documents/`), and a fallback link to the store's page on the web. Working v1;
see `README.md` for features and layout.

## Project rules

- **Build:** `xcodebuild -project NakupniKarty/NakupniKarty.xcodeproj
  -scheme NakupniKarty -destination 'generic/platform=iOS Simulator' build`
  (put `-derivedDataPath` in the scratchpad or rely on the gitignored
  `DerivedData/`). No test target yet, so a green build is the bar.
- **Xcode project uses a synchronized folder**: files added under
  `NakupniKarty/NakupniKarty/` are picked up automatically, with no
  `project.pbxproj` edits needed.
- **Data refresh:** `cd scrape && python3 scrape.py` (stdlib + `curl`,
  system Python). It rewrites `Resources/img/` and `Resources/stores.json`.
  To add a store, append it to `STORES` in `scrape/scrape.py`.
- **Language:** UI strings are Czech (Czech-only audience). The existing
  README and code comments are Czech too. Write new artifacts in English per
  the template, and keep each file in a single language.
- **Devbox quirks on this machine (Intel Mac, x86_64-darwin):**
  - nixpkgs-unstable has dropped x86_64-darwin, so `devbox.json` pins
    `nixpkgs.commit` to the `nixpkgs-26.05-darwin` branch. Add packages as
    flake refs on that commit (`devbox add github:NixOS/nixpkgs/<commit>#pkg`),
    because plain `devbox add pkg@ver` resolves to unstable and fails.
  - The devbox env injects the nix stdenv (`SDKROOT`, `LD`, `NIX_LDFLAGS`, …),
    which breaks `xcodebuild` linking. `init_hook` unsets these, so keep that
    line. `DEVELOPER_DIR` points to full Xcode, not CommandLineTools, because
    `xcodebuild` needs it.
  - Avoid nix packages that pull a C toolchain (e.g. python): they re-leak
    compiler env into Xcode builds. Prefer system/Xcode tools.

## Decisions not yet made (don't assume)

- Whether to translate the existing Czech README/comments to English.
- Distribution (TestFlight / App Store), signing team, and whether to keep the
  bundle id `cz.nakupniaplikace.karty`.
- Licensing/permission for the bundled logos and card images from
  nakupniaplikace.cz.
