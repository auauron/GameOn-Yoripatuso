# Hutik sa Katagman Prototype Design

## Purpose

Build a small Godot 4.4 top-down exploration prototype for the hackathon. The prototype demonstrates a replayable search for the Oton Gold Death Mask, audio-led Cultural Echo clues, environmental interaction, artifact recovery, and a replaceable portal/API event.

The canonical full-game proposal is `docs/HUTIK-SA-KATAGMAN-GAME-DESIGN-PROPOSAL.md`. This document covers only its hackathon vertical slice.

This is a vertical slice, not the complete game. Final artwork, UI, music, voice recordings, sound effects, museum content, and the organizer's API remain outside this build.

## Historical and Narrative Frame

The full game begins with a young archaeologist cataloguing material connected to the 1967 Oton excavation. An overlooked gold Eye Piece triggers an immersive archaeological reconstruction of Katagman in the late 14th to early 15th centuries. The reconstruction is formed from evidence, field records, interpretation, and sensory impressions; the game does not present it as literal time travel or verified supernatural history.

The prototype starts after the Eye Piece has been identified. A short text introduction explains that the player is entering a reconstruction to locate the missing Nose Piece and better understand the Oton Gold Death Mask assemblage.

The playable area is a stylized top-down reconstruction of ancient Katagman. Its atmosphere may draw inspiration from the supplied references through dense foliage, layered scenery, restrained lighting, and environmental storytelling, but it must not copy their art, characters, or map layouts.

All historical writing must distinguish established facts from interpretation. Phrases such as "believed to," "may have," and "the reconstruction suggests" should be used for uncertain meanings or practices.

## Full-Game Vision

The supplied final concept remains the long-term direction:

1. Explore present-day museum archives.
2. Solve catalog and excavation puzzles.
3. Identify the Eye Piece.
4. Enter reconstructed scenes of ancient Katagman.
5. Learn about trade, goldworking, and burial practice through puzzles.
6. Recover the Nose Piece.
7. Restore the digital record and unlock the organizer's museum portal.
8. End with the archaeological record still open to further interpretation.

The hackathon prototype implements only one complete search round inside the reconstructed Katagman environment. The other chapters are documented future work and must not block the prototype.

## Prototype Player Experience

The player enters a compact settlement area and explores using `WASD` or the arrow keys. The hidden target is randomly assigned to one of several authored hiding spots each round.

Some hiding spots are open, such as a worktable or a partially exposed space beneath a woven sleeping mat. Other spots use searchable covers or containers, such as a wooden chest, storage basket, or pottery storage area. These props use an `E` interaction to open or move them. If the selected hiding spot belongs to that prop, the Nose Piece becomes visible.

There is no waypoint, objective arrow, minimap marker, or distance clue text. Cultural Echo audio is the search language:

- Far: ordinary environmental ambience dominates.
- Approaching: a cultural layer becomes audible, such as distant waves, pottery handling, goldsmith hammering, or marketplace activity.
- Near: the selected echo is clear and louder.
- Interaction range: the player sees only the contextual prompt needed to inspect the prop or collect the artifact.

Actual cultural recordings and dialect performances will be supplied and reviewed later. The prototype provides labelled audio slots and may use neutral placeholder tones for testing.

## Core Loop

`Start round -> choose hiding spot -> explore -> follow Cultural Echo audio -> inspect cover if required -> see Nose Piece -> press E -> prepare discovery data -> trigger portal placeholder -> restart with a new random hiding spot`

## Recommended Architecture

Use small reusable scenes and signals rather than one large script.

### Main Game Scene

```text
MainGame (Node2D) [game_round.gd]
|- World (Node2D)
|  |- Ground (TileMapLayer)
|  |- Obstacles (TileMapLayer)
|  |- Props (Node2D)
|  |- SpawnPoints (Node2D)
|  |- Player (CharacterBody2D instance)
|  |- Artifact (Area2D instance)
|  `- EchoController (Node)
|- PortalGateway (Node) [portal_gateway.gd]
`- HUD (CanvasLayer instance)
```

### Player Scene

```text
Player (CharacterBody2D) [player.gd]
|- PlaceholderVisual (Polygon2D or Sprite2D)
|- CollisionShape2D
|- InteractionDetector (Area2D)
|  `- CollisionShape2D
`- Camera2D
```

### Artifact Scene

```text
Artifact (Area2D) [artifact.gd]
|- PlaceholderVisual (Polygon2D or Sprite2D)
`- CollisionShape2D
```

### Searchable Prop Scene

```text
SearchableProp (Interactable/Area2D) [searchable_prop.gd]
|- ClosedVisual (Polygon2D or Sprite2D)
|- OpenVisual (Polygon2D or Sprite2D)
|- CollisionShape2D
|- Blocker (StaticBody2D, optional)
|  `- CollisionShape2D
`- RevealPoint (Marker2D)
```

The optional `Blocker` supplies physical collision for large props while the `Area2D` root handles interaction detection.

### Spawn Point Scene

```text
ArtifactSpawnPoint (Marker2D) [artifact_spawn_point.gd]
```

Each spawn point stores a human-readable location name and an optional path to a searchable prop. Open spots reveal the artifact immediately. Covered spots keep it hidden until their prop emits `searched`.

### HUD Scene

```text
HUD (CanvasLayer) [hud.gd]
|- InteractionPrompt (Label)
|- PortalPanel (PanelContainer)
|  `- PortalMessage (Label)
`- RestartButton (Button)
```

The HUD remains functional and plain. It is not the final interface or museum design.

## Script Responsibilities

### `player.gd`

- Read top-down movement actions.
- Move with `move_and_slide()`.
- Track nearby interactable objects.
- Choose the closest valid interactable.
- Call its `interact()` method when the player presses `E`.
- Emit a signal when the current interaction prompt changes.

### `artifact_spawn_point.gd`

- Store `location_name`.
- Store an optional `searchable_prop_path`.
- Report whether the spot is open or covered.
- Expose the world position where the artifact should appear.

### `searchable_prop.gd`

- Store prompt text such as "Press E to search the wooden chest."
- Change from closed to opened only once per round.
- Emit `searched` when interacted with.
- Reset to the closed state on restart.
- Reveal the artifact only when this prop owns the selected spawn point.

### `artifact.gd`

- Store artifact name and component name.
- Start each round uncollected.
- Remain visible at open spots and hidden at covered spots.
- Return the collection prompt while available.
- Emit `collected` after an `E` interaction.
- Disable repeat collection after discovery.

### `echo_controller.gd`

- Receive the player and selected spawn point.
- Calculate distance from the player to the selected spot.
- Convert distance to a normalized proximity value.
- Control placeholder audio volume and optional layer transitions.
- Stop Cultural Echo playback after collection.
- Avoid textual hot/cold clues.

### `game_round.gd`

- Find all nodes in the `artifact_spawn_points` group.
- Randomly select one spawn point at round start.
- Store `selected_location_name`.
- Reset all searchable props.
- Position and configure the artifact.
- Connect artifact, echo, HUD, and portal events.
- Build discovery data after collection.
- Restart the round without reloading the whole project.

### `portal_gateway.gd`

- Accept a discovery dictionary through one public method.
- Emit a local `portal_unlock_requested` signal.
- Print the payload for development.
- Return a simulated success result to the HUD.
- Contain the single replacement point for the organizer's future API integration.

### `hud.gd`

- Display or hide contextual interaction prompts.
- Display the temporary portal result.
- Emit `restart_requested` when the button is pressed.
- Avoid lore-heavy panels or final museum layouts.

## Important Data

```gdscript
var selected_spawn_point: ArtifactSpawnPoint
var selected_location_name: String = ""
var artifact_collected: bool = false
var round_number: int = 0

var discovery_data := {
    "player_id": "Player_001",
    "artifact_name": "Oton Gold Death Mask",
    "artifact_component": "Nose Piece",
    "discovered_location": "",
    "status": "found"
}
```

Spawn point exports:

```gdscript
@export var location_name: String
@export var searchable_prop_path: NodePath
```

Echo tuning exports:

```gdscript
@export var maximum_echo_distance: float = 900.0
@export var full_volume_distance: float = 90.0
@export var silent_volume_db: float = -36.0
@export var loud_volume_db: float = -2.0
```

The echo controller exposes separate optional slots for natural ambience, human activity or craft sounds, music, and historically reviewed voice or dialect recordings. All slots use the same proximity value, leaving the final mix and cultural recordings to the team's asset workflow.

## Data and Signal Flow

1. `game_round.gd` selects a spawn point and configures the artifact and echo controller.
2. `player.gd` moves and updates the nearest interactable.
3. `echo_controller.gd` continuously maps player distance to audio intensity.
4. A searched prop emits `searched`; `game_round.gd` reveals the artifact when that prop owns the selected location.
5. The artifact emits `collected` after the player interacts with it.
6. `game_round.gd` stops the echo, builds discovery data, and calls `portal_gateway.gd`.
7. `portal_gateway.gd` emits the simulated result for the HUD.
8. The restart button asks `game_round.gd` to reset every round-owned object and choose again.

## Basic Pseudocode

```text
start_round:
    increment round number
    clear collected state and portal message
    reset every searchable prop
    select one random spawn point
    remember its location name
    move artifact to spawn point
    if spawn point has a searchable prop:
        hide artifact
        wait for that prop to be searched
    else:
        show artifact
    start echo controller at selected spawn point

every frame:
    move player from four-direction input
    measure distance to selected spawn point
    make Cultural Echo audio clearer/louder as distance decreases
    show an interaction prompt only for the nearest usable object

on prop searched:
    if prop owns selected spawn point:
        show artifact at reveal point

on artifact collected:
    mark collected
    hide artifact
    stop echo audio
    build discovery data
    trigger portal unlock placeholder
    show simple success panel

restart_round:
    hide success panel
    reset props and artifact
    choose another random spawn point when possible
    begin searching again
```

## Failure and Edge Cases

- If no spawn points exist, the round must stop and print a clear editor error instead of crashing.
- A searched empty prop remains open but does not reveal the artifact.
- Pressing `E` near overlapping objects uses the closest enabled interactable.
- The artifact cannot be collected twice.
- Restart clears old signal state, prompts, audio, opened props, and portal data.
- When at least two spawn points exist, restart should avoid the immediately previous point where practical.
- Missing audio streams must not prevent the game from running.
- Future API failure must leave the collected state intact and show a retry-ready status rather than respawning the artifact.

## Verification Criteria

The prototype is successful when:

1. The player moves smoothly in four directions and collides with the map.
2. At least six named hiding spots are available.
3. The selected hiding spot changes across repeated rounds.
4. Open and covered hiding spots both work.
5. Cultural Echo audio intensity responds continuously to distance.
6. No textual distance clues or objective markers reveal the location.
7. `E` opens searchable props and collects a revealed artifact.
8. Collection produces the correct discovery dictionary and simulated portal event.
9. Restart resets the full round and chooses another location when possible.
10. The prototype runs without final art, audio, backend, or museum assets.

## Deferred Work

- Playable museum archive chapter
- Catalog, pottery, excavation-note, trade-route, goldsmith, and burial protocol puzzles
- Final character animation, environment art, lighting, UI, and accessibility design
- Historically reviewed Hiligaynon or other language recordings
- Final music and soundscape
- Organizer API authentication, networking, retries, and privacy requirements
- Organizer-provided Digital Museum interface
- Full ending and unresolved-record sequence
