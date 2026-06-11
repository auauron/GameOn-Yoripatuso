# Hutik sa Katagman Dual-Era World Expansion Design

## Purpose

Expand the compact prototype into a large exploration game spanning two versions of Oton that share the same geography:

- Modern Oton in 2026, where the Eye Piece is hidden.
- Reconstructed Katagman in the late 14th to early 15th century, where the Nose Piece is hidden.

The player explores the modern world first, recovers the Eye Piece, and presses `F` to transition into the past reconstruction. The prototype remains asset-ready and uses placeholders until the team adds final art and audio.

## Selected World Structure

Use the approved hybrid structure:

1. One large seamless outdoor world for Modern Oton.
2. One large seamless outdoor world for reconstructed Katagman.
3. Separate reusable interior scenes for houses, workshops, storage buildings, and other enterable locations.

This preserves a strong sense of outdoor distance without making every interior part of an unmanageable scene.

## Shared Geography

Both outdoor worlds use the same world dimensions, coordinate system, river course, shoreline, major paths, and landmark anchors. Their appearance and structures differ by era.

Example correspondence:

| Shared Location | Modern Oton 2026 | Reconstructed Katagman |
| --- | --- | --- |
| River landing | Concrete landing and motorized boats | Wooden landing and trading vessels |
| Residential area | Concrete homes and roadside structures | Nipa and kubo houses |
| Craft district | Modern workshop or commercial block | Goldsmith and pottery work areas |
| Central crossing | Paved or compacted road junction | Earthen settlement paths |
| Burial-area geography | Protected, altered, or unmarked modern space | Reconstructed burial preparation area |

The layout is not presented as a verified one-to-one historical reconstruction. It is a game-space interpretation designed to help players compare continuity and change.

## World Scale

Increase the outdoor map from `1280 x 720` to approximately `6400 x 4200` world units. The camera continues to show a `1280 x 720` viewport, so only a small part of the settlement is visible at once.

Scattered districts should be separated by meaningful travel space:

- Riverside district
- Modern residential / ancient domestic district
- Modern commercial / ancient market district
- Modern craft area / ancient workshop district
- Vegetation and field routes
- Burial-context geography

Long empty corridors should be avoided. Travel spaces should contain foliage, water views, small props, sound regions, minor clues, and future points of interest.

## Game Flow

```text
Start in Modern Oton 2026
-> explore outdoor districts and enter modern interiors
-> follow present-day Cultural Echo clues
-> find and recover the Eye Piece
-> unlock the F action
-> press F
-> play a short transition effect
-> load reconstructed Katagman at the corresponding world coordinates
-> explore outdoor districts and enter ancient interiors
-> follow past Cultural Echo clues
-> reveal and recover the Nose Piece
-> trigger the portal placeholder
```

For the first implementation slice, the Eye Piece may be assigned to one of several modern hiding spots and the Nose Piece to one of several ancient hiding spots.

## Era Transition

Before the Eye Piece is recovered, pressing `F` does nothing and may show a short message such as `The past remains out of reach.`

After recovery, pressing `F` from Modern Oton:

1. Disables player input.
2. Plays a brief fade, blur, or color-overlay placeholder transition.
3. Stores the player's outdoor coordinates.
4. Replaces the modern outdoor environment with the ancient environment.
5. Places the player at the same corresponding coordinates, adjusted to the nearest safe era spawn if that location is blocked.
6. Updates HUD era text and Cultural Echo target.
7. Re-enables input.

The initial expansion uses a one-way transition into Katagman. Returning to the modern world can be introduced later when the story flow requires it.

## Scene Architecture

```text
GameRoot (Node) [game_root.gd]
|- WorldContainer (Node2D)
|  `- CurrentOutdoorWorld (instanced at runtime)
|- Player (persistent CharacterBody2D)
|- ArtifactContainer (Node2D)
|- EchoController
|- TransitionController
|- PortalGateway
`- HUD
```

Outdoor era scenes:

```text
ModernOtonWorld (Node2D) [outdoor_world.gd]
|- Geography
|- EraEnvironment
|- Collision
|- Buildings
|- Entrances
|- SearchableProps
|- ArtifactSpawnPoints
|- SafeEraSpawns
`- AudioRegions

AncientKatagmanWorld (Node2D) [outdoor_world.gd]
|- Geography
|- EraEnvironment
|- Collision
|- Buildings
|- Entrances
|- SearchableProps
|- ArtifactSpawnPoints
|- SafeEraSpawns
`- AudioRegions
```

Both scenes preserve the same geographic anchors but own their era-specific visuals, collisions, buildings, props, artifact locations, and sounds.

## Persistent State

`GameRoot` owns state that survives scene changes:

```gdscript
enum Era { MODERN, ANCIENT }

var current_era := Era.MODERN
var eye_piece_collected := false
var nose_piece_collected := false
var current_outdoor_position := Vector2.ZERO
var current_interior_id := ""
var modern_eye_spawn_id := ""
var ancient_nose_spawn_id := ""
```

The outdoor world scenes do not own the overall story state. They expose authored nodes and report interactions to `GameRoot`.

## Artifact Roles

### Eye Piece

- Exists only in Modern Oton.
- Is randomly assigned to a modern hiding spot at game start.
- Uses modern environmental sounds and clues.
- Becomes a permanent story-state item when collected.
- Unlocks the `era_transition` input action mapped to `F`.

### Nose Piece

- Exists only in reconstructed Katagman.
- Is assigned when the ancient world begins.
- Uses ancient Cultural Echo layers.
- Triggers the organizer portal placeholder when recovered.

## Interiors

Building entrances use a reusable `WorldEntrance` component containing:

```gdscript
@export var interior_scene: PackedScene
@export var entrance_id: String
@export var interior_spawn_id: String
```

The first expansion includes two example interiors:

- A modern house or storage interior.
- An ancient kubo or workshop interior at the same geographic landmark.

When entering an interior, the game stores the outdoor era and return position. Leaving restores the player near the corresponding exterior doorway.

Interiors use focused scenes so each developer can work on a building without editing the large outdoor map.

## Camera and Navigation

- Camera limits expand to the full `6400 x 4200` world.
- Position smoothing remains enabled.
- The player speed may increase slightly after scale testing, but sprinting is deferred.
- Major paths connect every district.
- Collision must not make corresponding transition coordinates unsafe in both eras.
- `SafeEraSpawn` markers provide fallback positions near major shared landmarks.

## UI

The prototype HUD adds:

- Era label: `OTON, 2026` or `KATAGMAN RECONSTRUCTION`
- Eye Piece status after collection
- Context message: `Press F to witness the past`
- Short transition overlay
- Existing interaction and portal panels

No minimap or objective arrow is included in this phase. Future navigation aids should preserve the audio-led exploration design.

## Audio

Each world owns its ambient sound palette while the persistent echo controller follows the currently selected artifact target.

Modern examples:

- Road and neighborhood ambience
- Modern river activity
- Pages, cameras, interviews, radios, or workshop sounds

Ancient examples:

- Wind through nipa structures
- River and trading-vessel sounds
- Pottery, goldworking, marketplace activity, and reviewed voice material

Actual recordings remain team-supplied assets.

## Error Handling

- Missing outdoor scene: remain in the current era and show an error.
- Missing safe transition point: retain the same coordinates and log a warning.
- Missing interior scene: do not transition; preserve player control.
- Missing audio: continue silently.
- Missing artifact spawn points: stop that era's artifact round without crashing.
- Pressing `F` before Eye Piece recovery: do not change scenes.

## Testing

Automated tests verify:

1. Both outdoor scenes load and share the same declared world bounds.
2. Modern world has Eye Piece spawn points and ancient world has Nose Piece spawn points.
3. `F` cannot transition before Eye Piece recovery.
4. Eye Piece recovery enables the transition.
5. Transition changes the era while preserving or safely adjusting position.
6. Both example building entrances load an interior and return outdoors.
7. Nose Piece recovery still emits the portal payload.
8. Camera limits match the expanded world bounds.

Visual smoke testing verifies district spacing, travel routes, camera behavior, entrance placement, and whether the map feels meaningfully larger rather than merely emptier.

## Deferred Work

- Returning freely between eras
- More than two interior scenes
- Streaming or chunk activation for extremely dense final maps
- NPC schedules and crowds
- Vehicles, sprinting, fast travel, or minimap
- Final modern and historical environment art
- Full Eye Piece investigation puzzle chain
- Save/load persistence across application sessions

