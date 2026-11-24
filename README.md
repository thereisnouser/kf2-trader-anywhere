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

### Dedicated server

Build the package from source using the instructions below.

1. Back up your server configuration and stop the server instance you intend to modify.
2. Copy `W4AllTraders.u` into the server's `KFGame/BrewedPC/` directory.
3. Add the mutator to your Survival map URL:

```text
?Mutator=W4AllTraders.W4AT_Mutator
```

If the URL already contains `?Mutator=`, append `W4AllTraders.W4AT_Mutator` to the existing comma-separated list. Ensure connecting clients can receive the package through your server's mod distribution setup.

Start the server and check its log for the `W4AllTraders` initialization message. To uninstall, remove the mutator from the launch configuration and restart the instance.

Trader Anywhere is intended for modded Survival servers. It is not officially whitelisted by Tripwire; standard mutator loading may mark a server Unranked and affect progression.

## 🛠️ Development

Trader Anywhere is an **UnrealScript** mutator for Killing Floor 2. Its internal package and class names retain the original `W4AllTraders` development naming.

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

The script registers the package in the SDK configuration, compiles its sources, and brews `dist/BrewedPC/Script/W4AllTraders.u`. Omit `-Brew` to compile without brewing. It does not install files on a dedicated server.

### Local testing

Launch the game with `-useunpublished -log` and run the following command in the game console:

```text
open KF-Spillway?Game=KFGameContent.KFGameInfo_Survival?Difficulty=0?GameLength=1?Mutator=W4AllTraders.W4AT_Mutator
```

Finish a wave, check all trader pods, test the interaction key and hold-to-auto-buy, then verify that remote trading stops when combat resumes.

### Implementation

The mutator uses a server-side controller, replicated trader phase state, and per-player interaction triggers to make the standard trader UI available during trader time. It does not directly modify weapon damage, prices, or XP.

The development build was tested locally and on a dedicated server, including other connected players and a map transition. The public 0.1.0 source revision still needs a fresh SDK build and full multiplayer regression testing.

## 🔗 Links

[Report an issue](https://github.com/thereisnouser/kf2-trader-anywhere/issues) · [Changelog](CHANGELOG.md)

---

*Made by thereisnouser*
