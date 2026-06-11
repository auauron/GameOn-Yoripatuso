# Prototype Architecture

## Ownership Boundaries

### `scripts/gameplay/`

Owns round flow and spawn selection. `game_round.gd` coordinates components but does not contain movement, UI rendering, audio math, or API implementation.

### `scripts/player/`

Owns movement and nearest-interactable selection. Art can change without changing this script.

### `scripts/interactions/`

Defines the small `Interactable` contract shared by props and artifacts.

### `scripts/world/`

Owns hiding-place metadata and searchable prop state.

### `scripts/artifact/`

Owns reveal, collect, and reset behavior for the Nose Piece.

### `scripts/audio/`

Maps player distance to a normalized Cultural Echo intensity. The four `AudioStreamPlayer` children accept ambience, activity, music, and voice assets independently.

### `scripts/integration/`

Owns the organizer portal boundary. Replace the body of `trigger_portal_unlock_placeholder()` when the real contract arrives; gameplay should not know HTTP details.

### `scripts/ui/`

Owns prototype labels, panels, and button signals. It is intentionally separate from the final UI design.

## Scene Responsibilities

- `scenes/gameplay/main_game.tscn`: level assembly and authored hiding spots
- `scenes/player/player.tscn`: player collision, detector, camera, placeholder
- `scenes/world/searchable_prop.tscn`: reusable searchable cover or container
- `scenes/world/artifact_spawn_point.tscn`: location name and optional prop link
- `scenes/artifact/artifact.tscn`: collectible placeholder and collision
- `scenes/ui/hud.tscn`: intro, interaction prompt, portal result, restart

## Asset Replacement Points

### Player

Replace `Player/PlaceholderVisual` and `Player/DirectionMarker`. Keep `Player`, `CollisionShape2D`, `InteractionDetector`, and `Camera2D`.

### Artifact

Replace `Artifact/PlaceholderVisual`, `Artifact/CenterCut`, and `Artifact/Glow`. Assign a discovery clip to the artifact scene's `discovery_sound` Inspector property.

### Searchable Props

Create inherited scenes from `searchable_prop.tscn` for each final prop. Replace `ClosedVisual` and `OpenVisual`; adjust the interaction, blocker, and reveal-point shapes to match the art. Assign an opening sound through `search_sound`.

### Cultural Echoes

Assign looping streams in `MainGame/World/EchoController`:

- `NatureEcho`
- `ActivityEcho`
- `MusicEcho`
- `VoiceEcho`

All streams are optional. Missing audio never blocks gameplay.

## Required Contracts

- Spawn points remain in the `artifact_spawn_points` group.
- Searchable props remain in the `searchable_props` group.
- Covered spawn points reference their owning prop through `searchable_prop_path`.
- Every searchable prop keeps a `RevealPoint` child.
- HUD node paths used by `hud.gd` remain stable unless the script is updated simultaneously.

## Future Expansion

Museum archives, trade, goldsmithing, and burial-context puzzles should become separate scenes. They should report completion to a higher-level chapter controller instead of expanding `game_round.gd` into a full-game manager.

