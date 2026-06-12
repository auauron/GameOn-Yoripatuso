# AI Environment TileMap Asset Pack Design

## Purpose

Create a consistent, non-pixel environment asset pack for `Hutik sa Katagman` using ChatGPT image generation, then integrate it into Godot 4.4 as reusable `TileSet` resources and depth-sorted object scenes.

The pack covers matching geography in Modern Oton, 2026 and the 14th-15th century Katagman reconstruction. Ground and river geometry remain identical between eras, while buildings, routes, vegetation details, props, and atmosphere communicate the time difference.

This specification supersedes the earlier warm-daylight direction for generated environment assets. The approved lighting is now humid late afternoon approaching dusk, with ancient Katagman slightly darker and more dreamlike.

## Approved Direction

| Category | Decision |
| --- | --- |
| Generator | ChatGPT image generation |
| Camera | High three-quarter 2D diorama view; no perspective camera rotation |
| Rendering style | Smooth hand-painted storybook illustration, not pixel art |
| Line treatment | Bold, irregular dark ink contours |
| Surface treatment | Layered watercolor and gouache-like painted texture |
| Grid | `128 x 128` Godot cells |
| Source resolution | `512 x 512` per ground tile or equivalent 4x source scale |
| Buildings | Complete buildings plus modular construction pieces |
| Lighting | Mysterious humid dusk with readable terrain and warm practical lights |
| Ancient treatment | Slightly darker blue-green shadows, stronger mist, subdued gold highlights |
| Era geography | Identical river course, ground boundaries, district anchors, and main routes |

## Originality and Historical Grounding

The supplied game artwork is a style reference only. Generated assets must not reproduce its characters, buildings, composition, symbols, or distinctive object designs. The pack uses an original visual identity grounded in Oton and Katagman.

Ancient assets should use historically plausible materials such as wood, bamboo, nipa, woven wall panels, earthen paths, pottery, baskets, river craft, beads, and workshop tools. Generated imagery must avoid fantasy ruins, European medieval architecture, gothic shapes, modern objects, or unsupported ceremonial symbolism.

Modern assets may include concrete houses, galvanized roofing, painted wood, simple drainage, utility poles, small boats, gardens, roadside vegetation, and restrained 2026 details. They should still share the same ink and paint language as the ancient set.

## Production Approach

Use a hybrid pipeline rather than requesting one giant atlas:

1. Generate seamless terrain families in controlled tile batches.
2. Generate transitions and edges after the base terrain palette is approved.
3. Generate complete buildings individually on transparent backgrounds.
4. Generate modular building pieces in matching follow-up batches.
5. Generate trees, bushes, boats, props, and foreground overlays as isolated transparent objects.
6. Normalize dimensions, transparency, color, and ground-contact origins before Godot import.
7. Assemble final atlases mechanically after individual assets are approved.

This reduces scale drift, inconsistent lighting, accidental overlaps, broken transparency, and unusable tile boundaries.

## Shared Style Lock

Every ChatGPT image request begins with this style lock:

> Create an original 2D environment asset for a narrative exploration game set in Oton, Iloilo, Philippines. Use a smooth hand-painted storybook style with bold irregular dark-brown ink contours, watercolor and gouache-like texture, gently stylized proportions, readable silhouettes, and mysterious humid late-afternoon light approaching dusk. Use a high three-quarter diorama viewing angle with visible roof planes and ground footprints. Keep the art painterly and high resolution, never pixel art. Maintain a coherent palette of muted tropical greens, blue-green shadows, warm earth, aged wood, nipa straw, river teal, and restrained amber light. Do not imitate or reproduce any existing game's exact artwork, characters, compositions, or designs.

The ancient-era variation appends:

> This asset belongs to a historically grounded 14th-15th century Katagman reconstruction. Make it slightly darker and more dreamlike than the modern era, with deeper blue-green shadows, stronger humid mist, subdued gold highlights, and materials appropriate to precolonial Panay. Exclude concrete, electric lights, modern tools, plastics, asphalt, European medieval architecture, fantasy ruins, and gothic decoration.

The modern-era variation appends:

> This asset belongs to Modern Oton in 2026. Use modest concrete, timber, galvanized metal, local garden plants, drainage, utility details, and contemporary river-community objects. Keep the atmosphere mysterious and natural rather than futuristic, urban, glossy, or photorealistic.

## Negative Constraints

Append these constraints to every generation request:

> No pixel art, no low-resolution edges, no isometric diamond grid, no side-view platformer angle, no front elevation only, no photorealism, no 3D render, no anime character style, no text, no labels, no UI, no watermark, no white border, no checkerboard background, no cast shadow cut off by the canvas, no duplicated objects, and no unrelated scenery. Preserve the requested camera angle, scale, palette, ink weight, and light direction.

## Tile Families

### Shared Base Terrain

The following terrain families exist in both eras and preserve matching geometry:

- Tropical grass: short, worn, damp, sparse, and darker variants.
- Packed earth: dry center, damp edge, footprint-worn, leaf-strewn variants.
- Sand and river mud.
- Stone or compacted aggregate for selected modern routes.
- River water: calm, rippled, shadowed, shallow, and reflected-light variants.
- Riverbanks: grass-to-water, earth-to-water, mud-to-water, inner corners, outer corners.
- Path transitions: grass-to-earth and grass-to-aggregate edges and corners.
- Small ground details: leaves, stones, roots, puddles, grass tufts, and worn marks.

Terrain tiles use seamless edges and contain no large unique landmark. They avoid baked object shadows so lighting can remain consistent when tiles repeat.

### Era-Specific Terrain Details

Modern Oton adds:

- Narrow concrete or aggregate paths.
- Drainage edges and simple culverts.
- Trimmed garden patches.
- Modern landing or dock surfaces.
- Restrained litter-free roadside details.

Ancient Katagman adds:

- Earthen footpaths.
- Bamboo or timber walkways.
- Trampled settlement clearings.
- Pottery or workshop soil marks.
- Wooden river landings.

## Object Inventory

### Shared Tropical Vegetation

- Coconut palms in at least four silhouettes.
- Broadleaf tropical trees in at least four silhouettes.
- Mangrove or riverside trees.
- Banana and low garden plants.
- Dense bushes, light bushes, flowering shrubs, reeds, grasses, roots, and vines.
- Fallen logs, stones, small stumps, and leaf clusters.
- Split vegetation assets: trunk/base for Y sorting and canopy overlay where required.

### Modern Oton

- Three complete modest house silhouettes with visible roofs and door approaches.
- Modular concrete walls, painted timber walls, galvanized roofs, doors, windows, posts, awnings, steps, and fences.
- Barangay-style pavilion or open shelter.
- Utility poles and restrained wire segments.
- Small modern riverboat, landing supplies, containers, benches, signs without text, garden pots, tables, cabinets, and storage objects.
- Searchable furniture variants for drawers, tables, beds, cabinets, and boxes.

### Ancient Katagman

- Three complete raised kubo silhouettes with nipa roofs and woven walls.
- Modular nipa roof planes, bamboo walls, woven panels, doors, windows, posts, stilts, ladders, platforms, railings, and under-house storage.
- River trading boat and smaller dugout-style craft.
- Pottery, baskets, woven mats, wooden chests, jars, bead containers, worktables, drying racks, fishing equipment, and market bundles.
- Goldworking and pottery workshop props rendered carefully without magical effects.
- Searchable variants for mats, baskets, jars, chests, tables, and storage alcoves.

### Atmosphere and Foreground

- Mist strips and soft river haze on transparent backgrounds.
- Warm window and lamp glow overlays without a surrounding environment.
- Smoke wisps, drifting leaves, water glints, insects, and dust particles.
- Large foreground leaves and branches designed for screen-edge framing.
- Painted contact shadows and optional directional shadow overlays.

## Scale and Export Contract

- Ground tiles: authored at `512 x 512`, exported to a `128 x 128` gameplay tile after review.
- Small props: source images generally `512 x 512`, tightly cropped with transparent margins kept minimal.
- Trees and buildings: source images between `1024` and `2048` pixels on the long edge.
- Transparent objects use true alpha, not a painted white or checkerboard background.
- Sortable objects place the ground-contact point at bottom center.
- Large trees split into a trunk/base sprite and canopy overlay when the player must walk behind the crown.
- Buildings split into a collision-bearing base/facade and roof overlay when necessary.
- Contact shadows are either separate sprites or consistently painted directly beneath isolated assets. Long cast shadows remain separate overlays.
- Texture filtering remains enabled in Godot; nearest-neighbor filtering is not used.

## ChatGPT Batch Prompt Template

Use this template for each controlled batch:

> [STYLE LOCK]
>
> Generate a clean production asset sheet containing exactly [COUNT] variations of [ASSET FAMILY]. Arrange them in a simple evenly spaced grid with no overlap. Every item must use the same high three-quarter camera angle, scale, dusk light direction, dark-brown ink weight, watercolor texture, and palette. [ERA VARIATION]
>
> Technical requirements: [TILE OR OBJECT REQUIREMENTS]. Leave generous separation for clean extraction. Keep all items fully inside the canvas. [NEGATIVE CONSTRAINTS]

For isolated object sheets, use:

> Transparent background. Show each complete object once. Align each object's ground-contact point consistently. Do not include scenery, ground patches, labels, borders, or decorative frames.

For seamless terrain, use:

> Produce one square seamless texture tile with perfectly matching left-right and top-bottom edges. Use uniform local detail with no central focal object, no border, and no directional cast shadow. The tile must repeat invisibly in all directions.

## First Generation Batches

Generate and approve batches in this order:

1. Shared grass, packed earth, sand, mud, and river-water base tiles.
2. Shared terrain transitions, riverbank edges, corners, and path edges.
3. Shared tropical trees, palms, bushes, reeds, rocks, and ground details.
4. Modern complete houses and pavilion.
5. Modern modular building parts and environment props.
6. Ancient complete kubo and workshop structures.
7. Ancient modular building parts, boats, pottery, baskets, and work props.
8. Shared mist, shadows, light glows, particles, and foreground canopies.

The team reviews one batch before using its generated output as a visual reference for the next. Approved outputs should be attached to subsequent ChatGPT prompts to preserve consistency.

## Godot Asset Structure

```text
assets/art/environment/
|- shared/
|  |- terrain/
|  |- water/
|  |- vegetation/
|  |- props/
|  `- atmosphere/
|- modern/
|  |- terrain/
|  |- buildings/
|  |- props/
|  `- atmosphere/
`- ancient/
   |- terrain/
   |- buildings/
   |- boats/
   |- props/
   `- atmosphere/

resources/tilesets/
|- shared_ground_tileset.tres
|- modern_detail_tileset.tres
`- ancient_detail_tileset.tres
```

Source generations and editable working files stay outside the Godot project. Only reviewed, cropped, game-ready PNG or lossless WebP exports enter `assets/`.

## Godot TileMap Architecture

Each outdoor scene uses multiple `TileMapLayer` nodes rather than one all-purpose map:

```text
Ground
|- BaseTerrain             shared cell geometry
|- RiverAndBanks           shared cell geometry
|- EraRouteSurface         same route footprint, era-specific art

GroundDetail
|- TerrainVariation        randomized visual alternates
|- SmallVegetation         non-colliding details
`- GroundProps             leaves, stones, puddles, footprints

DepthSortedWorld
|- Buildings              scene instances, not ground tiles
|- TreesAndVegetation     scene instances with foot origins
|- Props                  scene instances
|- Interactables
|- Player
`- Artifact

RoofAndCanopyOverlays
|- BuildingRoofs
`- TreeCanopies

EraAtmosphere
|- MistAndLight
`- Particles
```

Base terrain and river cell data can be shared or generated from the same map definition. Era-specific detail layers may differ while preserving the player's coordinate during the Eye Piece transition.

## Terrain and Collision Rules

- Terrain transitions use Godot terrain sets for grass, earth, sand, mud, water, and route surfaces.
- Water collision or traversal boundaries belong to dedicated collision/navigation data, not decorative ripples.
- Buildings, trees, and large props remain scene instances because they require Y sorting, interaction, collision footprints, or split overlays.
- Tile collisions follow only impassable ground footprints.
- Foreground framing and upper canopies never carry collision.
- Searchable and enterable objects preserve the existing gameplay node contracts.

## Naming Convention

Use lowercase snake case:

```text
shared_grass_damp_01.png
shared_river_bank_outer_ne.png
modern_house_concrete_blue_01.png
modern_roof_galvanized_red_01.png
ancient_kubo_woven_wall_01.png
ancient_river_boat_trade_01.png
shared_coconut_palm_base_01.png
shared_coconut_palm_canopy_01.png
```

Directional suffixes use `n`, `ne`, `e`, `se`, `s`, `sw`, `w`, and `nw`. Variations use two-digit indices.

## Quality Checklist

Reject or regenerate an asset when:

- It changes camera angle or perspective.
- It appears pixelated, photorealistic, or like a 3D render.
- Ink contours differ strongly from approved assets.
- Lighting direction or palette changes unexpectedly.
- A seamless tile has visible boundaries.
- Transparency contains halos or a false background.
- Object scale does not match the established house, player, or grid reference.
- Ground-contact origin is unclear.
- Ancient content contains modern or fantasy elements.
- Modern content becomes futuristic, urbanized, or culturally generic.
- The asset visually identifies an artifact hiding place before interaction.

## Validation

The implementation phase must verify:

1. Tiles repeat without visible seams at fullscreen resolution.
2. Terrain transitions cover straight edges, inner corners, and outer corners.
3. Modern and ancient world layers use matching ground and river coordinates.
4. Player depth sorting works around trees, houses, kubo, boats, and props.
5. Buildings retain working entrances and searchable objects retain reveal points.
6. Ancient screenshots are slightly darker without making paths or interactables unreadable.
7. Texture filtering produces smooth art without excessive blur.
8. Existing minimap, full map, artifact recovery, interiors, and era transition still pass automated tests.

## Success Criteria

The pack is successful when:

- Screenshots read as an original hand-painted storybook world rather than a procedural blockout.
- All assets look as though they came from one illustrator and one lighting setup.
- Modern Oton and ancient Katagman are immediately distinguishable while clearly sharing geography.
- Ground tiles repeat naturally across the large `6400 x 4200` maps.
- Houses, kubo, trees, bushes, paths, riverbanks, boats, props, and atmosphere can build complete districts.
- The team's final artwork can replace or extend generated assets without changing gameplay architecture.
