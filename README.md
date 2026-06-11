# Hutik sa Katagman

Godot 4.4 prototype for the hackathon vertical slice.

## Run

Open `project.godot` in Godot 4.4 and press **F6** or **F5**.

Controls:

- `WASD` or arrow keys: move
- `E`: search or recover the artifact
- `R`: restart after completing a round

## Current Prototype

- Top-down placeholder Katagman settlement
- Six randomized artifact hiding spots
- Three searchable environmental props
- Four empty Cultural Echo audio channels
- Oton Gold Death Mask Nose Piece collection
- Simulated organizer portal payload
- Replayable rounds without immediate spawn repetition

## Team Workflow

Gameplay code is grouped by feature under `scripts/`. Reusable scenes live under `scenes/`. Final assets belong under `assets/`; see [assets/README.md](assets/README.md).

Do not replace gameplay scenes just to add art. Open the relevant scene, replace its placeholder visual child with a `Sprite2D` or `AnimatedSprite2D`, then preserve the root script, collision nodes, groups, and node names used by scripts.

Architecture details are documented in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Automated Check

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
```

