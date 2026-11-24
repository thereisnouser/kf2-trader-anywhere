# KF2 Trader Anywhere

**Access the trader from anywhere during the trader phase in Killing Floor 2.** Trader Anywhere opens all enabled trader pods and lets players use the game's normal interaction key without having to run to a pod.

## ✨ Features

- **All trader pods open** — use any enabled trader pod on the map during the trader phase.
- **Remote trading** — open the standard trader menu from anywhere using your existing interaction key.
- **Native controls** — keep the game's interaction prompts and hold-to-auto-buy behavior.
- **Normal interactions** — nearby usable objects, such as doors, retain priority.
- **Wave-aware behavior** — remote trading is unavailable during combat.

## 🎮 How to use

Finish a wave and press **Use** (**E** by default) during the trader phase to open the shop. Hold the same key to use the game's normal auto-buy action.

You can also approach any enabled trader pod and interact with it normally. The mod does not add a separate keybind or change weapon prices.

## 📦 Installation

### Dedicated server (Windows)

1. Stop the KF2 server instances using the installation you want to modify.
2. Download `TraderAnywhere-0.1.0.zip` from [GitHub Releases](https://github.com/thereisnouser/kf2-trader-anywhere/releases) (once the first binary release is available) and extract it.
3. Double-click **install.cmd**, then enter your dedicated server folder (the folder containing `KFGame` and `Binaries`).
4. Add the following to your server's Survival map URL, then start the server normally:

```text
?Mutator=TraderAnywhere.TA_Mutator
```

Already using mutators? Append `,TraderAnywhere.TA_Mutator` to the existing `?Mutator=` list instead.

The installer copies the package, backs up a previous version if necessary, and verifies the installed file. It does not edit your launch script or restart your server. Your normal mod distribution setup must allow clients to receive the package.

### Manual installation

Copy `TraderAnywhere.u` into `KFGame/BrewedPC/` inside the dedicated server folder and add the same mutator parameter above. To uninstall, remove the mutator from your launch configuration and restart the server.

Trader Anywhere is not officially whitelisted by Tripwire and is intended for modded/Unranked Survival servers. Standard mutator loading may disable Ranked progression.

## 🛠️ Development

Trader Anywhere is an **UnrealScript** mutator for Killing Floor 2.

### Requirements

- A local **Killing Floor 2** installation.
- **Killing Floor 2 SDK**, launched at least once to generate its user configuration.
- **Windows PowerShell**.

### Building

From the repository root, replace the example SDK directory with your own:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 `
  -SdkDir '<Killing Floor 2 SDK directory>' -Brew
```

The script registers the package in the SDK configuration, compiles its sources, and brews `dist/BrewedPC/Script/TraderAnywhere.u`. Omit `-Brew` to compile without brewing. It does not install files on a dedicated server.

### Create a release ZIP

Build and package the mod in one command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\package.ps1 `
  -SdkDir '<Killing Floor 2 SDK directory>'
```

The script produces `dist/TraderAnywhere-0.1.0.zip` containing `TraderAnywhere.u`, `install.cmd`, and `install.ps1`, and checks that the archived package matches the compiled binary. Omit `-SdkDir` to package an existing build.

### Local testing

Launch the game with `-useunpublished -log` and run the following command in the game console:

```text
open KF-Spillway?Game=KFGameContent.KFGameInfo_Survival?Difficulty=0?GameLength=1?Mutator=TraderAnywhere.TA_Mutator
```

Finish a wave, check all trader pods, test the interaction key and hold-to-auto-buy, then verify that remote trading stops when combat resumes.

### Implementation

The mutator uses a server-side controller, replicated trader phase state, and per-player interaction triggers to make the standard trader UI available during trader time. It does not directly modify weapon damage, prices, or XP.

The development build was tested locally and on a dedicated server, including other connected players and a map transition. The public 0.1.0 source revision still needs a fresh SDK build and full multiplayer regression testing.

## 🔗 Links

[Report an issue](https://github.com/thereisnouser/kf2-trader-anywhere/issues) · [Changelog](CHANGELOG.md)

---

*Made by thereisnouser*
