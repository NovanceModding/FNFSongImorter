# File-by-file learning guide

## Haxe/HaxeFlixel ideas used here

A `class` groups state and behavior. `new()` is its constructor. Haxe requires
typed fields such as `timestampMs:Float`; `Null<Float>` explicitly allows the
absence of pitch. We use string constants rather than Haxe enum abstracts
because scripted Haxe support has varied between V-Slice/Polymod versions.

`SITSongImporterEditorState` extends `MusicBeatState`. In Haxe, `extends` means
it inherits the engine screen lifecycle. `create()` runs once after the state is
entered and constructs sprites/groups. `update(elapsed)` runs every frame;
`elapsed` is seconds since the prior frame. Both call `super` so the inherited
engine behavior still runs.

A `FlxSprite` is a drawable object with position, size, color, and lifecycle. A
`FlxTypedGroup<SITNoteView>` owns many note sprites while preserving their type.
The generated note objects are models; `SITNoteView` is only their view. This
separation prevents changing a rectangle color from becoming chart logic.

Callbacks are functions passed for later use. The export callback receives
`success`, `info`, or `error` after the platform file dialog completes. The
arrow function passed to `FlxG.switchState` constructs the next state when the
engine is ready.

## Important files

### `audio/SITAnalysisEvent.hxc`

Defines the analyzer-to-generator contract: time, duration, normalized strength,
nullable pitch, and source. An analyzer creates these; policies read them. Add
confidence or richer pitch contours here only when a real analyzer needs them.

### `audio/SITMockAudioAnalyzer.hxc`

Returns five deterministic events at 500, 750, 1000, 1250, and 1500 ms. The
editor calls it during regeneration. Replace this class with a JSON-backed or
native analyzer later, keeping the returned event type.

### `chart/SITGeneratedNote.hxc`

The editable, engine-neutral chart note. The generator/editor create and modify
it; the exporter reads it. It deliberately does not extend V-Slice
`SongNoteData`, avoiding schema coupling throughout the app.

### `chart/SITDifficultyPolicy.hxc`

Selects musical events for a requested difficulty. Normal is complete for Phase
1. Expand this with quantization, density targets, rhythmic importance, and
hand-authored policy settings.

### `chart/SITLaneAssigner.hxc`

Returns lanes separately from note construction. Its 0-1-2-3 rotation is a
temporary visual test—not a musical charting algorithm. Later consider recent
lane history, pitch motion, hand travel, jacks, chords, and accessibility.

### `chart/SITOwnerAssigner.hxc`

Implements Solo/VS independently of lanes. Replace the example vocal rule with
a config map such as `{melody: player, bass: player, vocals: opponent, drums:
ignored}`. “Ignored” should filter before lane assignment.

### `chart/SITChartGenerator.hxc`

Is the pipeline coordinator. The editor calls `generate`; it calls difficulty,
lane, and ownership policies and returns model objects. It imports no UI types.

### `chart/SITChartExporter.hxc`

Is the translation boundary. It produces the safe intermediate format and a
preview of the official compact chart fields. When V-Slice changes schema, this
is the principal file to update. `promptIntermediateSave` calls the engine's
file-dialog utility rather than writing arbitrary paths.

### `data/SITProjectConfig.hxc`

Holds user-editable project choices. The editor owns it and passes it down.
Later load/save this as a project JSON document rather than game progression
save data.

### `ui/SITInputFrame.hxc`

Maps mouse and first-touch input to semantic actions. The editor asks “primary
pressed?” rather than “left mouse clicked?” Wheel zoom and right-click are
desktop additions. It uses reflection because HaxeFlixel conditionally compiles
mouse/touch frontends for different targets. Later add pointer IDs, drag phases, long-press, and pinch
scale here, preserving the editor action API.

### `editor/SITNoteView.hxc`

Draws one note as a colored rectangle and holds a reference to its model. Green
is player, red opponent, yellow shared/solo. Later replace the generated bitmap
with note-style art without changing generation.

### `editor/SITSongImporterEditorState.hxc`

Builds the timeline, receives input, edits the notes array, positions views,
previews one existing engine music asset, and asks the exporter to save. The
vertical transform is `y = bottom - (time - viewStart) * zoom`; the inverse
turns a tap into time and then snaps it to 125 ms. Sustain resizing, scrolling,
and undo/redo do not belong in Phase 1.

### `integration/SITSongImporterModule.hxc`

V-Slice automatically instantiates scripted Modules. Every frame, this one
checks F6 and transitions to the custom state. It asks
`ScriptedMusicBeatState.scriptInit` to create the real proxy state before giving
it to Flixel. `opening` prevents duplicate transitions, while state-change hooks
reset the latch after entering/leaving so F6 works again. Replace this entry
adapter if the engine later gains a public custom menu registry.
