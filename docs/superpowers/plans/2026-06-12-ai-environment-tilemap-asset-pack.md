# AI Environment TileMap Asset Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a consistent ChatGPT-generated environment asset pack and integrate it into complete modern and ancient Godot TileMaps while preserving shared geography, exploration systems, entrances, artifact hiding, and depth sorting.

**Architecture:** A manifest-driven asset pipeline keeps prompts, generated source images, normalized game-ready images, atlases, and Godot `TileSet` resources synchronized. A deterministic `EnvironmentTileLayout` populates identical ground, river, and route cells in both eras while swapping era-specific artwork. Large buildings, trees, boats, props, searchable objects, and entrances remain depth-sorted scene instances rather than TileMap cells.

**Tech Stack:** Godot 4.4, GDScript, `TileMapLayer`, `TileSet`, `TileSetAtlasSource`, JSON manifests, ChatGPT built-in image generation, local chroma-key removal for transparent objects, PNG/WebP assets, and existing headless Godot integration tests.

---

## Scope and Delivery Stages

This plan produces the complete environment framework and asset inventory in three stages:

1. **Asset pipeline:** prompt library, manifest, validation, normalization, atlas building, and generated artwork.
2. **Shared TileMap geography:** grass, earth, paths, water, riverbanks, transitions, and ground details across the entire `6400 x 4200` world.
3. **District population:** residential, craft, market, riverside, and burial geography in both eras using generated buildings, vegetation, boats, props, atmosphere, and foreground art.

The TileMap grid is `128 x 128`. The world occupies 50 columns and 33 rows; the final row extends beyond `world_bounds.y = 4200` and is clipped by the camera and world collision boundary.

## File Map

```text
docs/art-prompts/environment/style-lock.md                    Shared visual and negative prompt
docs/art-prompts/environment/01-shared-terrain.md             Grass, earth, sand, mud, water prompts
docs/art-prompts/environment/02-terrain-transitions.md         Banks, edges, corners, and route prompts
docs/art-prompts/environment/03-shared-vegetation.md           Trees, palms, bushes, reeds, rocks
docs/art-prompts/environment/04-modern-buildings.md            Houses, pavilion, modular parts
docs/art-prompts/environment/05-modern-props.md                Modern boats, utilities, furniture, props
docs/art-prompts/environment/06-ancient-buildings.md           Kubo, workshop, modular parts
docs/art-prompts/environment/07-ancient-props.md               Boats, pottery, baskets, work props
docs/art-prompts/environment/08-atmosphere.md                  Mist, glows, shadows, particles, foreground
assets/art/environment/manifest.json                           Required files, dimensions, atlas positions
assets/art/environment/shared/...                              Shared game-ready assets
assets/art/environment/modern/...                              Modern game-ready assets
assets/art/environment/ancient/...                             Ancient game-ready assets
tools/environment_assets/validate_assets.gd                    Dimension, alpha, and inventory validation
tools/environment_assets/process_chroma_assets.ps1             Batch transparent-background removal
tools/environment_assets/assemble_atlases.gd                   Deterministic atlas composition
tools/environment_assets/build_tilesets.gd                     Godot TileSet resource generation
resources/tilesets/shared_ground_tileset.tres                  Shared base, water, and bank atlas
resources/tilesets/modern_detail_tileset.tres                  Modern route and ground-detail atlas
resources/tilesets/ancient_detail_tileset.tres                 Ancient route and ground-detail atlas
scripts/world/environment_tile_catalog.gd                      Stable atlas-coordinate constants
scripts/world/environment_tile_layout.gd                       Shared cell geometry and TileMap population
scenes/environment/shared/world_tile_layers.tscn               Reusable TileMapLayer assembly
scenes/environment/shared/tropical_tree.tscn                   Split base/canopy tree scene
scenes/environment/shared/environment_prop.tscn                Generic foot-origin sprite prop
scenes/environment/modern/*.tscn                               Generated modern structures and props
scenes/environment/ancient/*.tscn                              Generated ancient structures and props
scenes/worlds/modern_oton_world.tscn                            TileMaps and five modern districts
scenes/worlds/ancient_katagman_world.tscn                      Matching TileMaps and five ancient districts
tests/test_environment_asset_manifest.gd                       Pipeline inventory contract
tests/test_environment_tile_layout.gd                          Shared geography and layer contract
tests/test_diorama_world_contract.gd                           Updated object and district contracts
tools/capture_preview.gd                                       Full-map and district visual captures
docs/ARCHITECTURE.md                                           Asset replacement and TileMap workflow
assets/README.md                                               Team drop-zone instructions
```

### Task 1: Define the Environment Asset Manifest Contract

**Files:**
- Create: `assets/art/environment/manifest.json`
- Create: `tests/test_environment_asset_manifest.gd`
- Modify: `tests/run_all_tests.gd`

- [ ] **Step 1: Write the failing manifest test**

Create `tests/test_environment_asset_manifest.gd`:

```gdscript
extends RefCounted

const MANIFEST_PATH := "res://assets/art/environment/manifest.json"
const REQUIRED_ATLASES := ["shared_ground", "modern_detail", "ancient_detail"]
const REQUIRED_CATEGORIES := [
	"shared_terrain", "shared_vegetation", "modern_terrain", "modern_buildings",
	"modern_props", "ancient_terrain", "ancient_buildings", "ancient_props",
	"atmosphere",
]

func run() -> bool:
	assert(FileAccess.file_exists(MANIFEST_PATH))
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var manifest = JSON.parse_string(file.get_as_text())
	assert(manifest is Dictionary)
	assert(manifest.tile_size == 128)
	assert(manifest.source_tile_size == 512)
	for atlas_name in REQUIRED_ATLASES:
		assert(manifest.atlases.has(atlas_name))
		assert(manifest.atlases[atlas_name].resource.ends_with(".tres"))
	for category in REQUIRED_CATEGORIES:
		assert(manifest.required_assets.has(category))
		assert(not manifest.required_assets[category].is_empty())
	return true
```

Register it in `tests/run_all_tests.gd`:

```gdscript
preload("res://tests/test_environment_asset_manifest.gd").new(),
```

- [ ] **Step 2: Run the suite and verify failure**

Run:

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
```

Expected: failure because `manifest.json` does not exist.

- [ ] **Step 3: Create the manifest**

Create `assets/art/environment/manifest.json` with this top-level structure:

```json
{
  "tile_size": 128,
  "source_tile_size": 512,
  "world_grid": { "columns": 50, "rows": 33 },
  "atlases": {
    "shared_ground": {
      "image": "res://assets/art/environment/shared/terrain/shared_ground_atlas.png",
      "resource": "res://resources/tilesets/shared_ground_tileset.tres",
      "columns": 8,
      "rows": 4
    },
    "modern_detail": {
      "image": "res://assets/art/environment/modern/terrain/modern_detail_atlas.png",
      "resource": "res://resources/tilesets/modern_detail_tileset.tres",
      "columns": 8,
      "rows": 2
    },
    "ancient_detail": {
      "image": "res://assets/art/environment/ancient/terrain/ancient_detail_atlas.png",
      "resource": "res://resources/tilesets/ancient_detail_tileset.tres",
      "columns": 8,
      "rows": 2
    }
  },
  "required_assets": {
    "shared_terrain": [
      "shared_grass_01.png", "shared_grass_damp_01.png", "shared_earth_01.png",
      "shared_sand_01.png", "shared_mud_01.png", "shared_water_01.png",
      "shared_water_shadow_01.png", "shared_bank_n.png", "shared_bank_e.png",
      "shared_bank_s.png", "shared_bank_w.png", "shared_bank_ne.png",
      "shared_bank_se.png", "shared_bank_sw.png", "shared_bank_nw.png",
      "shared_grass_earth_n.png", "shared_grass_earth_e.png",
      "shared_grass_earth_s.png", "shared_grass_earth_w.png",
      "shared_grass_earth_inner_ne.png", "shared_grass_earth_inner_se.png",
      "shared_grass_earth_inner_sw.png", "shared_grass_earth_inner_nw.png",
      "shared_grass_earth_outer_ne.png", "shared_grass_earth_outer_se.png",
      "shared_grass_earth_outer_sw.png", "shared_grass_earth_outer_nw.png"
    ],
    "shared_vegetation": [
      "shared_coconut_palm_base_01.png", "shared_coconut_palm_canopy_01.png",
      "shared_broadleaf_tree_base_01.png", "shared_broadleaf_tree_canopy_01.png",
      "shared_mangrove_base_01.png", "shared_mangrove_canopy_01.png",
      "shared_bush_dense_01.png", "shared_bush_light_01.png", "shared_reeds_01.png"
    ],
    "modern_terrain": [
      "modern_route_01.png", "modern_route_damp_01.png", "modern_route_n.png",
      "modern_route_e.png", "modern_route_s.png", "modern_route_w.png",
      "modern_route_inner_ne.png", "modern_route_inner_se.png",
      "modern_route_inner_sw.png", "modern_route_inner_nw.png",
      "modern_route_outer_ne.png", "modern_route_outer_se.png",
      "modern_route_outer_sw.png", "modern_route_outer_nw.png"
    ],
    "modern_buildings": [
      "modern_house_concrete_01_base.png", "modern_house_concrete_01_roof.png",
      "modern_house_timber_01_base.png", "modern_house_timber_01_roof.png",
      "modern_pavilion_01_base.png", "modern_pavilion_01_roof.png",
      "modern_module_wall_concrete_01.png", "modern_module_wall_timber_01.png",
      "modern_module_roof_galvanized_01.png", "modern_module_door_01.png",
      "modern_module_window_01.png", "modern_module_steps_01.png",
      "modern_module_fence_01.png", "modern_module_awning_01.png"
    ],
    "modern_props": [
      "modern_boat_01.png", "modern_utility_pole_01.png", "modern_bench_01.png",
      "modern_storage_cabinet_01.png", "modern_worktable_01.png", "modern_garden_pot_01.png"
    ],
    "ancient_terrain": [
      "ancient_route_01.png", "ancient_route_damp_01.png", "ancient_route_n.png",
      "ancient_route_e.png", "ancient_route_s.png", "ancient_route_w.png",
      "ancient_route_inner_ne.png", "ancient_route_inner_se.png",
      "ancient_route_inner_sw.png", "ancient_route_inner_nw.png",
      "ancient_route_outer_ne.png", "ancient_route_outer_se.png",
      "ancient_route_outer_sw.png", "ancient_route_outer_nw.png"
    ],
    "ancient_buildings": [
      "ancient_kubo_01_base.png", "ancient_kubo_01_roof.png",
      "ancient_kubo_02_base.png", "ancient_kubo_02_roof.png",
      "ancient_workshop_01_base.png", "ancient_workshop_01_roof.png",
      "ancient_module_wall_bamboo_01.png", "ancient_module_wall_woven_01.png",
      "ancient_module_roof_nipa_01.png", "ancient_module_door_01.png",
      "ancient_module_window_01.png", "ancient_module_stilts_01.png",
      "ancient_module_ladder_01.png", "ancient_module_railing_01.png"
    ],
    "ancient_props": [
      "ancient_trade_boat_01.png", "ancient_dugout_01.png", "ancient_pottery_01.png",
      "ancient_basket_01.png", "ancient_woven_mat_01.png", "ancient_worktable_01.png"
    ],
    "atmosphere": [
      "shared_mist_strip_01.png", "shared_light_glow_01.png", "shared_smoke_01.png",
      "shared_foreground_leaves_01.png", "shared_contact_shadow_01.png"
    ]
  }
}
```

- [ ] **Step 4: Run tests and commit**

```powershell
git add assets/art/environment/manifest.json tests/test_environment_asset_manifest.gd tests/run_all_tests.gd
git commit -m "test: define environment asset manifest contract"
```

### Task 2: Create the ChatGPT Prompt Production Kit

**Files:**
- Create: `docs/art-prompts/environment/style-lock.md`
- Create: `docs/art-prompts/environment/01-shared-terrain.md`
- Create: `docs/art-prompts/environment/02-terrain-transitions.md`
- Create: `docs/art-prompts/environment/03-shared-vegetation.md`
- Create: `docs/art-prompts/environment/04-modern-buildings.md`
- Create: `docs/art-prompts/environment/05-modern-props.md`
- Create: `docs/art-prompts/environment/06-ancient-buildings.md`
- Create: `docs/art-prompts/environment/07-ancient-props.md`
- Create: `docs/art-prompts/environment/08-atmosphere.md`
- Modify: `tests/test_environment_asset_manifest.gd`

- [ ] **Step 1: Extend the failing test to require all prompt files**

Add:

```gdscript
for prompt_name in [
	"style-lock.md", "01-shared-terrain.md", "02-terrain-transitions.md",
	"03-shared-vegetation.md", "04-modern-buildings.md", "05-modern-props.md",
	"06-ancient-buildings.md", "07-ancient-props.md", "08-atmosphere.md",
]:
	assert(FileAccess.file_exists("res://docs/art-prompts/environment/%s" % prompt_name))
```

- [ ] **Step 2: Run and verify missing-file failure**

- [ ] **Step 3: Write `style-lock.md`**

Write this exact reusable core:

```text
Create original 2D environment art for a narrative exploration game set in Oton, Iloilo, Philippines. Use a smooth hand-painted storybook style with bold irregular dark-brown ink contours, watercolor and gouache-like texture, gently stylized proportions, readable silhouettes, and mysterious humid late-afternoon light approaching dusk. Use a high three-quarter diorama viewing angle with visible roof planes and ground footprints. Keep the art painterly and high resolution, never pixel art. Maintain muted tropical greens, blue-green shadows, warm earth, aged wood, nipa straw, river teal, and restrained amber light. Do not imitate or reproduce any existing game's exact artwork, characters, compositions, or designs.

Modern Oton variation: use modest concrete, timber, galvanized metal, local garden plants, drainage, utility details, and contemporary river-community objects. Keep the setting mysterious and natural rather than futuristic, urban, glossy, or photorealistic.

Ancient Katagman variation: use a historically grounded 14th-15th century Panay material culture. Make it slightly darker and more dreamlike than the modern era, with deeper blue-green shadows, stronger humid mist, subdued gold highlights, wood, bamboo, nipa, woven panels, pottery, baskets, and river craft. Exclude concrete, electricity, plastics, asphalt, European medieval architecture, fantasy ruins, gothic decoration, and magical effects.

Negative constraints: no pixel art, low-resolution edges, isometric diamond grid, side-view platformer angle, front elevation only, photorealism, 3D render, anime style, text, labels, UI, watermark, white border, checkerboard background, clipped cast shadows, duplicated objects, or unrelated scenery. Preserve camera angle, scale, palette, ink weight, and upper-left light direction.
```

- [ ] **Step 4: Write the eight exact batch prompt files**

Each file must contain copy-ready prompts using this exact structure:

```text
Use case: illustration-story
Asset type: 2D Godot environment asset
Primary request: generate the filenames listed for this batch in assets/art/environment/manifest.json, preserving one consistent scale reference across the entire batch
Style/medium: smooth hand-painted storybook watercolor and gouache with bold irregular dark-brown ink contours
Composition/framing: high three-quarter diorama view; bottom-center ground contact for objects
Lighting/mood: humid late afternoon approaching dusk; light from upper-left
Constraints: preserve the shared style lock; generate only the manifest-listed items for this batch; keep every item fully inside the canvas; consistent scale; no text; no watermark
Avoid: pixel art, photorealism, 3D render, isometric diamond view, side view, fantasy medieval imagery
```

Terrain prompt files require perfectly seamless edges and no directional cast shadow. Object prompt files require a flat `#ff00ff` chroma-key background because tropical vegetation contains green.

- [ ] **Step 5: Run tests and commit**

```powershell
git add docs/art-prompts/environment tests/test_environment_asset_manifest.gd
git commit -m "docs: add chatgpt environment asset prompts"
```

### Task 3: Generate, Extract, and Validate the Complete Asset Inventory

**Files:**
- Create: `tools/environment_assets/validate_assets.gd`
- Create: `tools/environment_assets/process_chroma_assets.ps1`
- Create: all manifest-listed PNG files under `assets/art/environment/`
- Modify: `assets/art/environment/manifest.json`

- [ ] **Step 1: Create the asset validator**

Create `tools/environment_assets/validate_assets.gd`:

```gdscript
extends SceneTree

const MANIFEST_PATH := "res://assets/art/environment/manifest.json"

func _init() -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var manifest: Dictionary = JSON.parse_string(file.get_as_text())
	var missing: Array[String] = []
	for category in manifest.required_assets:
		var folder := _folder_for(category)
		for filename in manifest.required_assets[category]:
			var path := "%s/%s" % [folder, filename]
			if not FileAccess.file_exists(path):
				missing.append(path)
				continue
			var image := Image.load_from_file(ProjectSettings.globalize_path(path))
			if image.is_empty():
				push_error("Unreadable image: %s" % path)
				quit(1)
				return
			if not category.contains("terrain") and not image.detect_alpha():
				push_error("Object asset requires alpha: %s" % path)
				quit(1)
				return
	if not missing.is_empty():
		push_error("Missing environment assets:\n%s" % "\n".join(missing))
		quit(1)
		return
	print("Environment asset inventory is complete.")
	quit(0)

func _folder_for(category: String) -> String:
	var folders := {
		"shared_terrain": "res://assets/art/environment/shared/terrain",
		"shared_vegetation": "res://assets/art/environment/shared/vegetation",
		"modern_terrain": "res://assets/art/environment/modern/terrain",
		"modern_buildings": "res://assets/art/environment/modern/buildings",
		"modern_props": "res://assets/art/environment/modern/props",
		"ancient_terrain": "res://assets/art/environment/ancient/terrain",
		"ancient_buildings": "res://assets/art/environment/ancient/buildings",
		"ancient_props": "res://assets/art/environment/ancient/props",
		"atmosphere": "res://assets/art/environment/shared/atmosphere",
	}
	return folders[category]
```

- [ ] **Step 2: Run the validator and verify the inventory failure**

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tools/environment_assets/validate_assets.gd
```

Expected: a complete list of missing manifest assets.

- [ ] **Step 3: Create the manifest-driven chroma processor**

Create `tools/environment_assets/process_chroma_assets.ps1`:

```powershell
param(
    [string]$InputDir = ".asset-staging/chroma"
)

$ErrorActionPreference = "Stop"
$manifest = Get-Content "assets/art/environment/manifest.json" -Raw | ConvertFrom-Json
$helper = Join-Path $env:USERPROFILE ".codex/skills/.system/imagegen/scripts/remove_chroma_key.py"
$folders = @{
    shared_vegetation = "assets/art/environment/shared/vegetation"
    modern_buildings = "assets/art/environment/modern/buildings"
    modern_props = "assets/art/environment/modern/props"
    ancient_buildings = "assets/art/environment/ancient/buildings"
    ancient_props = "assets/art/environment/ancient/props"
    atmosphere = "assets/art/environment/shared/atmosphere"
}

foreach ($category in $folders.Keys) {
    $outputDir = $folders[$category]
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    foreach ($filename in $manifest.required_assets.$category) {
        $source = Join-Path $InputDir $filename
        if (-not (Test-Path -LiteralPath $source)) {
            throw "Missing staged chroma asset: $source"
        }
        $output = Join-Path $outputDir $filename
        & python $helper --input $source --out $output --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill
        if ($LASTEXITCODE -ne 0) {
            throw "Chroma removal failed for $filename"
        }
    }
}
```

- [ ] **Step 4: Generate the eight approved batches with ChatGPT image generation**

Use one built-in image-generation call per named tile sheet, building, tree pair, or prop family. Use the exact prompt files from Task 2. Save selected source generations under `$CODEX_HOME/generated_images/`, inspect each output, and copy only approved outputs into a temporary workspace folder before processing.

For transparent objects, generate on flat `#ff00ff`, place every approved chroma source in `.asset-staging/chroma/` using its final manifest filename, then run:

```powershell
& tools/environment_assets/process_chroma_assets.ps1
```

If a one-pixel fringe remains, rerun once with `--edge-contract 1`.

- [ ] **Step 5: Normalize scale and filenames**

Export terrain tiles at exactly `128 x 128`. Keep object assets at their gameplay resolution with tight transparent bounds and bottom-center ground contact. Use exactly the manifest filenames.

- [ ] **Step 6: Inspect every final asset**

Reject any output with inconsistent camera angle, different ink weight, false transparency, visible tile seams, clipped roofs/canopies, modern items in ancient assets, fantasy medieval forms, or unreadable dusk values.

- [ ] **Step 7: Run validation and commit the approved pack**

Expected output: `Environment asset inventory is complete.`

```powershell
git add assets/art/environment tools/environment_assets/validate_assets.gd tools/environment_assets/process_chroma_assets.ps1
git commit -m "art: add generated dual-era environment asset pack"
```

### Task 4: Assemble Atlases and Build Godot TileSet Resources

**Files:**
- Create: `tools/environment_assets/assemble_atlases.gd`
- Create: `tools/environment_assets/build_tilesets.gd`
- Create: `resources/tilesets/shared_ground_tileset.tres`
- Create: `resources/tilesets/modern_detail_tileset.tres`
- Create: `resources/tilesets/ancient_detail_tileset.tres`
- Modify: `tests/test_environment_asset_manifest.gd`

- [ ] **Step 1: Extend the test to require generated TileSets**

Add:

```gdscript
for atlas_name in REQUIRED_ATLASES:
	var resource_path: String = manifest.atlases[atlas_name].resource
	assert(ResourceLoader.exists(resource_path))
	var tile_set := load(resource_path) as TileSet
	assert(tile_set != null)
	assert(tile_set.tile_size == Vector2i(128, 128))
	assert(tile_set.get_source_count() == 1)
```

- [ ] **Step 2: Run and verify missing-resource failure**

- [ ] **Step 3: Implement deterministic atlas assembly**

`assemble_atlases.gd` reads manifest atlas `slots`, creates an RGBA image sized `columns * 128` by `rows * 128`, resizes each source tile to `128 x 128`, and copies it into its declared slot. It must refuse duplicate slots or missing source files and save the three atlas PNGs at the manifest paths.

Add a `slots` object to each atlas entry, for example:

```json
"slots": {
  "shared_grass_01.png": [0, 0],
  "shared_grass_damp_01.png": [1, 0],
  "shared_earth_01.png": [2, 0],
  "shared_water_01.png": [0, 1],
  "shared_bank_n.png": [0, 2]
}
```

- [ ] **Step 4: Implement `build_tilesets.gd`**

Use this resource-building core:

```gdscript
var tile_set := TileSet.new()
tile_set.tile_size = Vector2i(128, 128)
var source := TileSetAtlasSource.new()
source.texture = load(atlas.image)
source.texture_region_size = Vector2i(128, 128)
for y in range(atlas.rows):
	for x in range(atlas.columns):
		source.create_tile(Vector2i(x, y))
tile_set.add_source(source, 0)
var error := ResourceSaver.save(tile_set, atlas.resource)
assert(error == OK)
```

- [ ] **Step 5: Generate atlases and resources**

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tools/environment_assets/assemble_atlases.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --editor --path . --quit-after 10
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tools/environment_assets/build_tilesets.gd
```

- [ ] **Step 6: Run tests and commit**

```powershell
git add tools/environment_assets assets/art/environment/*/terrain resources/tilesets tests/test_environment_asset_manifest.gd
git commit -m "feat: build environment tile atlases and tilesets"
```

### Task 5: Implement Deterministic Shared-Geography TileMap Layers

**Files:**
- Create: `scripts/world/environment_tile_catalog.gd`
- Create: `scripts/world/environment_tile_layout.gd`
- Create: `scenes/environment/shared/world_tile_layers.tscn`
- Create: `tests/test_environment_tile_layout.gd`
- Modify: `tests/run_all_tests.gd`

- [ ] **Step 1: Write the failing geography test**

Create `tests/test_environment_tile_layout.gd`:

```gdscript
extends RefCounted

func run() -> bool:
	var scene := load("res://scenes/environment/shared/world_tile_layers.tscn") as PackedScene
	assert(scene != null)
	var modern = scene.instantiate()
	modern.modern = true
	modern.populate()
	var ancient = scene.instantiate()
	ancient.modern = false
	ancient.populate()
	for layer_name in ["BaseTerrain", "RiverAndBanks", "EraRouteSurface", "TerrainVariation"]:
		assert(modern.get_node_or_null(layer_name) is TileMapLayer)
		assert(ancient.get_node_or_null(layer_name) is TileMapLayer)
	assert(modern.get_node("RiverAndBanks").get_used_cells() == ancient.get_node("RiverAndBanks").get_used_cells())
	assert(modern.get_node("EraRouteSurface").get_used_cells() == ancient.get_node("EraRouteSurface").get_used_cells())
	modern.free()
	ancient.free()
	return true
```

- [ ] **Step 2: Run and verify missing-scene failure**

- [ ] **Step 3: Create stable tile coordinates**

Create `environment_tile_catalog.gd` with constants for every atlas coordinate used by layout generation:

```gdscript
class_name EnvironmentTileCatalog
extends RefCounted

const GRASS := Vector2i(0, 0)
const GRASS_DAMP := Vector2i(1, 0)
const EARTH := Vector2i(2, 0)
const WATER := Vector2i(0, 1)
const WATER_SHADOW := Vector2i(1, 1)
const BANK_BY_MASK := {
	1: Vector2i(0, 2), 2: Vector2i(1, 2), 4: Vector2i(2, 2), 8: Vector2i(3, 2),
	3: Vector2i(4, 2), 6: Vector2i(5, 2), 12: Vector2i(6, 2), 9: Vector2i(7, 2),
}
const ROUTE := Vector2i(0, 0)
const ROUTE_DAMP := Vector2i(1, 0)
```

- [ ] **Step 4: Implement `EnvironmentTileLayout`**

The script owns `modern`, `grid_size = Vector2i(50, 33)`, `tile_size = 128`, and the existing `MAIN_ROUTE` coordinates. `populate()` must:

1. Assign the shared TileSet to `BaseTerrain` and `RiverAndBanks`.
2. Assign modern or ancient detail TileSet to route and variation layers.
3. Fill every cell with grass.
4. Mark river cells from the existing right-side river polygon.
5. Add bank cells by inspecting cardinal water neighbors and selecting `BANK_BY_MASK`.
6. Mark route cells when the cell center falls within the existing route widths.
7. Add deterministic damp/ground-detail variants with `hash(Vector2i) % 7`.

Use this distance helper for route cells:

```gdscript
func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if is_zero_approx(length_squared):
		return point.distance_to(start)
	var t := clamp((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * t)
```

- [ ] **Step 5: Create `world_tile_layers.tscn`**

```text
WorldTileLayers Node2D [environment_tile_layout.gd]
|- BaseTerrain TileMapLayer z_index=0
|- RiverAndBanks TileMapLayer z_index=1
|- EraRouteSurface TileMapLayer z_index=2
`- TerrainVariation TileMapLayer z_index=3
```

- [ ] **Step 6: Run tests and commit**

```powershell
git add scripts/world/environment_tile_catalog.gd scripts/world/environment_tile_layout.gd scenes/environment/shared/world_tile_layers.tscn tests/test_environment_tile_layout.gd tests/run_all_tests.gd
git commit -m "feat: add shared-geography environment tilemaps"
```

### Task 6: Replace Procedural Ground With TileMap Layers in Both Worlds

**Files:**
- Modify: `scenes/worlds/modern_oton_world.tscn`
- Modify: `scenes/worlds/ancient_katagman_world.tscn`
- Modify: `tests/test_diorama_world_contract.gd`
- Delete: `scripts/world/painted_world_ground.gd`

- [ ] **Step 1: Extend the world contract test**

Inside the world loop add:

```gdscript
var world_tiles := world.get_node_or_null("Ground/WorldTileLayers")
assert(world_tiles != null)
for tile_layer_name in ["BaseTerrain", "RiverAndBanks", "EraRouteSurface", "TerrainVariation"]:
	assert(world_tiles.get_node(tile_layer_name) is TileMapLayer)
assert(world.get_node_or_null("Ground/WorldVisual") == null)
```

After loading both worlds compare:

```gdscript
var modern_tiles = loaded_worlds[0].get_node("Ground/WorldTileLayers")
var ancient_tiles = loaded_worlds[1].get_node("Ground/WorldTileLayers")
assert(modern_tiles.get_node("RiverAndBanks").get_used_cells() == ancient_tiles.get_node("RiverAndBanks").get_used_cells())
```

- [ ] **Step 2: Run and verify failure on the existing `WorldVisual`**

- [ ] **Step 3: Replace `WorldVisual` in both scenes**

Instance `world_tile_layers.tscn` as `Ground/WorldTileLayers`. Set `modern = true` in Modern Oton and `modern = false` in ancient Katagman. Keep all existing root layer names, anchors, artifact points, entrances, and actor layers unchanged.

- [ ] **Step 4: Remove the obsolete procedural ground script**

Delete `scripts/world/painted_world_ground.gd` and its `.uid` after confirming no references remain:

```powershell
rg "painted_world_ground" .
```

Expected: no results after scene changes.

- [ ] **Step 5: Run tests, startup smoke test, and commit**

```powershell
git add scenes/worlds tests/test_diorama_world_contract.gd scripts/world/painted_world_ground.gd scripts/world/painted_world_ground.gd.uid
git commit -m "refactor: replace procedural ground with tilemaps"
```

### Task 7: Create Reusable Generated-Asset Object Scenes

**Files:**
- Create: `scripts/environment/environment_sprite_prop.gd`
- Create: `scenes/environment/shared/environment_prop.tscn`
- Create: `scenes/environment/shared/tropical_tree.tscn`
- Modify: `scenes/environment/modern/modern_house_exterior.tscn`
- Modify: `scenes/environment/ancient/kubo_exterior.tscn`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Add failing sprite-asset assertions**

Require `Sprite2D` visuals and foot-origin metadata:

```gdscript
for scene_path in [
	"res://scenes/environment/shared/environment_prop.tscn",
	"res://scenes/environment/shared/tropical_tree.tscn",
]:
	var packed := load(scene_path) as PackedScene
	assert(packed != null)
	var instance := packed.instantiate()
	assert(instance.has_meta("ground_contact_origin"))
	assert(instance.find_child("Sprite2D", true, false) != null)
	instance.free()
```

- [ ] **Step 2: Run and verify missing-scene failure**

- [ ] **Step 3: Implement the generic prop scene**

`environment_sprite_prop.gd` exposes `texture`, `visual_offset`, and `footprint_size`. In `_ready()` it assigns the texture, places the sprite so the root remains the foot point, and updates a rectangular footprint collision.

Scene contract:

```text
EnvironmentProp Node2D metadata/ground_contact_origin=(0,0)
|- ContactShadow Sprite2D
|- Visual Sprite2D
`- CollisionBody StaticBody2D
   `- CollisionShape2D
```

- [ ] **Step 4: Create the split tropical tree scene**

```text
TropicalTree Node2D metadata/ground_contact_origin=(0,0)
|- ContactShadow Sprite2D
|- BaseVisual Sprite2D texture=shared_coconut_palm_base_01.png
|- CanopyVisual Sprite2D texture=shared_coconut_palm_canopy_01.png z_index=2
`- CollisionBody StaticBody2D
   `- CollisionShape2D
```

The collision covers only the trunk base. The canopy has no collision.

- [ ] **Step 5: Replace procedural house and kubo visuals**

Keep the existing scene roots, metadata, collision, entrance alignment, and node names. Replace the scripted `BaseVisual` and `RoofVisual` with `Sprite2D` nodes using the generated base and roof PNGs. Preserve `RoofVisual.z_index = 2`.

- [ ] **Step 6: Run tests and commit**

```powershell
git add scripts/environment/environment_sprite_prop.gd scenes/environment tests/test_diorama_world_contract.gd
git commit -m "feat: add generated environment sprite scenes"
```

### Task 8: Populate All Five Districts in Both Eras

**Files:**
- Create: `scenes/environment/modern/modern_craft_district.tscn`
- Create: `scenes/environment/modern/modern_market_district.tscn`
- Create: `scenes/environment/modern/modern_riverside_district.tscn`
- Create: `scenes/environment/modern/modern_burial_geography.tscn`
- Create: `scenes/environment/ancient/ancient_craft_district.tscn`
- Create: `scenes/environment/ancient/ancient_market_district.tscn`
- Create: `scenes/environment/ancient/ancient_riverside_district.tscn`
- Create: `scenes/environment/ancient/ancient_burial_geography.tscn`
- Modify: `scenes/worlds/modern_oton_world.tscn`
- Modify: `scenes/worlds/ancient_katagman_world.tscn`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Add failing district assertions**

```gdscript
for district_name in ["ResidentialDistrict", "CraftDistrict", "MarketDistrict", "RiversideDistrict", "BurialDistrict"]:
	var district := world.get_node_or_null("DepthSortedWorld/Districts/%s" % district_name)
	assert(district != null)
	assert(district.get_child_count() >= 4)
```

Also assert each modern district root position equals its ancient counterpart.

- [ ] **Step 2: Run and verify failure**

- [ ] **Step 3: Build modern district scenes**

Each district contains one landmark, two supporting structures or vegetation masses, one prop cluster, and a clear route through the scene:

- Craft: modern workshop, worktable, cabinet, utility pole, vegetation.
- Market: pavilion, benches, garden pots, storage props, vegetation.
- Riverside: modern boat, landing supplies, reeds, palms, crate/searchable prop.
- Burial geography: restrained heritage landscape, path marker without text, trees, bushes, no exposed artifact marker.

- [ ] **Step 4: Build ancient district scenes**

- Craft: goldworking/pottery workshop, worktable, pottery, baskets, drying rack.
- Market: open shelter, pottery groups, woven goods, baskets, vegetation.
- Riverside: trade boat, dugout craft, wooden landing, reeds, basket/searchable prop.
- Burial geography: carefully interpreted natural area, earthen path, subdued markers, trees, mist, no fantasy tomb.

- [ ] **Step 5: Instance districts at matching anchors**

Create `DepthSortedWorld/Districts` in both worlds and use these shared root positions:

```text
ResidentialDistrict (1300, 1050)
CraftDistrict       (3050, 820)
MarketDistrict      (3450, 2180)
RiversideDistrict   (5500, 2020)
BurialDistrict      (4650, 3300)
```

Move existing searchable props and entrances into the appropriate district scenes while preserving artifact `NodePath` references. Update those paths in the same commit.

- [ ] **Step 6: Confirm traversal and collision**

Use Godot's visible collision shapes. Every main route remains at least 120 world units wide; door approaches remain open; water and world boundaries remain impassable; foreground art has no collision.

- [ ] **Step 7: Run tests and commit**

```powershell
git add scenes/environment/modern scenes/environment/ancient scenes/worlds tests/test_diorama_world_contract.gd
git commit -m "feat: populate dual-era exploration districts"
```

### Task 9: Add Mysterious Dusk Atmosphere and Era Differentiation

**Files:**
- Create: `scripts/environment/era_atmosphere.gd`
- Create: `scenes/environment/shared/era_atmosphere.tscn`
- Modify: `scenes/worlds/modern_oton_world.tscn`
- Modify: `scenes/worlds/ancient_katagman_world.tscn`
- Modify: `tests/test_diorama_world_contract.gd`

- [ ] **Step 1: Add failing atmosphere assertions**

```gdscript
var atmosphere := world.get_node("EraAtmosphere/Atmosphere")
assert(atmosphere.has_method("get_ambient_color"))
if world.era_id == 1:
	assert(atmosphere.get_ambient_color().get_luminance() < loaded_worlds[0].get_node("EraAtmosphere/Atmosphere").get_ambient_color().get_luminance())
```

- [ ] **Step 2: Run and verify failure**

- [ ] **Step 3: Implement reusable atmosphere scene**

The scene contains:

```text
Atmosphere Node2D [era_atmosphere.gd]
|- CanvasModulate
|- Mist Sprite2D
|- WarmGlow Sprite2D
`- DriftingParticles GPUParticles2D
```

Modern ambient color: `Color("#a8ac96")`.

Ancient ambient color: `Color("#7f8f82")` with higher mist opacity and lower warm-glow energy.

The script exposes:

```gdscript
func get_ambient_color() -> Color:
	return $CanvasModulate.color
```

- [ ] **Step 4: Add atmosphere to both worlds**

Instance under `EraAtmosphere/Atmosphere`; set `ancient = false` or `true`. Keep HUD unaffected because it remains in `CanvasLayer`.

- [ ] **Step 5: Run tests, inspect both eras, and commit**

```powershell
git add scripts/environment/era_atmosphere.gd scenes/environment/shared/era_atmosphere.tscn scenes/worlds tests/test_diorama_world_contract.gd
git commit -m "style: add mysterious dual-era dusk atmosphere"
```

### Task 10: Documentation, Captures, Final Verification, and Push

**Files:**
- Modify: `tools/capture_preview.gd`
- Modify: `assets/README.md`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `README.md`
- Create: `docs/modern-full-tilemap-preview.png`
- Create: `docs/ancient-full-tilemap-preview.png`
- Create: `docs/modern-district-previews.png`
- Create: `docs/ancient-district-previews.png`

- [ ] **Step 1: Extend the preview tool**

Capture both eras at the five district anchors and save full-map screenshots. Ensure the player uses the same coordinate before and after each `F` transition comparison.

- [ ] **Step 2: Document the asset workflow**

Update `assets/README.md` with:

1. Where source generations stay.
2. Where game-ready assets belong.
3. Exact naming and bottom-center origin rules.
4. How to run validation, atlas assembly, TileSet building, and Godot import.
5. How teammates replace generated art without changing TileMap coordinates or scene contracts.

- [ ] **Step 3: Document architecture**

Update `docs/ARCHITECTURE.md` with the manifest, atlas, TileSet, deterministic shared-layout, district scene, collision, and era-atmosphere contracts.

- [ ] **Step 4: Run fresh verification**

```powershell
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tools/environment_assets/validate_assets.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --script res://tests/run_all_tests.gd
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --headless --path . --quit-after 30
& 'C:\Users\ASUS\OneDrive\Desktop\Godot_v4.4.1-stable_win64.exe' --path . --script res://tools/capture_preview.gd
git diff --check
```

Expected:

- Asset validator reports a complete inventory.
- All logic tests pass.
- Startup smoke test exits `0`.
- Preview captures are created.
- No parser, missing-resource, or import errors appear.
- `git diff --check` prints nothing.

- [ ] **Step 5: Visually inspect all captures**

Confirm:

1. Tiles repeat without visible seams.
2. Modern and ancient river/route geometry matches.
3. Ancient Katagman is slightly darker but remains navigable.
4. Bold storybook ink and painted texture remain consistent across all assets.
5. Player depth sorting works around buildings, trees, boats, and props.
6. Entrances and searchable objects remain readable.
7. No foreground art blocks important interaction zones.

- [ ] **Step 6: Commit and push**

```powershell
git add README.md assets/README.md docs/ARCHITECTURE.md docs/*tilemap*.png docs/*district*.png tools/capture_preview.gd
git commit -m "docs: document environment tilemap production workflow"
git push origin main
```

## Final Verification Checklist

- [ ] All manifest assets exist and validate.
- [ ] Prompt files reproduce the approved art direction without copying reference artwork.
- [ ] TileSet resources use `128 x 128` cells and smooth filtering.
- [ ] Both worlds contain identical river and route cell coordinates.
- [ ] Ground, riverbanks, route surfaces, and details cover the full map.
- [ ] All five districts exist in both eras at matching anchors.
- [ ] Buildings, kubo, trees, boats, bushes, and props use foot-based depth sorting.
- [ ] Modern and ancient entrances and searchable artifact covers still work.
- [ ] Ancient atmosphere is darker than modern while remaining readable.
- [ ] Minimap, full map, fullscreen, interiors, Eye Piece, `F` transition, and Nose Piece flow remain green.
- [ ] Final captures show a coherent, mysterious, hand-painted storybook world rather than pixel art or procedural geometry.
