# Optional source-build integration

This directory intentionally contains no blind patch against a moving engine.
In the inspected official tree, `source/funkin/ui/mainmenu/MainMenuState.hx`
constructs and dispatches its menu choices directly. To add a first-class item
in a source build:

1. Add a unique `song-importer` option where `MainMenuState` creates options.
2. Add a selection branch that switches to the importer state.
3. Promote the `.hxc` state to compiled `.hx` source, or instantiate the
   registered scripted state through the current Polymod scripted-class API.
4. Guard editor-only dependencies with the same target/build decisions used by
   the official debug editors.

This creates an engine fork maintenance cost. The F6 module is the recommended
Phase 1 path because it remains an ordinary mod.

