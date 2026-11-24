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

These instructions are for a **Windows KF2 dedicated server that is already installed**. You do not need programming knowledge, the KF2 SDK, or any `.ini` configuration changes.

### 1. Find your server folder

If your server is currently running:

1. Press **Ctrl + Shift + Esc** to open Task Manager.
2. Open the **Details** tab, find `KFServer.exe`, right-click it and choose **Open file location**.
3. File Explorer opens the `Binaries\Win64` folder. Go up two folders (click the up arrow twice). This is your server folder.
4. Click the Explorer address bar and copy the full folder path.

For example, your server folder may be `C:\KF2Server`:

```text
C:\KF2Server\
  KF2Server.bat
  Binaries\
    Win64\
      KFServer.exe
  KFGame\
    BrewedPC\
    Config\
```

The location and launcher filename may differ. If the server is not running, open the folder where you installed the dedicated server with SteamCMD (the `force_install_dir` path), or use **Manage → Browse local files** for the dedicated server tool in Steam if installed through Steam.

### 2. Install the mod

1. Stop your server. If several servers share the same installation folder, stop all of them first.
2. Open [GitHub Releases](https://github.com/thereisnouser/kf2-trader-anywhere/releases) and download **TraderAnywhere-0.1.0.zip** when the binary release is available. Do not download `Source code (zip)`.
3. Right-click the downloaded ZIP, choose **Extract All**, then open the extracted folder.
4. Double-click **install.cmd**. Paste your server folder path from step 1 and press Enter.

When you see `Installed:` or `Trader Anywhere is already installed`, the mod is in the correct folder. The installer also creates a ready-to-use basic server launcher in that folder and prints its location. You do not need to copy files yourself or open the Config folder. If the optional launcher cannot be created, the installer displays a warning and the manual activation instructions still apply.

### 3. Start the server with the mod enabled

Choose the option that matches how you want to launch your server.

#### Option A — Start with one double-click (recommended for a basic server)

1. Open the dedicated server folder you selected in the installer.
2. Double-click **StartServer.cmd** (or **StartServer-TraderAnywhere.cmd**, if the first filename was already in use). The installer displays the exact file path.
3. Press **Y** to start the server. Leave its window open while playing.

That's it. No configuration editing or commands are needed. This launcher starts a basic Survival server on Spillway with Trader Anywhere enabled. It uses the server's normal configuration and default launch options; it does not copy custom ports, other mutators, or options from your usual launcher. Stop other servers using the same ports before starting it.

Your existing startup files are never overwritten. If both filenames are already occupied by other files, use Option B.

#### Option B — Keep your existing server settings

If you already start your server by double-clicking a `.bat` or `.cmd` file, continue using that file. The standard Windows launcher is commonly named `KF2Server.bat` and is located in the server folder from step 1.

1. Make a copy of your launcher file as a backup.
2. Right-click the original launcher → **Edit** (on Windows 11, use **Show more options** if needed), or open Notepad and use **File → Open** to select the launcher. Choose **All files** if it is not visible.
3. Find the line that starts `KFServer.exe` or `kfserver`. Find the map name in that line, such as `KF-BioticsLab` or `KF-Spillway`.
4. Add the mod parameter to the map name and its existing options, before any space-separated flags such as `-Port`. Keep everything else unchanged. Use the examples below.

**Example — no other mutators:**

Before:

```bat
start .\Binaries\Win64\KFServer.exe KF-BioticsLab?Difficulty=2
```

After:

```bat
start .\Binaries\Win64\KFServer.exe KF-BioticsLab?Difficulty=2?Mutator=TraderAnywhere.TA_Mutator
```

**Example — another mutator is already enabled:**

Before:

```text
KF-BioticsLab?Mutator=ExampleMod.ExampleMutator?Difficulty=2
```

After:

```text
KF-BioticsLab?Mutator=ExampleMod.ExampleMutator,TraderAnywhere.TA_Mutator?Difficulty=2
```

`ExampleMod.ExampleMutator` is just a placeholder for your existing mod. Do not add a second `?Mutator=` or remove the other mods. If the map and its options are inside quotation marks, keep the added text inside those same quotation marks.

5. Press **Ctrl + S**, close Notepad and start your server using the same launcher as before.

If your server uses a hosting panel or a server manager, use its startup arguments or mutator-list setting instead. The exact menu depends on the provider; do not replace the entire startup command. For a custom PowerShell launcher, edit the map URL that the script passes to the server. If you cannot find the startup settings, ask the server administrator or hosting provider.

### 4. Check that it works

Join your server, finish the first wave, then press **E** during trader time without standing next to a trader. The standard shop should open.

If it does not, check that `TraderAnywhere.u` exists in your server's `KFGame\BrewedPC` folder and look for `TraderAnywhere: v0.1.0 runtime initialized` in the latest log under `KFGame\Logs`. Your server's existing mod distribution setup must allow connecting clients to receive the package.

### Uninstall

Stop the server, remove only `TraderAnywhere.TA_Mutator` from the launcher (remove the whole `?Mutator=` option if it was the only mutator), then restart the server. You can leave the unused package in place or delete `KFGame\BrewedPC\TraderAnywhere.u` once no server uses it. You may also delete the basic launcher created by the installer (do not delete your original server launcher).

Trader Anywhere is intended for modded/Unranked Survival servers and is not officially whitelisted by Tripwire. Standard mutator loading may disable Ranked progression.

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

The script produces `dist/TraderAnywhere-0.1.0.zip` containing `TraderAnywhere.u`, `install.cmd`, `install.ps1`, and `LICENSE`, and checks that the archived package matches the compiled binary. Omit `-SdkDir` to package an existing build.

### Local testing

Launch the game with `-useunpublished -log` and run the following command in the game console:

```text
open KF-Spillway?Game=KFGameContent.KFGameInfo_Survival?Difficulty=0?GameLength=1?Mutator=TraderAnywhere.TA_Mutator
```

Finish a wave, check all trader pods, test the interaction key and hold-to-auto-buy, then verify that remote trading stops when combat resumes.

### Implementation

The mutator uses a server-side controller, replicated trader phase state, and per-player interaction triggers to make the standard trader UI available during trader time. It does not directly modify weapon damage, prices, or XP.

The 0.1.0 gameplay package was built and tested locally and on a dedicated server. The basic server launcher is separate from the gameplay package.

## 📄 License

Distributed under the [MIT License](LICENSE).

## 🔗 Links

[Report an issue](https://github.com/thereisnouser/kf2-trader-anywhere/issues) · [Changelog](CHANGELOG.md)

---

*Made by thereisnouser*
