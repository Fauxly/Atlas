# Atlas

A native package manager for jailbroken Apple TV — built for **rootful palera1n**, in the spirit of Sileo/Zebra, but designed from the ground up for the TV remote instead of a touchscreen.

![platform](https://img.shields.io/badge/platform-tvOS-black) ![jailbreak](https://img.shields.io/badge/jailbreak-palera1n%20rootful-blue) ![license](https://img.shields.io/badge/license-TBD-lightgrey)

<!-- Замени плейсхолдер ниже на реальный скриншот/GIF -->
<p align="center">
  <img src="docs/screenshot-main.png" width="720" alt="Atlas dashboard" />
</p>

## Why

There's no proper on-TV package manager for palera1n on Apple TV — the recommended workflow is `apt` over SSH or PurePKG's tvOS build. Atlas aims to be a fully native, remote-friendly alternative: browse repos, search, install and remove tweaks, all from the couch.

## Features

- **Repository browsing** — home screen shows one horizontal row per repository, App Store–style
- **Categories & search** across every added source
- **Install / uninstall** tweaks directly on-device, with live `dpkg` output
- **Dependency checking** before install (parses `Depends`, warns about missing packages)
- **Update detection** — installed tweaks with a newer version available are flagged, with one-tap update
- **Add your own repositories** — supports both nested (Procursus-style `dists/...`) and flat repo layouts, auto-detected
- **Multi-repo quick-add** — add several sources in one sitting without re-opening the keyboard each time
- **Settings** — interface language (RU/EN), download cache management, repository list reset, in-app diagnostic log, device/app info

## Requirements

- Apple TV 4K (1st generation, A10X) or another palera1n-supported model
- **Rootful** palera1n jailbreak
- tvOS 15.0 or later

## Installation

**Option 1 — via PurePKG or another APT-compatible manager**

Add this repository:
```
https://Fauxly.github.io/
```
*(replace with wherever you're hosting the Atlas repo feed)*

**Option 2 — direct `.deb` install**

1. Download the latest `.deb` from [Releases](../../releases)
2. Copy it to the device and install with:
   ```bash
   dpkg -i com.fixstricks.atlas_*.deb
   ```

**Option 3 — palera1n loader**

Atlas can be added to a custom palera1n loader configuration alongside PurePKG — see [`loader.json`](loader.json) in this repo. Point the palera1n loader app at this file's raw URL to get Atlas as an install option during bootstrap.

## Technical notes

A few things that came up building this that might be useful to others working on tvOS jailbreak tooling:

- **Privilege escalation** — the rootful bootstrap's root filesystem is mounted `nosuid`, so classic `su`/`tsu` don't work. Atlas installs/removes packages via a private persona-based `posix_spawn` API (`posix_spawnattr_set_persona_np` + friends), the same mechanism used by [PurePKG](https://github.com/Lrdsnow/PurePKG).
- **Custom tab bar** — tvOS's system `UITabBarController` doesn't allow inserting arbitrary elements (like a persistent back button) into its bar, so the whole navigation shell is a hand-built `UIViewController` container instead.
- **Repository format detection** — `Packages` is fetched trying both the standard nested layout (`dists/{arch}/{distribution}/{component}/binary-{arch}/Packages`) and the flat layout (`Packages` at repo root), falling back automatically.
- **Text input** — a `UIAlertController` with `addTextField()` reliably hung on this setup when the on-screen keyboard tried to appear; a plain `UITextField` on a regular screen (matching the search tab) doesn't have this issue and works fine with Apple TV Remote's "type from nearby iPhone" feature.

## Credits

- [PurePKG](https://github.com/Lrdsnow/PurePKG) by Lrdsnow — reference implementation for the persona-spawn privilege escalation approach used here
- [palera1n](https://github.com/palera1n/palera1n) — the jailbreak this all runs on
- [Procursus](https://github.com/ProcursusTeam/Procursus) — bootstrap and default repository

## License

*(TBD — add a LICENSE file, e.g. MIT, and update this section)*

## Status

Actively in development. Issues and feedback welcome.
