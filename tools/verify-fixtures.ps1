$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$exampleRoot = Join-Path $root 'mod/song-importer-starter/data/song-importer/examples'
$analysis = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'mock-analysis.json') | ConvertFrom-Json
$intermediate = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'example-intermediate.json') | ConvertFrom-Json
$vslice = Get-Content -Raw -LiteralPath (Join-Path $exampleRoot 'example-vslice-chart.json') | ConvertFrom-Json

if ($analysis.events.Count -ne 5) { throw 'Expected five mock analysis events.' }
if (($analysis.events.timestampMs -join ',') -ne '500,750,1000,1250,1500') { throw 'Mock timestamps changed unexpectedly.' }
if ($intermediate.notes.Count -ne 5) { throw 'Expected five generated notes.' }
if (($intermediate.notes.lane -join ',') -ne '0,1,2,3,0') { throw 'Lane rotation contract failed.' }
if ($intermediate.notes[2].owner -ne 'opponent') { throw 'VS vocal ownership contract failed.' }
if ($vslice.version -ne '2.0.0') { throw 'Unexpected V-Slice fixture version.' }
if (($vslice.notes.normal.d -join ',') -ne '0,1,6,3,0') { throw 'V-Slice strumline conversion contract failed.' }

Write-Output 'Fixture verification passed: mock analysis -> generated notes -> V-Slice preview.'
