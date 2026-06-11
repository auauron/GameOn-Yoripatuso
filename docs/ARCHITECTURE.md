# Dual-Era Architecture

## Runtime Shape

`GameRoot` persists while outdoor worlds and interiors are replaced inside `WorldContainer`. The player, camera, HUD, collectible, Cultural Echo controller, portal boundary, and story state therefore survive scene changes.

- `scripts/gameplay/game_root.gd`: world loading, era transition, objectives, interiors, and artifact routing
- `scripts/gameplay/game_state.gd`: pure Eye Piece and one-way past-transition rules
- `scripts/world/exploration_world.gd`: shared outdoor bounds, spawn markers, and coordinate clamping
- `scripts/player/player.gd`: movement, nearest interaction, and dynamic camera limits
- `scripts/audio/echo_controller.gd`: distance-based volume across four optional audio layers
- `scripts/integration/portal_gateway.gd`: organizer integration boundary

## Scene Responsibilities

- `scenes/gameplay/game_root.tscn`: persistent runtime assembly and startup scene
- `scenes/worlds/modern_oton_world.tscn`: 6400x4200 Modern Oton, Eye Piece locations, modern house entrance
- `scenes/worlds/ancient_katagman_world.tscn`: matching geography, Nose Piece locations, ancient kubo entrance
- `scenes/interiors/modern_house_interior.tscn`: reusable present-day interior contract
- `scenes/interiors/ancient_kubo_interior.tscn`: reusable historical interior contract
- `scenes/world/searchable_prop.tscn`: openable cover or container with a `RevealPoint`
- `scenes/world/world_entrance.tscn` and `world_exit.tscn`: reusable `E` interactions

## Asset Handoff

### Outdoor Worlds

Replace or extend each scene's `WorldVisual` with `TileMapLayer`, `Sprite2D`, `AnimatedSprite2D`, particles, and authored collision. Keep the world root script, `SharedAnchors`, `PlayerSpawn`, `SafeTransitionSpawn`, `ArtifactSpawnPoints`, and `Entrances`.

Shared anchors must remain at matching coordinates across both eras. Art does not need a one-to-one match: a modern road can correspond to an ancient footpath, and a concrete house can correspond to a nipa or kubo structure.

### Player and Artifacts

Replace `Player/PlaceholderVisual` and `DirectionMarker`, preserving collision, interaction detector, and camera. Replace the artifact polygon children while preserving the `Artifact` root and collision. `GameRoot` configures the same collectible as the blue Eye Piece or gold Nose Piece.

### Interiors and Props

New interiors must expose `PlayerSpawn`, `WorldExit`, and `metadata/interior_bounds`. Create inherited searchable-prop scenes for beds, tables, drawers, cabinets, chests, baskets, and pottery. Preserve `ClosedVisual`, `OpenVisual`, `RevealPoint`, and collision nodes or update the script paths together.

### Cultural Echo Audio

Assign looping streams to `GameRoot/EchoController/NatureEcho`, `ActivityEcho`, `MusicEcho`, and `VoiceEcho`. The controller raises all available layers as the player approaches the selected artifact location. Empty channels are valid while the team adds assets.

## Required Contracts

- Both outdoor worlds keep `world_bounds = Rect2(0, 0, 6400, 4200)`.
- Modern artifact points use `eye_piece_spawn_points`; ancient points use `nose_piece_spawn_points`.
- Covered artifact points reference a `SearchableProp` through `searchable_prop_path`.
- Each entrance supplies a valid era-appropriate `interior_scene`.
- HUD node paths used by `hud.gd` remain stable unless the script changes in the same commit.
