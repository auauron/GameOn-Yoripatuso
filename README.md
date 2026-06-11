# Hutik sa Katagman

Godot 4.4 exploration prototype set across Modern Oton in 2026 and a historically grounded reconstruction of 14th-15th century Katagman.

## Run

Open `project.godot` in Godot 4.4 and press **F5**.

Controls:

- `WASD` or arrow keys: move
- `E`: search, enter a building, exit, or recover an artifact
- `F`: use the recovered Eye Piece to witness the past
- `M`: open or close the exploration map and view your location
- `F11`: toggle fullscreen mode

## Current Game Flow

1. Explore the 6400x4200 Modern Oton map and follow Cultural Echoes to the hidden Eye Piece.
2. Recover it with `E`, then press `F` to enter ancient Katagman at the same geographic coordinate.
3. Explore the ancient settlement, including enterable kubo interiors, and locate the Nose Piece.
4. Recover the Nose Piece to complete the Oton Gold Death Mask discovery flow.

The two outdoor scenes share river, residential, craft, market, and burial-area anchors. Their buildings, routes, props, vegetation, and atmosphere are authored independently for each era.

The first art-direction showcase is the residential district: the same coordinates become a warm 2026 Oton neighborhood or a raised-kubo Katagman settlement. Both use a high three-quarter layered-diorama camera, dense story clusters, foot-based depth sorting, and foreground foliage that can frame the player without blocking movement.

A live minimap appears in the top-right during exploration. The full map shows the current era and coordinates without revealing either artifact's hiding place. Inside buildings it marks the outdoor position you will return to.

## Team Workflow

Gameplay code is grouped by feature under `scripts/`. Persistent systems live in `scenes/gameplay/game_root.tscn`; swappable outdoor and interior content lives under `scenes/worlds/` and `scenes/interiors/`.

Final assets belong under `assets/`; see [assets/README.md](assets/README.md). Replace procedural blockout visuals without renaming scripted roots, collision children, spawn markers, entrances, exits, or HUD nodes. Detailed ownership and replacement points are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

Residential previews are generated at `docs/modern-residential-diorama-preview.png` and `docs/ancient-residential-diorama-preview.png`.

## Automated Check

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --quit-after 30
```
