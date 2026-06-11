# Layered Diorama Visual Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat procedural world blockout with a tested layered-diorama rendering architecture, approved camera framing, original painted player treatment, and matching modern/ancient residential showcase clusters.

**Architecture:** Each outdoor scene receives fixed background layers, a Y-sorted `DepthSortedWorld`, high roof/canopy overlays, and foreground framing. The persistent player and artifact are temporarily reparented into the active scene's actor layer so they sort naturally against buildings and vegetation, then detached before a scene is freed. Reusable environment scenes provide asset-ready foot origins, collision footprints, and split base/roof visuals.

**Tech Stack:** Godot 4.4, GDScript, `CanvasItem.y_sort_enabled`, `Camera2D`, custom `Node2D._draw()` blockout art, reusable PackedScenes, existing dual-era world loading, and headless integration tests.

---

## Scope

This plan delivers the first approved visual slice:

- Complete render-layer and Y-sort architecture in both outdoor worlds.
- Persistent actor reparenting across worlds and interiors.
- Wide-explorer outdoor camera and closer interior camera.
- Original painted blockout player with stable foot origin and contact shadow.
- One dense residential showcase cluster in Modern Oton.
- One compositionally matching residential showcase cluster in ancient Katagman.
- Foreground canopy framing and warm daylight palette.
- Updated preview captures and team asset guidance.

It does not create every final environment asset or populate all five districts with production artwork. Later art work must use the contracts established here.

## File Map

```text
scripts/world/exploration_world.gd                         Actor-layer and render-layer access
scripts/gameplay/game_root.gd                              Persistent actor reparenting and camera profiles
scripts/player/player.gd                                   Outdoor/interior camera profile API
scripts/player/painted_player_visual.gd                    Original wide-explorer character drawing
scripts/environment/depth_sorted_prop.gd                   Foot-origin environment contract
scripts/environment/residential_cluster_visual.gd          Era-specific painted cluster backdrop/details
scripts/environment/foreground_cluster_visual.gd           Non-colliding foreground framing
scenes/environment/shared/depth_sorted_prop.tscn            Reusable sortable prop scene
scenes/environment/shared/foreground_cluster.tscn           Reusable foreground scene
scenes/environment/modern/modern_house_exterior.tscn        Split modern house base/roof
scenes/environment/modern/modern_vegetation_cluster.tscn    Modern residential vegetation
scenes/environment/ancient/kubo_exterior.tscn               Split ancient kubo base/roof
scenes/environment/ancient/ancient_vegetation_cluster.tscn  Ancient residential vegetation
scenes/worlds/modern_oton_world.tscn                         Layer stack and modern showcase assembly
scenes/worlds/ancient_katagman_world.tscn                    Layer stack and ancient showcase assembly
scenes/interiors/modern_house_interior.tscn                  Interior actor layer and camera profile
scenes/interiors/ancient_kubo_interior.tscn                  Interior actor layer and camera profile
scenes/player/player.tscn                                    Painted visual and camera defaults
tests/test_diorama_world_contract.gd                         Layer and environment-scene contracts
tests/test_camera_profiles.gd                                Camera framing contract
tests/test_game_root_flow.gd                                 Reparenting and gameplay regression coverage
tests/test_interior_flow.gd                                  Recursive entrance and exit contracts
tests/run_all_tests.gd                                       Suite registration
tools/capture_preview.gd                                     Showcase and sorting captures
docs/ARCHITECTURE.md                                         Visual-layer and asset handoff documentation
README.md                                                    Current visual-slice description
```

### Task 1: Define the Diorama World Contract

**Files:**
- Create: `tests/test_diorama_world_contract.gd`
- Modify: `tests/run_all_tests.gd`
- Modify: `scripts/world/exploration_world.gd`
- Modify: `scenes/worlds/modern_oton_world.tscn`
- Modify: `scenes/worlds/ancient_katagman_world.tscn`
- Modify: `tests/test_interior_flow.gd`
- Modify: `tests/test_game_root_flow.gd`

- [ ] **Step 1: Write the failing layer-contract test**

Create `tests/test_diorama_world_contract.gd`:

```gdscript
extends RefCounted

const REQUIRED_LAYERS := [
	"FarBackground",
	"Ground",
	"GroundDetail",
	"DepthSortedWorld",
	"RoofAndCanopyOverlays",
	"NearForeground",
	"EraAtmosphere",
]

func run() -> bool:
	for path in [
		"res://scenes/worlds/modern_oton_world.tscn",
		"res://scenes/worlds/ancient_katagman_world.tscn",
	]:
		var scene := load(path) as PackedScene
		assert(scene != null)
		var world := scene.instantiate() as ExplorationWorld
		for layer_name in REQUIRED_LAYERS:
			assert(world.get_node_or_null(layer_name) != null)
		assert(world.get_actor_layer() == world.get_node("DepthSortedWorld"))
		assert(world.get_actor_layer().y_sort_enabled)
		assert(world.get_node("FarBackground").z_index < world.get_actor_layer().z_index)
		assert(world.get_node("NearForeground").z_index > world.get_actor_layer().z_index)
		world.free()
	return true
```

Register it before the asynchronous suites in `tests/run_all_tests.gd`:

```gdscript
preload("res://tests/test_diorama_world_contract.gd").new(),
```

- [ ] **Step 2: Run the suite and verify the intended failure**

Run:

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
```

Expected: failure because the required render-layer nodes and `get_actor_layer()` do not exist.

- [ ] **Step 3: Add the world API**

Add to `scripts/world/exploration_world.gd`:

```gdscript
@export var actor_layer_path := NodePath("DepthSortedWorld")

func get_actor_layer() -> Node2D:
	return get_node_or_null(actor_layer_path) as Node2D
```

- [ ] **Step 4: Replace each world root's visual structure**

In both outdoor scenes, remove the single `WorldVisual` instance and add this exact top-level structure:

```text
FarBackground         Node2D  z_index = -30
Ground                Node2D  z_index = -20
GroundDetail          Node2D  z_index = -10
DepthSortedWorld      Node2D  z_index = 0, y_sort_enabled = true
RoofAndCanopyOverlays Node2D  z_index = 20
NearForeground        Node2D  z_index = 40
EraAtmosphere         Node2D  z_index = 30
```

Move `SearchableProps` and `Entrances` under `DepthSortedWorld`. Preserve `ArtifactSpawnPoints`, `SharedAnchors`, `PlayerSpawn`, and `SafeTransitionSpawn` at the world root. Update every covered spawn's path, for example:

```ini
searchable_prop_path = NodePath("../../DepthSortedWorld/SearchableProps/FamilyStorage")
```

Update tests that inspect authored entrances. In `tests/test_interior_flow.gd` replace root-only lookups with:

```gdscript
var entrance_container := world.find_child("Entrances", true, false)
assert(entrance_container != null)
var entrances := entrance_container.get_children()
```

For interior exits use:

```gdscript
assert(interior.find_child("WorldExit", true, false) != null)
```

In `tests/test_game_root_flow.gd`, replace both direct entrance lookups with:

```gdscript
var entrance_container = game.current_world.find_child("Entrances", true, false)
var entrance = entrance_container.get_child(0)
```

Update `ExplorationWorld._ready()` to fail clearly when the actor layer is missing:

```gdscript
var actor_layer := get_actor_layer()
if actor_layer == null:
	push_error("%s requires a DepthSortedWorld actor layer." % name)
```

- [ ] **Step 5: Run the full suite**

Expected: the new contract passes and existing spawn, entrance, and artifact tests remain green.

- [ ] **Step 6: Commit**

```powershell
git add tests/test_diorama_world_contract.gd tests/run_all_tests.gd tests/test_interior_flow.gd tests/test_game_root_flow.gd scripts/world/exploration_world.gd scenes/worlds/modern_oton_world.tscn scenes/worlds/ancient_katagman_world.tscn
git commit -m "refactor: add layered diorama world contract"
```

### Task 2: Reparent Persistent Actors Into the Active Sort Layer

**Files:**
- Modify: `scripts/gameplay/game_root.gd`
- Modify: `tests/test_game_root_flow.gd`
- Modify: `scenes/interiors/modern_house_interior.tscn`
- Modify: `scenes/interiors/ancient_kubo_interior.tscn`

- [ ] **Step 1: Add failing actor-parent assertions**

In `tests/test_game_root_flow.gd`, after starting the game add:

```gdscript
assert(game.player.get_parent() == game.current_world.get_actor_layer())
assert(game.artifact.get_parent() == game.current_world.get_actor_layer())
```

After entering an interior add:

```gdscript
assert(game.player.get_parent() == game.current_content.get_node("DepthSortedWorld"))
assert(game.artifact.get_parent() == game.current_content.get_node("DepthSortedWorld"))
```

After returning outdoors add:

```gdscript
assert(game.player.get_parent() == game.current_world.get_actor_layer())
```

- [ ] **Step 2: Run the suite and verify failure**

Expected: the persistent nodes are still children of `GameRoot`.

- [ ] **Step 3: Add interior actor layers**

In both interior scenes add:

```ini
[node name="DepthSortedWorld" type="Node2D" parent="."]
y_sort_enabled = true
```

Move the interior searchable prop and `WorldExit` under `DepthSortedWorld`. Keep `PlayerSpawn` at the root and update runtime exit lookup to search recursively.

- [ ] **Step 4: Implement safe persistent-node reparenting**

Add these methods to `scripts/gameplay/game_root.gd`:

```gdscript
func _attach_persistent_actors(actor_layer: Node2D) -> void:
	if actor_layer == null:
		push_error("Current content has no actor layer.")
		return
	for actor in [player, artifact]:
		var saved_transform := actor.global_transform
		actor.reparent(actor_layer)
		actor.global_transform = saved_transform

func _detach_persistent_actors() -> void:
	for actor in [player, artifact]:
		if actor.get_parent() == self:
			continue
		var saved_transform := actor.global_transform
		actor.reparent(self)
		actor.global_transform = saved_transform
```

Call `_attach_persistent_actors(current_world.get_actor_layer())` immediately after adding an outdoor world. For interiors call:

```gdscript
_attach_persistent_actors(current_content.get_node("DepthSortedWorld") as Node2D)
```

Call `_detach_persistent_actors()` at the beginning of `_clear_current_content()` before removing and freeing the scene.

Change the exit lookup in `connect_world_interactions()` to:

```gdscript
var world_exit := current_content.find_child("WorldExit", true, false) as WorldExit
```

Find entrances recursively from the authored container:

```gdscript
var entrances := current_content.find_child("Entrances", true, false)
```

- [ ] **Step 5: Run the suite**

Expected: actors persist, reparent safely, and the full Eye Piece/interior/Nose Piece flow passes.

- [ ] **Step 6: Commit**

```powershell
git add scripts/gameplay/game_root.gd tests/test_game_root_flow.gd scenes/interiors/modern_house_interior.tscn scenes/interiors/ancient_kubo_interior.tscn
git commit -m "refactor: sort persistent actors within loaded scenes"
```

### Task 3: Add Outdoor and Interior Camera Profiles

**Files:**
- Create: `tests/test_camera_profiles.gd`
- Modify: `tests/run_all_tests.gd`
- Modify: `scripts/player/player.gd`
- Modify: `scenes/player/player.tscn`
- Modify: `scripts/gameplay/game_root.gd`

- [ ] **Step 1: Write the failing camera-profile test**

Create `tests/test_camera_profiles.gd`:

```gdscript
extends RefCounted

func run(tree: SceneTree) -> bool:
	var player_scene := load("res://scenes/player/player.tscn") as PackedScene
	var player := player_scene.instantiate() as PlayerController
	tree.root.add_child(player)
	await tree.process_frame

	player.apply_outdoor_camera_profile()
	assert(player.get_node("Camera2D").zoom == Vector2.ONE)
	assert(player.get_node("Camera2D").offset == Vector2(0, -72))
	assert(player.get_node("Camera2D").position_smoothing_speed == 6.0)

	player.apply_interior_camera_profile()
	assert(player.get_node("Camera2D").zoom == Vector2(1.35, 1.35))
	assert(player.get_node("Camera2D").offset == Vector2(0, -36))

	player.queue_free()
	await tree.process_frame
	return true
```

Register it as an asynchronous suite in `tests/run_all_tests.gd` before `test_scene_contract.gd`.

Use this exact runner block:

```gdscript
var camera_suite := preload("res://tests/test_camera_profiles.gd").new()
if not await camera_suite.run(self):
	quit(1)
	return
```

- [ ] **Step 2: Run the suite and verify failure**

Expected: `apply_outdoor_camera_profile()` is undefined.

- [ ] **Step 3: Implement the camera API**

Add to `scripts/player/player.gd`:

```gdscript
const OUTDOOR_CAMERA_ZOOM := Vector2.ONE
const OUTDOOR_CAMERA_OFFSET := Vector2(0, -72)
const INTERIOR_CAMERA_ZOOM := Vector2(1.35, 1.35)
const INTERIOR_CAMERA_OFFSET := Vector2(0, -36)

func apply_outdoor_camera_profile() -> void:
	_apply_camera_profile(OUTDOOR_CAMERA_ZOOM, OUTDOOR_CAMERA_OFFSET)

func apply_interior_camera_profile() -> void:
	_apply_camera_profile(INTERIOR_CAMERA_ZOOM, INTERIOR_CAMERA_OFFSET)

func _apply_camera_profile(target_zoom: Vector2, target_offset: Vector2) -> void:
	$Camera2D.zoom = target_zoom
	$Camera2D.offset = target_offset
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_speed = 6.0
```

Set subtle drag margins in `player.tscn`:

```ini
drag_horizontal_enabled = true
drag_vertical_enabled = true
drag_left_margin = 0.08
drag_top_margin = 0.08
drag_right_margin = 0.08
drag_bottom_margin = 0.08
```

- [ ] **Step 4: Apply profiles during scene loading**

In `GameRoot.load_outdoor_world()` call:

```gdscript
player.apply_outdoor_camera_profile()
```

In `GameRoot.enter_interior()` call:

```gdscript
player.apply_interior_camera_profile()
```

- [ ] **Step 5: Run the suite**

Expected: camera tests and all existing gameplay tests pass.

- [ ] **Step 6: Commit**

```powershell
git add tests/test_camera_profiles.gd tests/run_all_tests.gd scripts/player/player.gd scenes/player/player.tscn scripts/gameplay/game_root.gd
git commit -m "feat: add layered diorama camera profiles"
```

### Task 4: Create the Sortable Environment Scene Contracts

**Files:**
- Create: `scripts/environment/depth_sorted_prop.gd`
- Create: `scripts/environment/foreground_cluster_visual.gd`
- Create: `scenes/environment/shared/depth_sorted_prop.tscn`
- Create: `scenes/environment/shared/foreground_cluster.tscn`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Extend the failing contract test**

Add to `tests/test_diorama_world_contract.gd`:

```gdscript
var prop_scene := load("res://scenes/environment/shared/depth_sorted_prop.tscn") as PackedScene
assert(prop_scene != null)
var prop := prop_scene.instantiate()
assert(prop.has_meta("ground_contact_origin"))
assert(prop.get_node_or_null("ContactShadow") != null)
assert(prop.get_node_or_null("Visual") != null)
assert(prop.get_node_or_null("CollisionBody/CollisionShape2D") != null)
prop.free()

var foreground_scene := load("res://scenes/environment/shared/foreground_cluster.tscn") as PackedScene
assert(foreground_scene != null)
var foreground := foreground_scene.instantiate()
assert(foreground.get_node_or_null("CollisionShape2D") == null)
foreground.free()
```

- [ ] **Step 2: Run the suite and verify missing-scene failure**

- [ ] **Step 3: Implement the sortable prop script**

Create `scripts/environment/depth_sorted_prop.gd`:

```gdscript
class_name DepthSortedProp
extends Node2D

@export var prop_size := Vector2(120, 150)
@export var body_color := Color("#7b5835")
@export var accent_color := Color("#b88b4b")

func _ready() -> void:
	set_meta("ground_contact_origin", Vector2.ZERO)
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()
	var rect := Rect2(Vector2(-prop_size.x * 0.5, -prop_size.y), prop_size)
	draw_rect(rect, body_color)
	draw_line(rect.position, rect.end, accent_color, 5.0, true)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, prop_size.x * 0.36, Color(0.08, 0.1, 0.07, 0.42))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
```

The root position is the foot point. All visual drawing extends upward into negative Y.

- [ ] **Step 4: Create `depth_sorted_prop.tscn`**

Use this node contract:

```text
DepthSortedProp Node2D [depth_sorted_prop.gd]
|- ContactShadow Node2D
|- Visual Node2D
`- CollisionBody StaticBody2D
   `- CollisionShape2D
```

Use a `RectangleShape2D` sized `Vector2(76, 34)` and position the collision at `Vector2(0, -17)` so only the ground footprint blocks movement.

- [ ] **Step 5: Implement the non-colliding foreground scene**

Create `scripts/environment/foreground_cluster_visual.gd`:

```gdscript
class_name ForegroundClusterVisual
extends Node2D

@export var cluster_size := Vector2(520, 260)
@export var foliage_color := Color("#14261a")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	for offset in [Vector2(0, 80), Vector2(110, 15), Vector2(230, 70), Vector2(350, 5), Vector2(460, 75)]:
		draw_circle(offset, 105.0, foliage_color)
```

Create `foreground_cluster.tscn` with only a `Node2D` root using this script. Do not add collision.

- [ ] **Step 6: Run the suite and commit**

```powershell
git add scripts/environment scenes/environment/shared tests/test_diorama_world_contract.gd
git commit -m "feat: add reusable diorama environment contracts"
```

### Task 5: Build Matching Residential Showcase Scenes

**Files:**
- Create: `scripts/environment/residential_cluster_visual.gd`
- Create: `scenes/environment/modern/modern_house_exterior.tscn`
- Create: `scenes/environment/modern/modern_vegetation_cluster.tscn`
- Create: `scenes/environment/ancient/kubo_exterior.tscn`
- Create: `scenes/environment/ancient/ancient_vegetation_cluster.tscn`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Add failing residential-scene assertions**

Add:

```gdscript
for path in [
	"res://scenes/environment/modern/modern_house_exterior.tscn",
	"res://scenes/environment/ancient/kubo_exterior.tscn",
]:
	var scene := load(path) as PackedScene
	assert(scene != null)
	var building := scene.instantiate()
	assert(building.has_meta("ground_contact_origin"))
	assert(building.get_node_or_null("BaseVisual") != null)
	assert(building.get_node_or_null("RoofVisual") != null)
	assert(building.get_node_or_null("CollisionBody/CollisionShape2D") != null)
	building.free()
```

- [ ] **Step 2: Run and verify missing-scene failure**

- [ ] **Step 3: Implement the residential visual script**

Create `scripts/environment/residential_cluster_visual.gd`:

```gdscript
class_name ResidentialClusterVisual
extends Node2D

@export var modern := true
@export var draw_roof := false
@export var building_size := Vector2(250, 180)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if draw_roof:
		_draw_roof()
	else:
		_draw_base()

func _draw_base() -> void:
	var wall := Color("#c3b299") if modern else Color("#815b35")
	var outline := Color("#554638") if modern else Color("#49301d")
	var rect := Rect2(Vector2(-building_size.x * 0.5, -building_size.y), building_size)
	draw_rect(rect, wall)
	draw_polyline(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y), rect.position]), outline, 6.0, true)
	draw_rect(Rect2(Vector2(-30, -82), Vector2(60, 82)), Color("#38291f"))
	if not modern:
		draw_line(Vector2(-90, 0), Vector2(-90, 48), outline, 10.0, true)
		draw_line(Vector2(90, 0), Vector2(90, 48), outline, 10.0, true)

func _draw_roof() -> void:
	var roof := Color("#8c5848") if modern else Color("#b28a4b")
	var outline := Color("#55352c") if modern else Color("#5b421f")
	var points := PackedVector2Array([
		Vector2(-building_size.x * 0.62, -building_size.y),
		Vector2(0, -building_size.y * 1.45),
		Vector2(building_size.x * 0.62, -building_size.y),
	])
	draw_colored_polygon(points, roof)
	draw_polyline(points, outline, 7.0, true)
```

- [ ] **Step 4: Create split modern and ancient building scenes**

Each building scene uses a foot-origin root with metadata and separate base/roof children:

```text
BuildingRoot Node2D metadata/ground_contact_origin = Vector2(0, 0)
|- ContactShadow Polygon2D
|- BaseVisual Node2D [ResidentialClusterVisual draw_roof=false]
|- RoofVisual Node2D [ResidentialClusterVisual draw_roof=true] z_index=2
`- CollisionBody StaticBody2D
   `- CollisionShape2D
```

Modern dimensions: `Vector2(280, 180)`, footprint collision `Vector2(220, 48)` at `Vector2(0, -24)`.

Ancient dimensions: `Vector2(250, 165)`, footprint collision `Vector2(190, 42)` at `Vector2(0, -21)`. Keep the doorway approach open by using one horizontal wall footprint rather than a full-height collision.

- [ ] **Step 5: Create vegetation cluster scenes**

Create era-specific scenes inheriting the shared depth-sorted prop contract. Configure:

```text
modern_vegetation_cluster: prop_size Vector2(150, 170), body_color #35583e, accent #6d8b55
ancient_vegetation_cluster: prop_size Vector2(165, 185), body_color #24482f, accent #4f7144
```

- [ ] **Step 6: Run the suite and commit**

```powershell
git add scripts/environment/residential_cluster_visual.gd scenes/environment/modern scenes/environment/ancient tests/test_diorama_world_contract.gd
git commit -m "feat: add dual-era residential showcase assets"
```

### Task 6: Assemble the Modern and Ancient Showcase Clusters

**Files:**
- Modify: `scenes/worlds/modern_oton_world.tscn`
- Modify: `scenes/worlds/ancient_katagman_world.tscn`
- Create: `scripts/world/painted_world_ground.gd`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Add failing showcase assertions**

For each world assert:

```gdscript
var residential := world.get_node_or_null("DepthSortedWorld/ResidentialShowcase")
assert(residential != null)
assert(residential.get_child_count() >= 5)
assert(world.get_node("NearForeground").get_child_count() >= 2)
```

Assert corresponding composition roots match:

```gdscript
assert(modern.get_node("DepthSortedWorld/ResidentialShowcase").position == ancient.get_node("DepthSortedWorld/ResidentialShowcase").position)
```

- [ ] **Step 2: Run and verify failure**

- [ ] **Step 3: Implement the painted ground script**

Create `scripts/world/painted_world_ground.gd` with exports `modern` and `world_size`. Draw:

- Warm grass field.
- Shared river polygon.
- Wide antialiased route lines.
- Five irregular district clearing polygons.
- Repeated small ground-detail marks using a fixed seed so the visuals are deterministic.

Use the existing shared route coordinates and colors:

```gdscript
var grass := Color("#6f895d") if modern else Color("#587448")
var path := Color("#918b7d") if modern else Color("#b59a61")
var water := Color("#377d91") if modern else Color("#316d79")
```

The script replaces `PlaceholderWorldVisual`; it only owns ground and distant non-sorting scenery.

- [ ] **Step 4: Assemble Modern Oton residential cluster**

At shared residential position `Vector2(1300, 1050)`, add under `DepthSortedWorld/ResidentialShowcase`:

```text
PrimaryHouse         modern_house_exterior at (0, 0)
SecondaryHouse       modern_house_exterior at (-360, 190), scale 0.85
RoadsideVegetation   modern_vegetation_cluster at (260, 130)
GardenVegetation     modern_vegetation_cluster at (-240, -110), scale 0.8
FamilyStorage        existing searchable prop at (-130, 145)
ResidentialHouse     existing entrance at (150, 120)
```

Move the existing `FamilyStorage` and `ResidentialHouse` nodes into this cluster and update artifact paths accordingly.

Add two shared foreground-cluster instances under `NearForeground` near `Vector2(900, 1300)` and `Vector2(1550, 1450)`.

- [ ] **Step 5: Assemble ancient Katagman residential cluster**

At the same `Vector2(1300, 1050)` composition root:

```text
PrimaryKubo          kubo_exterior at (0, 0)
SecondaryKubo        kubo_exterior at (-360, 190), scale 0.85
DomesticVegetation   ancient_vegetation_cluster at (260, 130)
GardenVegetation     ancient_vegetation_cluster at (-240, -110), scale 0.8
WovenMat             existing searchable prop at (-130, 145)
ResidentialKubo      existing entrance at (150, 120)
```

Add matching but era-specific foreground vegetation at the same broad screen-framing positions.

- [ ] **Step 6: Ensure district routes and interactions remain reachable**

Run the game and use remote-scene collision visibility. Verify the approach from `PlayerSpawn` to the residential entrance remains at least 120 world units wide and no foreground node has collision.

- [ ] **Step 7: Run the full suite and commit**

```powershell
git add scripts/world/painted_world_ground.gd scenes/worlds tests/test_diorama_world_contract.gd
git commit -m "feat: assemble layered residential districts"
```

### Task 7: Replace the Player Block With an Original Painted Explorer

**Files:**
- Create: `scripts/player/painted_player_visual.gd`
- Modify: `scenes/player/player.tscn`
- Modify: `tests/test_camera_profiles.gd`

- [ ] **Step 1: Add failing player visual assertions**

Add to `tests/test_camera_profiles.gd`:

```gdscript
assert(player.get_node_or_null("ContactShadow") != null)
assert(player.get_node_or_null("PaintedVisual") != null)
assert(player.get_node("PaintedVisual").position.y < 0.0)
assert(player.get_node("CollisionShape2D").position.y <= -10.0)
```

- [ ] **Step 2: Run and verify failure**

- [ ] **Step 3: Implement the original player drawing**

Create `scripts/player/painted_player_visual.gd`:

```gdscript
class_name PaintedPlayerVisual
extends Node2D

var facing := Vector2.DOWN
var walk_phase := 0.0

func set_motion(direction: Vector2, speed: float, delta: float) -> void:
	if direction.length_squared() > 0.01:
		facing = direction.normalized()
		walk_phase += speed * delta * 0.035
	queue_redraw()

func _draw() -> void:
	var bob := sin(walk_phase) * 1.5
	var outline := Color("#322719")
	var coat := Color("#d5a94c")
	var cloth := Color("#426a64")
	draw_circle(Vector2(0, -40 + bob), 10.0, Color("#bb7e55"))
	draw_arc(Vector2(0, -40 + bob), 11.0, 0.0, TAU, 24, outline, 4.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -29 + bob), Vector2(12, -29 + bob),
		Vector2(16, -5 + bob), Vector2(-16, -5 + bob),
	]), coat)
	draw_polyline(PackedVector2Array([
		Vector2(-12, -29 + bob), Vector2(12, -29 + bob),
		Vector2(16, -5 + bob), Vector2(-16, -5 + bob), Vector2(-12, -29 + bob),
	]), outline, 4.0, true)
	draw_rect(Rect2(Vector2(-7, -22 + bob), Vector2(14, 13)), cloth)
```

This drawing is an original researcher/apprentice silhouette and must not reproduce any reference character.

- [ ] **Step 4: Update `player.tscn`**

Remove `PlaceholderVisual` and `DirectionMarker`. Add:

```text
ContactShadow Polygon2D at y = -2, flattened ellipse, translucent dark green
PaintedVisual Node2D at y = 0 [painted_player_visual.gd]
CollisionShape2D at y = -13
InteractionDetector at y = -18
```

Keep the root position as the player's foot point.

- [ ] **Step 5: Drive the visual from movement**

In `PlayerController._physics_process(delta)` call:

```gdscript
$PaintedVisual.set_motion(direction, velocity.length(), delta)
```

When input is disabled, call with `Vector2.ZERO` so idle still redraws correctly.

- [ ] **Step 6: Run tests and commit**

```powershell
git add scripts/player/painted_player_visual.gd scenes/player/player.tscn scripts/player/player.gd tests/test_camera_profiles.gd
git commit -m "style: add original painted explorer blockout"
```

### Task 8: Visual Capture, Documentation, and Regression Verification

**Files:**
- Modify: `tools/capture_preview.gd`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `README.md`
- Create: `docs/modern-residential-diorama-preview.png`
- Create: `docs/ancient-residential-diorama-preview.png`
- Create: `docs/diorama-depth-sorting-preview.png`

- [ ] **Step 1: Update the preview tool**

Capture the player at the shared residential coordinate in both eras:

```gdscript
game.player.global_position = Vector2(1300, 1240)
await _settle_camera()
_save_frame("res://docs/modern-residential-diorama-preview.png")

game.state.collect_eye_piece()
game.request_era_transition()
game.player.global_position = Vector2(1300, 1240)
await _settle_camera()
_save_frame("res://docs/ancient-residential-diorama-preview.png")
```

For sorting proof, capture the player once above and once below `PrimaryKubo`, composing the two images into a single preview only if the existing image toolchain is available; otherwise save two clearly named PNG files.

- [ ] **Step 2: Update architecture documentation**

Document:

- Required outdoor layer names and Z values.
- Foot-origin rule for all sortable scenes.
- Persistent actor reparenting lifecycle.
- Base/roof split for buildings.
- Foreground scenes are non-colliding.
- Final art replacement process and required asset metadata.

- [ ] **Step 3: Update README**

Describe the current slice honestly as a layered painted blockout with one showcase district per era. Do not describe all districts as production-complete.

- [ ] **Step 4: Run fresh verification**

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --quit-after 30
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --path . --script res://tools/capture_preview.gd
git diff --check
```

Expected:

- All automated tests pass.
- Startup smoke test exits `0`.
- Preview tool writes the modern and ancient residential captures.
- No script or parser errors appear in the Godot log.
- `git diff --check` produces no output.

- [ ] **Step 5: Visually inspect the captures**

Confirm:

1. At least four visible depth planes: ground, actors/props, roofs/canopies, near foreground.
2. Character is approximately 48-56 screen pixels tall outdoors.
3. Modern and ancient residential screenshots show matching geography.
4. Warm daylight keeps all routes and interactive objects readable.
5. No foreground element permanently hides an entrance or searchable prop.

- [ ] **Step 6: Commit and push**

```powershell
git add README.md docs/ARCHITECTURE.md docs/*diorama*.png tools/capture_preview.gd
git commit -m "docs: document layered diorama asset workflow"
git push origin main
```

## Final Verification Checklist

- [ ] Both worlds expose the approved layer stack.
- [ ] Player and artifact sort inside the active scene.
- [ ] Scene unloading never frees persistent actors.
- [ ] Outdoor and interior camera profiles match the approved framing.
- [ ] Player root and environment roots use foot-based origins.
- [ ] Modern and ancient residential clusters share composition coordinates.
- [ ] Foreground framing has no collision.
- [ ] Existing Eye Piece, `F` transition, interiors, Nose Piece, minimap, `M`, and `F11` behavior remains green.
- [ ] Preview screenshots read as illustrated scenes rather than flat diagrams.
