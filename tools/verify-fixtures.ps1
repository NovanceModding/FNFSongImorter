$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$exampleRoot = Join-Path $root 'mod/song-importer-starter/data/song-importer/examples'
$analysis = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'mock-analysis.json') | ConvertFrom-Json
$intermediate = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'example-intermediate.json') | ConvertFrom-Json
$vslice = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'example-vslice-chart.json') | ConvertFrom-Json
$metadata = Get-Content -Raw -LiteralPath (Join-Path $root 'mod/song-importer-starter/_polymod_meta.json') | ConvertFrom-Json

if ($analysis.events.Count -ne 5) { throw 'Expected five mock analysis events.' }
if (($analysis.events.timestampMs -join ',') -ne '500,750,1000,1250,1500') { throw 'Mock timestamps changed unexpectedly.' }
if ($intermediate.notes.Count -ne 5) { throw 'Expected five generated notes.' }
if (($intermediate.notes.lane -join ',') -ne '0,1,2,3,0') { throw 'Lane rotation contract failed.' }
if ($intermediate.notes[2].owner -ne 'opponent') { throw 'VS vocal ownership contract failed.' }
if ($vslice.version -ne '2.0.0') { throw 'Unexpected V-Slice fixture version.' }
if (($vslice.notes.normal.d -join ',') -ne '0,1,6,3,0') { throw 'V-Slice strumline conversion contract failed.' }
if ($metadata.api_version -ne '0.8.6') { throw 'Mod metadata must target FNF v0.8.6.' }

$modulePath = Join-Path $root 'mod/song-importer-starter/scripts/integration/SITSongImporterModule.hxc'
$moduleSource = Get-Content -Raw -LiteralPath $modulePath
if ($moduleSource -notmatch "FlxG\.state == null") { throw 'State transition null guard is missing.' }
if ($moduleSource -notmatch "ScriptedMusicBeatState\.scriptInit\('SITSongImporterEditorState'\)") { throw 'Scripted state proxy initialization is missing.' }
if ($moduleSource -match "switchState\(\(\) -> new SITSongImporterEditorState") { throw 'Unsafe deferred scripted-state construction returned.' }
if ($moduleSource -notmatch 'onStateChangeEnd') { throw 'Transition latch reset hook is missing.' }

Write-Output 'Verification passed: fixtures and v0.8.6 scripted-state transition guards.'
