# Hutik sa Katagman Dual-Era World Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the compact prototype arena with two large, geographically aligned Oton outdoor worlds, an Eye Piece-gated `F` transition into Katagman, and reusable enterable interiors.

**Architecture:** A persistent `GameRoot` owns the player, HUD, audio controller, artifacts, portal gateway, and story state. Modern, ancient, and interior scenes are loaded into a `WorldContainer` and expose a common `ExplorationWorld` interface for bounds, spawn markers, searchable props, and entrances.

**Tech Stack:** Godot 4.4, GDScript, `PackedScene` world loading, `CharacterBody2D`, `Area2D` interactions, signals, placeholder `Polygon2D` environments, and headless Godot integration tests.

---

## File Map

```text
scenes/gameplay/game_root.tscn                 Persistent runtime root
scenes/worlds/modern_oton_world.tscn           6400x4200 modern outdoor scene
scenes/worlds/ancient_katagman_world.tscn      6400x4200 ancient outdoor scene
scenes/interiors/modern_house_interior.tscn    Example present-day interior
scenes/interiors/ancient_kubo_interior.tscn    Example ancient interior
scenes/world/world_entrance.tscn               Reusable doorway interaction
scenes/world/world_exit.tscn                   Reusable interior exit
scripts/gameplay/game_root.gd                   Era, objective, and scene state
scripts/gameplay/game_state.gd                  Pure transition rules
scripts/world/exploration_world.gd              Common world interface
scripts/world/world_entrance.gd                 Interior request interaction
scripts/world/world_exit.gd                     Outdoor return interaction
scripts/world/placeholder_world_visual.gd       Era-specific map blockout drawing
scripts/artifact/artifact.gd                    Configurable Eye/Nose collectible
scripts/ui/hud.gd                               Era and transition feedback
tests/test_game_state.gd                        Eye Piece transition rules
tests/test_dual_world_contract.gd               World alignment and objective tests
tests/test_interior_flow.gd                     Entrance and return tests
```

### Task 1: Add Pure Dual-Era State Rules

**Files:**
- Create: `scripts/gameplay/game_state.gd`
- Create: `tests/test_game_state.gd`
- Modify: `tests/run_all_tests.gd`

- [ ] Write a failing test asserting the initial era is modern, transition is denied before Eye Piece recovery, Eye Piece recovery unlocks transition, and transition becomes one-way ancient.
- [ ] Run the headless suite and confirm failure because `game_state.gd` is missing.
- [ ] Implement `GameState` with `Era.MODERN`, `Era.ANCIENT`, `eye_piece_collected`, `nose_piece_collected`, `can_enter_past()`, `collect_eye_piece()`, and `enter_past()`.
- [ ] Rerun the suite and confirm the state test passes.

Required state API:

```gdscript
class_name GameState
extends RefCounted

enum Era { MODERN, ANCIENT }

var current_era := Era.MODERN
var eye_piece_collected := false
var nose_piece_collected := false

func can_enter_past() -> bool:
	return eye_piece_collected and current_era == Era.MODERN

func collect_eye_piece() -> void:
	eye_piece_collected = true

func enter_past() -> bool:
	if not can_enter_past():
		return false
	current_era = Era.ANCIENT
	return true
```

### Task 2: Define the Exploration World Contract

**Files:**
- Create: `scripts/world/exploration_world.gd`
- Create: `scripts/world/placeholder_world_visual.gd`
- Create: `tests/test_dual_world_contract.gd`
- Modify: `tests/run_all_tests.gd`

- [ ] Write a failing test loading both world scenes and asserting `world_bounds == Rect2(0, 0, 6400, 4200)`.
- [ ] Assert modern spawn points use group `eye_piece_spawn_points` and ancient points use `nose_piece_spawn_points`.
- [ ] Implement `ExplorationWorld` exports for `era_id`, `world_bounds`, `player_spawn_path`, and `safe_transition_spawn_path`.
- [ ] Implement helpers `get_player_spawn()`, `get_safe_transition_position()`, `get_artifact_spawn_points(group_name)`, and `clamp_to_world(position)`.
- [ ] Add `PlaceholderWorldVisual` drawing shared river geography, roads or paths, district clearings, and era-specific structures over a 6400x4200 area.

### Task 3: Build the Two Large Outdoor Worlds

**Files:**
- Create: `scenes/worlds/modern_oton_world.tscn`
- Create: `scenes/worlds/ancient_katagman_world.tscn`
- Create: `scenes/world/world_entrance.tscn`
- Create: `scripts/world/world_entrance.gd`

- [ ] Author matching shared anchors for central crossing, residential/domestic district, craft district, riverside district, market/commercial district, and burial geography.
- [ ] Add at least six modern Eye Piece spawn markers scattered across districts.
- [ ] Add at least six ancient Nose Piece spawn markers at corresponding but era-specific locations.
- [ ] Add three searchable props per world and link covered artifact spots to them.
- [ ] Add a modern-house entrance and ancient-kubo entrance at the same shared geographic landmark.
- [ ] Add collision boundaries covering the expanded world and river edge.
- [ ] Verify the dual-world contract test passes.

Required entrance API:

```gdscript
class_name WorldEntrance
extends Interactable

signal entrance_requested(entrance: WorldEntrance)

@export var entrance_id := ""
@export var interior_scene: PackedScene
@export var interior_spawn_id := "Entry"

func interact(_player: Node2D) -> void:
	if interior_scene:
		entrance_requested.emit(self)
```

### Task 4: Create Reusable Interior Flow

**Files:**
- Create: `scenes/interiors/modern_house_interior.tscn`
- Create: `scenes/interiors/ancient_kubo_interior.tscn`
- Create: `scenes/world/world_exit.tscn`
- Create: `scripts/world/world_exit.gd`
- Create: `tests/test_interior_flow.gd`

- [ ] Write a failing test asserting each outdoor entrance has a valid interior scene and each interior has `PlayerSpawn` and `WorldExit`.
- [ ] Implement `WorldExit` with signal `exit_requested` and `E` interaction.
- [ ] Build a 1280x900 modern house placeholder interior with room collision, searchable storage, spawn marker, and exit.
- [ ] Build a 1280x900 ancient kubo/workshop placeholder interior with matching contract.
- [ ] Run the test and verify both interiors load and expose required nodes.

Required exit API:

```gdscript
class_name WorldExit
extends Interactable

signal exit_requested

func interact(_player: Node2D) -> void:
	exit_requested.emit()
```

### Task 5: Generalize Artifact Collection

**Files:**
- Modify: `scripts/artifact/artifact.gd`
- Modify: `scenes/artifact/artifact.tscn`
- Modify: `tests/test_scene_contract.gd`

- [ ] Add configurable `artifact_name`, `component_name`, prompt, and placeholder color.
- [ ] Emit the same `collected` signal for Eye Piece and Nose Piece.
- [ ] Configure the collectible as Eye Piece in modern and Nose Piece in ancient through `GameRoot`, not duplicated scenes.
- [ ] Keep open and covered spawn behavior unchanged.

### Task 6: Replace MainGame with Persistent GameRoot

**Files:**
- Create: `scenes/gameplay/game_root.tscn`
- Create: `scripts/gameplay/game_root.gd`
- Modify: `project.godot`
- Retire from startup: `scenes/gameplay/main_game.tscn`

- [ ] Build `GameRoot` containing `WorldContainer`, persistent `Player`, `Artifact`, `EchoController`, `PortalGateway`, transition overlay, and HUD.
- [ ] On startup, load `modern_oton_world.tscn`, place the player at its `PlayerSpawn`, select an Eye Piece spawn, and begin modern echoes.
- [ ] Connect all searchable props and entrances after every world load.
- [ ] On Eye Piece collection, set state, stop current echoes, show `Press F to witness the past`, and retain control.
- [ ] On `F`, deny transition before collection; after collection fade, load ancient world, preserve and clamp the corresponding outdoor coordinate, configure the Nose Piece, update camera bounds, and start ancient echoes.
- [ ] On Nose Piece collection, call the existing portal gateway.

Core runtime methods:

```gdscript
func load_outdoor_world(scene: PackedScene, desired_position: Vector2) -> bool
func configure_current_artifact() -> void
func request_era_transition() -> void
func enter_interior(entrance: WorldEntrance) -> void
func return_to_outdoor() -> void
func connect_world_interactions() -> void
```

### Task 7: Expand HUD and Camera Behavior

**Files:**
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `scenes/player/player.tscn`
- Modify: `project.godot`

- [ ] Add `EraLabel`, `ObjectiveStatus`, `TransitionHint`, and full-screen `TransitionOverlay`.
- [ ] Add HUD methods `set_era()`, `set_objective()`, `show_transition_hint()`, `show_context_message()`, and `fade_transition()`.
- [ ] Map `era_transition` to physical key `F`.
- [ ] Expand camera limits dynamically from the current world's bounds instead of hardcoded 1280x720 values.
- [ ] Keep the viewport at 1280x720 while the world expands to 6400x4200.

### Task 8: End-to-End Integration and Visual Verification

**Files:**
- Modify: `tests/test_scene_contract.gd`
- Modify: `tools/capture_preview.gd`
- Modify: `README.md`
- Modify: `docs/ARCHITECTURE.md`

- [ ] Update scene tests to load `game_root.tscn`.
- [ ] Exercise modern Eye Piece reveal and collection, denied pre-collection transition, successful `F` transition, ancient Nose Piece collection, portal result, interior entry, and exterior return.
- [ ] Run the complete headless suite and a 30-frame game smoke test.
- [ ] Capture modern and ancient world previews at representative district coordinates.
- [ ] Open the updated project in Godot for visible inspection.
- [ ] Document the new world/interior asset replacement points and collaboration boundaries.

## Verification Commands

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --quit-after 30
```

Expected: both commands exit `0`; tests report successful modern collection, era transition, interior round-trip, ancient collection, and portal payload.

