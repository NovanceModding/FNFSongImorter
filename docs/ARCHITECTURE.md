# Architecture and engine integration

## What the official V-Slice code says

This starter was checked against the official `FunkinCrew/Funkin` `main` branch
at commit `b2215482c25c5e98a72ac47b4807018934480d01`.

- Mods live below `mods/<mod-id>/` and use `_polymod_meta.json`. The current
  engine rule in `PolymodHandler` is `>=0.8.0 <0.9.0`.
- `.hxc` files below a mod's `scripts/` directory are Polymod scripted classes.
  `MusicBeatState` and `Module` are explicitly scriptable. Modules are created
  at mod load and receive global update/state/gameplay events.
- `MusicBeatState` is the useful FNF form of a HaxeFlixel `FlxState`: it is a
  screen-sized collection of objects and also dispatches beat/script events.
- The official chart model is `SongChartData`: version, per-difficulty scroll
  speeds, events, and a map of difficulty names to `SongNoteData` arrays.
  A note serializes compactly as `t` (milliseconds), `d` (combined strumline and
  lane), and optional `l`, `k`, and `p`. For a four-key chart, `d` 0–3 is the
  player strumline and 4–7 is the opponent strumline.
- Official editor export uses `FileUtil.writeFileReference`, which opens a
  platform save dialog. Direct `FlxG.save` access is intentionally blacklisted
  for scripts. V-Slice's own save system is for preferences/progression, not a
  sensible project-document format.
- The official full `ChartEditorState` is source code behind
  `FEATURE_CHART_EDITOR` and is thousands of lines long. This prototype does not
  subclass or patch it.

## Honest mod/source boundary

The Phase 1 editor, mock audio reference, generation, and download-style JSON
export can be a normal mod. A global F6 module is the stable entry used here.

A polished first-class main-menu button requires an engine/source modification
because the stock menu constructs and handles its own fixed options; no public
JSON registry advertises arbitrary custom states. Native audio decoding, Python
AI tools, Demucs, and unrestricted project-directory I/O also belong in an
external desktop tool or a source extension/native bridge. Mobile sandboxing
and platform codecs make that split even more important.

The practical long-term shape is likely hybrid:

```text
external/native analyzer -> portable intermediate JSON -> V-Slice editor mod
                                                -> chart + metadata + audio assets
```

On desktop, a source build could host analysis directly. On Android/iOS, a
separate service/app or pre-analysis workflow is more realistic than shipping
large Python/ML dependencies inside V-Slice.

## Replaceable pipeline

```text
audio reference
  -> SITMockAudioAnalyzer
  -> Array<SITAnalysisEvent>
  -> SITDifficultyPolicy
  -> SITLaneAssigner
  -> SITOwnerAssigner
  -> Array<SITGeneratedNote>
  -> SITChartExporter
  -> intermediate JSON / V-Slice chart JSON
```

`SITChartGenerator` knows about analysis events, policies, notes, and config. It
does not import Flixel. The editor calls the pipeline and renders its result.
This is the dependency direction that allows mock analysis to be replaced by an
onset detector without rewriting the editor.

Difficulty is a policy over musical intent. Easy currently retains strong
accents; Normal represents every supplied event; Hard intentionally has only a
placeholder pass-through. Later, Hard should accept meaningful additional
subdivision/ornament events, not become the foundation from which random notes
are deleted.

Ownership is another policy. Solo returns `shared` (exported onto the player
strumline in this starter); VS currently sends vocals to opponent and all other
sources to player. Later this becomes a source-to-owner settings map.

## From preview JSON to a playable song

`example-vslice-chart.json` shows only `SongChartData`. A playable V-Slice song
also needs correctly named song metadata (current schema `2.2.x`), instrumental
and optional voice audio assets in the engine's expected song folders, plus any
album/freeplay/story registration desired by the mod. The next converter should
construct or validate both metadata and chart files using the current registry
schemas. Keep `SITGeneratedNote` unchanged; only the export boundary needs to
track future V-Slice schema revisions.

