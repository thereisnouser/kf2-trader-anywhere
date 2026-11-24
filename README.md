# Trader Anywhere

A quality-of-life mutator for Killing Floor 2 (KF2) Survival. All enabled trader pods open during the trader phase, and players can access the shop from anywhere using their normal interaction key.

**Version:** 0.1.0 — first public source version.

## Features

- Opens every enabled map trader pod during the trader phase.
- Opens the standard trader menu with the usual interaction key (E by default), even away from a pod.
- Uses the game's native interaction prompts and hold-to-auto-buy behavior.
- Gives nearby usable objects, such as doors, priority over remote trading.
- Disables remote trading during combat.
- Replicates trader state to connected clients, including players joining mid-phase.
- Uses standard Survival gameplay; does not directly modify prices, weapons, damage, or XP.

## Build

Requirements: Windows, Killing Floor 2, and the Killing Floor 2 SDK. Run the SDK once to generate its user configuration.

From the repository root, run PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -SdkDir "F:\Steam\steamapps\common\killingfloor2" -Brew
```

Replace the SDK path with your actual installation directory. Without the `-Brew` switch, the script only compiles the UnrealScript package.

The script registers the package in the user SDK configuration, copies the source files, compiles them, and optionally brews the package. It backs up the INI before modifying the package registration. It does not install anything on a dedicated server.

The brewed output is:

```text
dist\BrewedPC\Script\W4AllTraders.u
```

The internal package and class names retain the original development naming for compatibility.

## Local testing

Launch KF2 with Steam launch options `-useunpublished -log`. Open the in-game console and run:

```text
open KF-Spillway?Game=KFGameContent.KFGameInfo_Survival?Difficulty=0?GameLength=1?Mutator=W4AllTraders.W4AT_Mutator
```

Finish a wave, check that every pod opens, try normal interaction and hold-to-auto-buy away from a pod, and verify that remote trading stops when the next wave begins.

## Dedicated server

1. Back up your server configuration and any existing package of the same name.
2. Stop the instance you intend to modify.
3. Copy the brewed `W4AllTraders.u` into the server's `KFGame\BrewedPC\` directory.
4. Add `?Mutator=W4AllTraders.W4AT_Mutator` to the Survival map URL. If a mutator list already exists, append the class name to that comma-separated list instead.
5. Ensure clients can receive the required package through your mod distribution setup.
6. Start the server and check its log for `W4AllTraders` initialization messages.

To uninstall, remove the mutator from the launch configuration and restart the instance. The mod does not require a custom game mode.

## Ranked and compatibility

Trader Anywhere is not officially whitelisted by Tripwire. Standard mutator loading may mark a server Unranked and affect progression. Use it on modded/Unranked servers unless official approval is obtained. Compatibility with third-party loaders is not official Ranked approval. No progression or anti-cheat compatibility guarantees are made.

The development build was tested locally and on a dedicated server, including other clients and a map transition. The public version retains its gameplay logic with updated version metadata. The exact public revision still needs a fresh SDK build, and exhaustive multiplayer/load testing has not been completed.

## Technical references

- [KF2 Game Scripts](https://github.com/GenZmeY/KF2-Game-Scripts)
- [KF2 Modding for Dummies](https://steamcommunity.com/sharedfiles/filedetails/?id=1112644122)

This is an independent community mod, not an official Tripwire Interactive product.
