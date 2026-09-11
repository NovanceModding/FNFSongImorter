# FNF V-Slice Song Importer — Phase 1 Starter

This repository is intentionally a small **Polymod/HScript mod**, not a fork of
the whole Friday Night Funkin' engine. It proves the replaceable data pipeline
and a four-lane editor without pretending to contain audio analysis.

The template targets the official Funkin **v0.8.6** tag at commit
`ee9d492becfc1178b2c80487167d09a880f90146`, whose mod API accepts `0.8.x` mods
and whose chart schema is `2.0.0`. See `docs/ARCHITECTURE.md` for
the engine research and integration limits.

## Install and run

1. Use an official V-Slice build with mod support (API `0.8.x`).
2. Copy `mod/song-importer-starter` into the game's `mods` folder, so the
   metadata ends up at `mods/song-importer-starter/_polymod_meta.json`.
3. Enable **Song Importer Starter** in the in-game Mods menu, then restart or
   reload mods.
4. From most game screens, press **F6**. The global module opens the editor.
5. During the current v0.8.6 compatibility isolation test, the editor displays
   only a confirmation message. **Escape** returns to the main menu. The Phase 1
   controls remain separated in their scripts but will be reintroduced only
   after this minimal state is confirmed by the real game runtime.

The editor entry hotkey is deliberate. A scripted state is supported, but the
stock main menu does not expose a stable data-driven registry for arbitrary menu
items. `engine-patch/README.md` explains the optional source-build integration
point for a real menu button.

## Project map

```text
mod/song-importer-starter/
  _polymod_meta.json
  scripts/
    audio/       mock analyzer and future analysis boundary
    chart/       models, policies, pipeline, exporter
    data/        editable project settings
    editor/      HaxeFlixel editor state and note view
    ui/          pointer/keyboard/touch input snapshot
    integration/ global F6 module
  data/song-importer/examples/
                 readable mock input and expected exports
docs/            architecture, file-by-file teaching guide, roadmap
engine-patch/    optional source-build instructions (no engine files copied)
tools/           local fixture verification
```

Folders under `scripts/` are organization, not hidden coupling: each `.hxc`
defines a uniquely named scripted class, and the engine's Polymod loader
registers those classes. The chart pipeline imports no Flixel UI classes.

## Verify this repository

This environment does not contain a complete V-Slice/Haxe build, so it cannot
compile the mod in isolation: `.hxc` classes are interpreted by V-Slice and rely
on engine types. The fixture validator still checks the example contracts:

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify-fixtures.ps1
```

For a real runtime check, install the mod in the matching V-Slice build and
watch the log for HScript parsing errors. Exact API compatibility matters;
future `0.9.x` releases may require small integration updates.

## Official references used

- [Funkin source repository](https://github.com/FunkinCrew/Funkin)
- [v0.8.6 Polymod handler and API rule](https://github.com/FunkinCrew/Funkin/blob/ee9d492becfc1178b2c80487167d09a880f90146/source/funkin/modding/PolymodHandler.hx)
- [v0.8.6 song/chart models](https://github.com/FunkinCrew/Funkin/blob/ee9d492becfc1178b2c80487167d09a880f90146/source/funkin/data/song/SongData.hx)
- [v0.8.6 official chart editor](https://github.com/FunkinCrew/Funkin/blob/ee9d492becfc1178b2c80487167d09a880f90146/source/funkin/ui/debug/charting/ChartEditorState.hx)
- [Official scripted-class documentation](https://funkincrew.github.io/funkin-modding-docs/21-scripted-classes/21-00-scripted-classes.html)
