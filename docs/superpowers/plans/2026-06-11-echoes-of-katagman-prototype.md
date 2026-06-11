# Hutik sa Katagman Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a replayable Godot 4.4 top-down prototype in which the player follows distance-reactive Cultural Echo audio, searches environmental props, recovers the Oton Gold Death Mask Nose Piece, and triggers a replaceable portal/API event.

**Architecture:** A `MainGame` scene owns round state and coordinates reusable player, artifact, searchable-prop, spawn-point, echo, HUD, and portal components through signals. The hackathon build uses placeholder visuals and optional placeholder audio while keeping the organizer integration isolated behind one gateway method.

**Tech Stack:** Godot 4.4, GDScript, Godot input actions, `CharacterBody2D`, `Area2D`, `TileMapLayer`, `AudioStreamPlayer`, signals, and headless Godot smoke tests.

---

## Prototype Boundary

Implement one reconstructed-Katagman search level. Introduce the Eye Piece and archaeological-vision premise with brief text, then place the player directly into the search round. Do not implement the museum archive chapter, educational puzzle chapters, final museum, real network request, or ending sequence in this prototype.

## File Map

```text
res://
|- project.godot                         Input actions and startup scene
|- scenes/
|  |- main_game.tscn                    Playable vertical slice
|  |- player/player.tscn                Movement and interaction detector
|  |- artifact/artifact.tscn            Collectible Nose Piece
|  |- world/searchable_prop.tscn         Reusable searchable cover/container
|  |- world/artifact_spawn_point.tscn    Authored hiding-place metadata
|  `- ui/hud.tscn                        Prompts, intro, portal status, restart
|- scripts/
|  |- game_round.gd                      Round orchestration
|  |- player.gd                          Movement and nearest interaction
|  |- interactable.gd                    Shared interaction contract
|  |- artifact.gd                        Reveal and collection state
|  |- searchable_prop.gd                 Open/search/reset behavior
|  |- artifact_spawn_point.gd            Hiding-place configuration
|  |- echo_controller.gd                 Distance-to-audio mapping
|  |- portal_gateway.gd                  Future API replacement boundary
|  `- hud.gd                             Plain prototype UI behavior
`- tests/
   |- run_all_tests.gd                   Headless test entry point
   |- test_echo_math.gd                  Audio proximity tests
   `- test_discovery_payload.gd          Portal payload tests
```

## Recommended Authored Hiding Spots

Use six `ArtifactSpawnPoint` instances in the prototype map:

1. `Goldsmith Worktable` - open, artifact visible.
2. `Beneath the Woven Sleeping Mat` - covered by a searchable mat.
3. `Pottery Storage Shelf` - open, partly obscured by pots.
4. `Wooden Storage Chest` - covered and opened with `E`.
5. `Riverside Trading Basket` - covered and searched with `E`.
6. `Burial Preparation Alcove` - open but visually secluded.

These are stylized prototype locations. Final environmental details should be checked by the team's historical adviser or source material before presentation as fact.

### Task 1: Configure the Project Shell

**Files:**
- Modify: `project.godot`
- Create: `scenes/main_game.tscn`
- Create: `scripts/game_round.gd`

- [ ] **Step 1: Add input actions in the Godot editor**

Create these actions under **Project > Project Settings > Input Map**:

```text
move_up: W, Up Arrow
move_down: S, Down Arrow
move_left: A, Left Arrow
move_right: D, Right Arrow
interact: E
restart_round: R
```

- [ ] **Step 2: Create the main scene skeleton**

Create `scenes/main_game.tscn` with this node structure:

```text
MainGame (Node2D)
|- World (Node2D)
|  |- Ground (TileMapLayer)
|  |- Obstacles (TileMapLayer)
|  |- Props (Node2D)
|  |- SpawnPoints (Node2D)
|  `- EchoController (Node)
|- PortalGateway (Node)
`- HUD (CanvasLayer)
```

Attach `scripts/game_round.gd` to `MainGame` and set this scene as the project's main scene.

- [ ] **Step 3: Add a startup guard**

Begin `scripts/game_round.gd` with explicit state and an empty setup method:

```gdscript
extends Node2D

var selected_spawn_point: ArtifactSpawnPoint
var previous_spawn_point: ArtifactSpawnPoint
var selected_location_name := ""
var artifact_collected := false
var round_number := 0

func _ready() -> void:
	call_deferred("start_round")

func start_round() -> void:
	round_number += 1
```

- [ ] **Step 4: Run the empty shell**

Run: `godot --path . --editor` and press **F6** on `main_game.tscn`.

Expected: the scene opens without parser errors, even though gameplay is not added yet.

### Task 2: Build Top-Down Player Movement

**Files:**
- Create: `scenes/player/player.tscn`
- Create: `scripts/player.gd`
- Modify: `scenes/main_game.tscn`

- [ ] **Step 1: Create the player nodes**

Use this structure:

```text
Player (CharacterBody2D)
|- PlaceholderVisual (Polygon2D)
|- CollisionShape2D
|- InteractionDetector (Area2D)
|  `- CollisionShape2D
`- Camera2D
```

Use a small colored polygon or the existing icon as the temporary visual. Give the body a capsule or rectangle collision shape. Give `InteractionDetector` a circular shape slightly larger than the body.

- [ ] **Step 2: Implement movement**

Create `scripts/player.gd`:

```gdscript
class_name Player
extends CharacterBody2D

@export var move_speed := 180.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = direction * move_speed
	move_and_slide()
```

- [ ] **Step 3: Instance and test the player**

Add `player.tscn` beneath `World` in `main_game.tscn`. Add temporary `StaticBody2D` walls around the play area.

Expected: WASD and arrow keys move smoothly, diagonal speed is normalized, and the player cannot cross the walls.

### Task 3: Define the Interaction Contract

**Files:**
- Create: `scripts/interactable.gd`
- Modify: `scripts/player.gd`

- [ ] **Step 1: Create the base interactable type**

Create `scripts/interactable.gd`:

```gdscript
class_name Interactable
extends Area2D

@export var interaction_prompt := "Press E to interact."
var interaction_enabled := true

func get_interaction_prompt() -> String:
	return interaction_prompt if interaction_enabled else ""

func interact(_player: Player) -> void:
	pass
```

- [ ] **Step 2: Track nearby interactables in the player**

Add to `scripts/player.gd`:

```gdscript
signal interaction_prompt_changed(prompt: String)

var nearby_interactables: Array[Interactable] = []
var current_interactable: Interactable

func _ready() -> void:
	$InteractionDetector.area_entered.connect(_on_interaction_area_entered)
	$InteractionDetector.area_exited.connect(_on_interaction_area_exited)

func _process(_delta: float) -> void:
	_refresh_current_interactable()
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact(self)

func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.append(area)

func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)

func _refresh_current_interactable() -> void:
	nearby_interactables = nearby_interactables.filter(
		func(item: Interactable) -> bool:
			return is_instance_valid(item) and item.interaction_enabled
	)
	nearby_interactables.sort_custom(
		func(a: Interactable, b: Interactable) -> bool:
			return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	var next_interactable: Interactable = nearby_interactables.front() if not nearby_interactables.is_empty() else null
	if next_interactable == current_interactable:
		return
	current_interactable = next_interactable
	interaction_prompt_changed.emit(
		current_interactable.get_interaction_prompt() if current_interactable else ""
	)
```

- [ ] **Step 3: Verify overlapping interactions**

Place two temporary `Interactable` areas near one another.

Expected: the player selects the closest enabled area and clears the prompt after leaving both.

### Task 4: Add Searchable Environmental Props

**Files:**
- Create: `scenes/world/searchable_prop.tscn`
- Create: `scripts/searchable_prop.gd`
- Modify: `scenes/main_game.tscn`

- [ ] **Step 1: Create the reusable searchable prop**

Use an `Interactable` root so the player's detector can discover it:

```text
SearchableProp (Interactable/Area2D)
|- ClosedVisual (Polygon2D)
|- OpenVisual (Polygon2D)
|- CollisionShape2D
|- Blocker (StaticBody2D, optional)
|  `- CollisionShape2D
`- RevealPoint (Marker2D)
```

Set the player's `InteractionDetector` collision mask to the layer used by interactables. Use the optional `Blocker` for props that the player must walk around.

- [ ] **Step 2: Implement search and reset behavior**

Create `scripts/searchable_prop.gd`:

```gdscript
class_name SearchableProp
extends Interactable

signal searched(prop: SearchableProp)

@export var prop_name := "container"
var is_open := false

func _ready() -> void:
	reset_prop()

func interact(_player: Player) -> void:
	if is_open:
		return
	is_open = true
	interaction_enabled = false
	$ClosedVisual.visible = false
	$OpenVisual.visible = true
	searched.emit(self)

func reset_prop() -> void:
	is_open = false
	interaction_enabled = true
	interaction_prompt = "Press E to search the %s." % prop_name
	$ClosedVisual.visible = true
	$OpenVisual.visible = false
```

- [ ] **Step 3: Author three covered locations**

Instance searchable props for the woven sleeping mat, storage chest, and trading basket. Use different placeholder colors and names so testing is unambiguous.

Expected: each prop opens once, changes visual state, and cannot be repeatedly searched until reset.

### Task 5: Add Spawn-Point Metadata and Random Selection

**Files:**
- Create: `scenes/world/artifact_spawn_point.tscn`
- Create: `scripts/artifact_spawn_point.gd`
- Modify: `scenes/main_game.tscn`
- Modify: `scripts/game_round.gd`

- [ ] **Step 1: Define spawn-point data**

Create `scripts/artifact_spawn_point.gd`:

```gdscript
class_name ArtifactSpawnPoint
extends Marker2D

@export var location_name := "Unnamed Katagman Location"
@export var searchable_prop_path: NodePath

func get_searchable_prop() -> SearchableProp:
	if searchable_prop_path.is_empty():
		return null
	return get_node_or_null(searchable_prop_path) as SearchableProp
```

Add the root to the `artifact_spawn_points` group in `artifact_spawn_point.tscn`.

- [ ] **Step 2: Place all six spawn points**

Set each `location_name` to the names in the Recommended Authored Hiding Spots section. Assign `searchable_prop_path` only to the mat, chest, and basket points.

- [ ] **Step 3: Select a random point while avoiding immediate repetition**

Add to `scripts/game_round.gd`:

```gdscript
func _choose_spawn_point() -> ArtifactSpawnPoint:
	var points: Array[ArtifactSpawnPoint] = []
	for node in get_tree().get_nodes_in_group("artifact_spawn_points"):
		if node is ArtifactSpawnPoint:
			points.append(node)

	if points.is_empty():
		push_error("No artifact spawn points exist in main_game.tscn.")
		return null

	var candidates := points.filter(
		func(point: ArtifactSpawnPoint) -> bool:
			return point != previous_spawn_point
	)
	if candidates.is_empty():
		candidates = points

	return candidates.pick_random()
```

- [ ] **Step 4: Seed and store the selection**

Extend `start_round()`:

```gdscript
func start_round() -> void:
	round_number += 1
	artifact_collected = false
	selected_spawn_point = _choose_spawn_point()
	if selected_spawn_point == null:
		return
	previous_spawn_point = selected_spawn_point
	selected_location_name = selected_spawn_point.location_name
	print("Round %d selected: %s" % [round_number, selected_location_name])
```

Expected: repeated restarts print different adjacent selections when at least two points exist.

### Task 6: Build Artifact Reveal and Collection

**Files:**
- Create: `scenes/artifact/artifact.tscn`
- Create: `scripts/artifact.gd`
- Modify: `scenes/main_game.tscn`
- Modify: `scripts/game_round.gd`

- [ ] **Step 1: Create the artifact scene**

Use this structure:

```text
Artifact (Interactable/Area2D)
|- PlaceholderVisual (Polygon2D)
`- CollisionShape2D
```

- [ ] **Step 2: Implement artifact state**

Create `scripts/artifact.gd`:

```gdscript
class_name Artifact
extends Interactable

signal collected(artifact: Artifact)

@export var artifact_name := "Oton Gold Death Mask"
@export var component_name := "Nose Piece"
var is_collected := false

func prepare_for_round(spawn_point: ArtifactSpawnPoint) -> void:
	global_position = spawn_point.global_position
	is_collected = false
	interaction_enabled = false
	visible = false
	interaction_prompt = "Press E to recover the Nose Piece."
	if spawn_point.get_searchable_prop() == null:
		reveal_at(spawn_point.global_position)

func reveal_at(reveal_position: Vector2) -> void:
	if is_collected:
		return
	global_position = reveal_position
	visible = true
	interaction_enabled = true

func interact(_player: Player) -> void:
	if is_collected or not interaction_enabled:
		return
	is_collected = true
	interaction_enabled = false
	visible = false
	collected.emit(self)
```

- [ ] **Step 3: Connect selected props to artifact reveal**

Add references and setup to `scripts/game_round.gd`:

```gdscript
@onready var artifact: Artifact = $World/Artifact

func _ready() -> void:
	artifact.collected.connect(_on_artifact_collected)
	for node in get_tree().get_nodes_in_group("searchable_props"):
		if node is SearchableProp:
			node.searched.connect(_on_prop_searched)
	call_deferred("start_round")

func _on_prop_searched(prop: SearchableProp) -> void:
	if selected_spawn_point == null:
		return
	if selected_spawn_point.get_searchable_prop() == prop:
		artifact.reveal_at(prop.get_node("RevealPoint").global_position)

func _on_artifact_collected(_artifact: Artifact) -> void:
	artifact_collected = true
```

Add every searchable prop root to the `searchable_props` group.

- [ ] **Step 4: Prepare and reset all round objects**

Before configuring the artifact in `start_round()`:

```gdscript
for node in get_tree().get_nodes_in_group("searchable_props"):
	if node is SearchableProp:
		node.reset_prop()
artifact.prepare_for_round(selected_spawn_point)
```

Expected: open spots display the artifact immediately; covered spots reveal it only after the correct prop is searched; `E` collects it once.

### Task 7: Implement Cultural Echo Audio Logic

**Files:**
- Create: `scripts/echo_controller.gd`
- Create: `tests/test_echo_math.gd`
- Modify: `scenes/main_game.tscn`

- [ ] **Step 1: Write the distance-mapping test**

Create `tests/test_echo_math.gd`:

```gdscript
extends RefCounted

func run() -> void:
	assert(is_equal_approx(EchoController.proximity_from_distance(900.0, 90.0, 900.0), 0.0))
	assert(is_equal_approx(EchoController.proximity_from_distance(90.0, 90.0, 900.0), 1.0))
	var middle := EchoController.proximity_from_distance(495.0, 90.0, 900.0)
	assert(middle > 0.0 and middle < 1.0)
```

- [ ] **Step 2: Implement the controller and pure proximity function**

Create `scripts/echo_controller.gd`:

```gdscript
class_name EchoController
extends Node

@export var maximum_echo_distance := 900.0
@export var full_volume_distance := 90.0
@export var silent_volume_db := -36.0
@export var loud_volume_db := -2.0

@onready var nature_echo: AudioStreamPlayer = $NatureEcho
@onready var activity_echo: AudioStreamPlayer = $ActivityEcho
@onready var music_echo: AudioStreamPlayer = $MusicEcho
@onready var voice_echo: AudioStreamPlayer = $VoiceEcho

var player: Player
var target: Node2D
var active := false
var echo_players: Array[AudioStreamPlayer]

func _ready() -> void:
	echo_players = [nature_echo, activity_echo, music_echo, voice_echo]

static func proximity_from_distance(distance: float, near_distance: float, far_distance: float) -> float:
	if far_distance <= near_distance:
		return 1.0 if distance <= near_distance else 0.0
	return 1.0 - clamp(inverse_lerp(near_distance, far_distance, distance), 0.0, 1.0)

func begin(searching_player: Player, target_node: Node2D) -> void:
	player = searching_player
	target = target_node
	active = true
	for echo_player in echo_players:
		if echo_player.stream:
			echo_player.play()

func stop() -> void:
	active = false
	for echo_player in echo_players:
		echo_player.stop()

func _process(_delta: float) -> void:
	if not active or not is_instance_valid(player) or not is_instance_valid(target):
		return
	var distance := player.global_position.distance_to(target.global_position)
	var proximity := proximity_from_distance(distance, full_volume_distance, maximum_echo_distance)
	for echo_player in echo_players:
		echo_player.volume_db = lerp(silent_volume_db, loud_volume_db, proximity)
```

- [ ] **Step 3: Add placeholder audio slots**

Under `World/EchoController`, add:

```text
EchoController (Node)
|- NatureEcho (AudioStreamPlayer)
|- ActivityEcho (AudioStreamPlayer)
|- MusicEcho (AudioStreamPlayer)
`- VoiceEcho (AudioStreamPlayer)
```

Leave streams empty until the team supplies audio, or assign neutral test tones. The intended future content is nature ambience, craft or settlement activity, restrained music, and historically reviewed dialect or voice material. Missing streams must not break distance logic.

- [ ] **Step 4: Start and stop the echo from the round manager**

Add these cached references to `scripts/game_round.gd`:

```gdscript
@onready var player: Player = $World/Player
@onready var echo_controller: EchoController = $World/EchoController
```

Call this at the end of `start_round()` after the artifact has been prepared:

```gdscript
echo_controller.begin(player, selected_spawn_point)
```

Call this in `_on_artifact_collected()`:

```gdscript
echo_controller.stop()
```

Expected: the placeholder Cultural Echo becomes louder toward the chosen spot and stops after collection. No label reports whether the player is hot or cold.

### Task 8: Add the Portal/API Replacement Boundary

**Files:**
- Create: `scripts/portal_gateway.gd`
- Create: `tests/test_discovery_payload.gd`
- Modify: `scripts/game_round.gd`
- Modify: `scenes/main_game.tscn`

- [ ] **Step 1: Write the payload test**

Create `tests/test_discovery_payload.gd`:

```gdscript
extends RefCounted

func run() -> void:
	var payload := PortalGateway.build_discovery_payload("Player_001", "Wooden Storage Chest")
	assert(payload["player_id"] == "Player_001")
	assert(payload["artifact_name"] == "Oton Gold Death Mask")
	assert(payload["artifact_component"] == "Nose Piece")
	assert(payload["discovered_location"] == "Wooden Storage Chest")
	assert(payload["status"] == "found")
```

- [ ] **Step 2: Implement the gateway**

Create `scripts/portal_gateway.gd`:

```gdscript
class_name PortalGateway
extends Node

signal portal_unlock_requested(payload: Dictionary)
signal portal_result_received(success: bool, message: String, payload: Dictionary)

static func build_discovery_payload(player_id: String, location_name: String) -> Dictionary:
	return {
		"player_id": player_id,
		"artifact_name": "Oton Gold Death Mask",
		"artifact_component": "Nose Piece",
		"discovered_location": location_name,
		"status": "found"
	}

func trigger_portal_unlock_placeholder(payload: Dictionary) -> void:
	portal_unlock_requested.emit(payload)
	print("Portal Unlock Event Triggered: ", JSON.stringify(payload))
	portal_result_received.emit(
		true,
		"PORTAL UNLOCKED\nOton Gold Death Mask Collection Restored.\nWaiting for organizer API integration.",
		payload
	)
```

- [ ] **Step 3: Trigger the gateway after collection**

Extend `_on_artifact_collected()` in `scripts/game_round.gd`:

```gdscript
@onready var portal_gateway: PortalGateway = $PortalGateway

func _on_artifact_collected(_artifact: Artifact) -> void:
	artifact_collected = true
	echo_controller.stop()
	var payload := PortalGateway.build_discovery_payload(
		"Player_001",
		selected_location_name
	)
	portal_gateway.trigger_portal_unlock_placeholder(payload)
```

Expected: collecting the Nose Piece prints valid JSON-compatible discovery data and emits a simulated success event. No network request occurs.

### Task 9: Build the Minimal Prototype HUD

**Files:**
- Create: `scenes/ui/hud.tscn`
- Create: `scripts/hud.gd`
- Modify: `scenes/main_game.tscn`
- Modify: `scripts/game_round.gd`

- [ ] **Step 1: Create functional UI nodes**

Use this structure:

```text
HUD (CanvasLayer)
|- IntroPanel (PanelContainer)
|  |- IntroText (Label)
|  `- BeginButton (Button)
|- InteractionPrompt (Label)
`- PortalPanel (PanelContainer)
   |- PortalMessage (Label)
   `- RestartButton (Button)
```

Use plain controls and default theme styling. The intro copy should briefly state that the Eye Piece has initiated an evidence-based reconstruction of Katagman and that the player is looking for the missing Nose Piece.

- [ ] **Step 2: Implement HUD signals**

Create `scripts/hud.gd`:

```gdscript
class_name PrototypeHUD
extends CanvasLayer

signal begin_requested
signal restart_requested

func _ready() -> void:
	$IntroPanel/BeginButton.pressed.connect(_on_begin_pressed)
	$PortalPanel/RestartButton.pressed.connect(func(): restart_requested.emit())
	show_interaction_prompt("")
	hide_portal_result()

func _on_begin_pressed() -> void:
	$IntroPanel.visible = false
	begin_requested.emit()

func show_interaction_prompt(prompt: String) -> void:
	$InteractionPrompt.text = prompt
	$InteractionPrompt.visible = not prompt.is_empty()

func show_portal_result(message: String, payload: Dictionary) -> void:
	$PortalPanel/PortalMessage.text = "%s\n\nFound Location: %s\nStatus: Ready to send to organizer portal." % [
		message,
		payload.get("discovered_location", "Unknown")
	]
	$PortalPanel.visible = true

func hide_portal_result() -> void:
	$PortalPanel.visible = false
```

- [ ] **Step 3: Connect player, portal, and restart events**

In `scripts/game_round.gd`:

```gdscript
@onready var hud: PrototypeHUD = $HUD

func _ready() -> void:
	player.interaction_prompt_changed.connect(hud.show_interaction_prompt)
	portal_gateway.portal_result_received.connect(_on_portal_result_received)
	hud.begin_requested.connect(start_round)
	hud.restart_requested.connect(start_round)
	artifact.collected.connect(_on_artifact_collected)
	for node in get_tree().get_nodes_in_group("searchable_props"):
		if node is SearchableProp:
			node.searched.connect(_on_prop_searched)

func _on_portal_result_received(success: bool, message: String, payload: Dictionary) -> void:
	if success:
		hud.show_portal_result(message, payload)
```

At this stage, remove the earlier `call_deferred("start_round")` line from `_ready()`. The first round starts when the player dismisses the introduction.

- [ ] **Step 4: Clear UI on restart**

At the top of `start_round()`, call:

```gdscript
hud.hide_portal_result()
hud.show_interaction_prompt("")
```

Expected: prompts appear only near interactables, collection shows the portal placeholder, and Restart Round clears it.

### Task 10: Assemble the Placeholder Katagman Map

**Files:**
- Modify: `scenes/main_game.tscn`

- [ ] **Step 1: Block out a compact exploration route**

Use plain TileMap cells, polygons, or colored sprites to create:

```text
central settlement clearing
goldsmith work area
domestic sleeping area
pottery storage area
riverside trading edge
burial preparation edge
connecting foliage-lined paths
```

- [ ] **Step 2: Add collision boundaries**

Place collisions on water, dense vegetation, walls, and large props. Keep every hiding spot reachable without precision movement.

- [ ] **Step 3: Check camera and layering**

Enable the player's `Camera2D`. Use simple `z_index` values or Y-sorting so the player can pass visually behind tall props. Do not spend prototype time on shaders, final lighting, or detailed animation.

- [ ] **Step 4: Validate every hiding spot manually**

Temporarily force each spawn point in `start_round()` one at a time.

Expected: all six spots are reachable; three are immediately visible; three reveal after searching the correct prop; the artifact is never placed inside collision geometry.

### Task 11: Add Headless Logic Tests

**Files:**
- Create: `tests/run_all_tests.gd`
- Modify: `tests/test_echo_math.gd`
- Modify: `tests/test_discovery_payload.gd`

- [ ] **Step 1: Create the test runner**

Create `tests/run_all_tests.gd`:

```gdscript
extends SceneTree

func _init() -> void:
	var suites := [
		load("res://tests/test_echo_math.gd").new(),
		load("res://tests/test_discovery_payload.gd").new()
	]
	for suite in suites:
		suite.run()
	print("All Hutik sa Katagman logic tests passed.")
	quit(0)
```

- [ ] **Step 2: Run the tests**

Run from the project root:

```powershell
godot --headless --path . --script res://tests/run_all_tests.gd
```

Expected: `All Hutik sa Katagman logic tests passed.` and exit code `0`.

- [ ] **Step 3: Confirm parser safety without optional audio**

Clear all four echo streams and rerun the test command and game.

Expected: no crash or invalid call occurs when placeholder audio is absent.

### Task 12: Complete the Hackathon Smoke Test

**Files:**
- Modify only files needed to fix failures found during this task

- [ ] **Step 1: Test keyboard controls**

Verify `WASD`, arrow keys, `E`, and the restart button. Verify diagonal movement is not faster than horizontal movement.

- [ ] **Step 2: Test six consecutive rounds**

Record the selected location printed for each round.

Expected: the artifact does not use the immediately previous spawn when multiple choices exist, and both open and covered spots appear during the sequence.

- [ ] **Step 3: Test clue integrity**

Walk toward and away from the selected spot without looking at the debug output.

Expected: audio intensity communicates proximity; no objective arrow, textual hot/cold clue, or visible marker exposes the selected spawn point.

- [ ] **Step 4: Test collection and payload**

Collect the Nose Piece from an open spot and a covered spot.

Expected payload shape:

```json
{
  "player_id": "Player_001",
  "artifact_name": "Oton Gold Death Mask",
  "artifact_component": "Nose Piece",
  "discovered_location": "<selected authored location name>",
  "status": "found"
}
```

- [ ] **Step 5: Test complete reset**

After collection, click Restart Round.

Expected: portal panel hides, props close, artifact state resets, Cultural Echo restarts at the new target, and the new artifact can be collected exactly once.

- [ ] **Step 6: Run final automated verification**

```powershell
godot --headless --path . --script res://tests/run_all_tests.gd
```

Expected: all tests pass with exit code `0`.

## Organizer API Integration Point

When the organizer supplies the actual contract, replace only the body of `PortalGateway.trigger_portal_unlock_placeholder()` or add a second implementation called by that method. Keep `game_round.gd`, artifact collection, and HUD independent of HTTP details.

Before integration, obtain:

```text
endpoint URL
HTTP method
authentication requirements
required request fields
success and error response formats
timeout and retry rules
privacy requirements for player identifiers
portal deep-link or unlock callback behavior
```

Do not guess these values or commit credentials into the Godot project.
