# Changelog

## 1.0.0

First release, extracted from [TurnTV](https://github.com/TSUISHI/TurnTV) v1.0.1
and rebuilt as a reusable Godot addon.

- `CRTScreen` node driving the whole pipeline: content canvas, Stage 1 signal
  SubViewport and Stage 2 display pass.
- `CRTSettings` resource holding all 48 shader parameters, with inspector
  integration, dictionary and JSON round-trip.
- `CRTPresets` with Composite TV, CRT Studio, Famicom RF, RGB Direct and
  Lightweight.
- Quarter-turn `screen_rotation` and `content_rotation` for vertical (tate)
  games; the tube rotates together with its scanlines and phosphor mask.
- `display_fit` and `screen_aspect` for tube shape, including non-square pixels.
- Demo with an animated test pattern, every parameter, preset switching, image
  loading by dialog or drag and drop, and settings JSON export.
