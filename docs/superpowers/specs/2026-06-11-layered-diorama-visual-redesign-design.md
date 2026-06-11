# Layered Diorama Visual Redesign

## Purpose

Transform `Hutik sa Katagman` from a flat top-down blockout into an original, hand-painted 2D exploration game with the camera composition, object layering, environmental density, and sense of depth established during the approved visual workshop.

The redesign may draw inspiration from the supplied references' high three-quarter framing and illustrated depth, but it must not reproduce their characters, environments, props, compositions, or artwork. The finished identity must be recognizably rooted in Oton, Iloilo and the Katagman narrative.

## Approved Direction

The user approved the following visual decisions:

| Category | Approved Direction |
| --- | --- |
| Camera language | Layered Diorama, high three-quarter 2D view |
| Surface treatment | Hand-Painted Folk Diorama |
| Outdoor lighting | Warm Daylight |
| World density | Dense Story Clusters connected by quieter paths and fields |
| Outdoor character scale | Wide Explorer, approximately 48-56 screen pixels tall |

## Camera

The game remains a true 2D project. The apparent camera angle is created through three-quarter artwork, vertically offset building facades, visible roofs, elliptical ground footprints, and depth sorting rather than by rotating a 3D camera.

Outdoor camera behavior:

- Viewport remains `1280 x 720`.
- Camera rotation remains zero.
- Camera zoom begins at `Vector2(1.0, 1.0)` and is tuned so the final outdoor player sprite appears approximately 48-56 pixels tall on screen.
- Position smoothing remains enabled at approximately `6.0`.
- A small vertical look-ahead places the player slightly below screen center, exposing more of the route ahead.
- Drag margins remain subtle so the camera feels composed rather than mechanically locked to every player step.
- Discovery moments may briefly ease to a closer zoom.
- Interiors use a closer default composition, approximately 72-84 pixels for the character.

The camera must never rotate or use perspective distortion. UI remains in `CanvasLayer` and is unaffected by camera zoom.

## Render Stack

Each outdoor world uses explicit visual layers:

```text
OutdoorWorld
|- FarBackground                 fixed low Z; distant canopy silhouettes and sky gaps
|- Ground                       fixed Z; earth, grass, roads, river, clearings
|- GroundDetail                 fixed Z; stones, leaves, footprints, grass patches
|- DepthSortedWorld             Y-sort enabled
|  |- Buildings                foot anchors at doors or foundation contact points
|  |- TreesAndVegetation       foot anchors at trunk bases
|  |- Props                     baskets, pottery, signs, boats, worktables
|  |- Interactables             searchable objects and entrances
|  |- Player                    sorting point at the feet
|  `- NPCs                      future characters use the same foot-origin contract
|- RoofAndCanopyOverlays         high Z; selective roofs, branches, hanging leaves
|- NearForeground               highest world Z; oversized dark leaves and framing shapes
`- EraAtmosphere                particles, insects, drifting leaves, smoke, water highlights
```

`DepthSortedWorld` enables Y sorting. Every sortable sprite uses its ground-contact point as its origin or Y-sort origin. A character walking behind a kubo, tree, sign, or market prop is drawn behind it; walking below that object draws the character in front.

Large roofs and tree crowns are split from their collision-bearing bases when necessary. This permits the lower structure to Y-sort naturally while the upper canopy stays above the player.

## Foreground Depth

Foreground occlusion is intentional but brief:

- Oversized leaves, roof edges, posts, and hanging branches frame the lower and side edges of the screen.
- Foreground shapes may cover the player for short movement intervals but cannot hide intersections, entrances, collectibles, or interaction prompts for long periods.
- Near-camera framing may use a very subtle `Parallax2D` scroll scale above `1.0` only when it improves depth without sliding unnaturally against world geometry.
- Distant decorative silhouettes may use scroll scale below `1.0`.
- Collision and gameplay positions remain in world space and never live inside parallax layers.

## World Composition

The `6400 x 4200` worlds remain large, but they are no longer filled uniformly. They are organized as dense story clusters joined by quieter travel space.

Each major district is composed like a handcrafted scene:

1. A readable entrance silhouette.
2. One dominant landmark.
3. Two to four supporting structures or vegetation masses.
4. A path loop or branching choice.
5. Foreground framing.
6. Small cultural and environmental props.
7. One or more interaction opportunities.
8. A distinct ambient sound profile.

Travel corridors use fields, river views, fences, trees, roadside objects, and changing ground texture. They provide breathing room without becoming empty corridors.

## Shared Geography and Era Pairing

Modern Oton and ancient Katagman retain matching world bounds, river course, district anchors, and major route logic. Their artwork is authored independently.

Examples:

| Geography | Modern Oton, 2026 | Katagman Reconstruction |
| --- | --- | --- |
| Residential cluster | Concrete homes, galvanized roofs, utility details, roadside plants | Raised kubo, nipa roofs, woven walls, storage baskets |
| Craft cluster | Repair shops, small businesses, tools, modern containers | Goldworking, pottery, beads, wooden worktables |
| Riverside | Concrete or timber landing, modern boats and supplies | Trading boats, woven goods, ceramics, wooden landing |
| Central route | Compacted or paved road, signs, drainage | Earthen path, vegetation edges, carved or wooden markers |
| Burial geography | Altered or protected modern land | Carefully labeled interpretive reconstruction |

The Eye Piece transition preserves the player's world coordinate so the visual contrast is immediate and compositionally comparable.

## Art Direction

The final assets use an original hand-painted folk illustration style:

- Bold, readable silhouettes.
- Textured color fields rather than flat geometric fills.
- Controlled dark outlines, strongest on characters and interactive objects.
- Slightly irregular hand-painted edges.
- Warm ochre, clay, wood, nipa, river blue-green, and layered vegetation palettes.
- Modern materials use cooler concrete, metal, glass, painted wood, and asphalt accents without losing the shared visual language.
- Proportions may be gently stylized, but cultural objects must remain identifiable and reviewed.

The final style is not pixel art. Texture filtering remains smooth, and high-resolution source art must support fullscreen display without visible scaling artifacts.

## Character

The outdoor player sprite is approximately 48-56 screen pixels tall at default zoom.

Required animation states:

- Idle: four directions.
- Walk: four directions, at least six frames per direction when final art is available.
- Interact or inspect.
- Artifact recovery reaction.
- Eye Piece transition pose or silhouette.

The character's feet remain visually stable across frames to prevent Y-sort jitter. Collision is centered around the feet and lower body, not the full painted silhouette.

## Buildings and Props

Buildings are assembled from at least two visual sections:

- Base or facade: participates in Y sorting and owns collision.
- Roof or canopy: may extend above and in front of actors.

Every enterable structure has a clear doorway silhouette and a visible path approach. Doors use the existing `WorldEntrance` contract.

Props are separated into:

- Background decoration with no gameplay node.
- Y-sorted world props.
- Searchable props preserving `SearchableProp`, collision, closed/open visuals, and `RevealPoint`.
- Foreground-only framing props without collision.

Artifact locations must never be visually marked by a special asset before discovery.

## Lighting and Shadows

Outdoor exploration uses warm daylight and remains fully readable:

- Broad palette and ambient color provide the primary lighting.
- Painted contact shadows sit beneath characters, buildings, baskets, boats, trees, and signs.
- Directional cast shadows share a consistent sun direction.
- Real-time 2D shadows are used selectively, not on every outdoor object.
- Water highlights, smoke, insects, dust, and leaf movement add life without darkening the scene.

Interiors and story scenes may use `CanvasModulate`, `PointLight2D`, and `LightOccluder2D` for stronger pools of light and shadows. The HUD remains unaffected on its CanvasLayer.

## Collision and Navigation

- Collision follows the ground footprint, never the full roof or foliage silhouette.
- Trees collide around trunk bases.
- Raised houses collide around posts, walls, and inaccessible foundation areas while preserving doorway paths.
- Foreground canopy art is non-colliding.
- Paths remain at least three player widths across at normal traversal points.
- No foreground art may permanently obscure an interaction area.

## Scene and Asset Architecture

The current procedural `PlaceholderWorldVisual` is replaced by authored layer containers and reusable visual scenes.

Planned reusable scenes:

```text
scenes/environment/shared/depth_sorted_prop.tscn
scenes/environment/shared/foreground_cluster.tscn
scenes/environment/modern/modern_house_exterior.tscn
scenes/environment/modern/modern_vegetation_cluster.tscn
scenes/environment/ancient/kubo_exterior.tscn
scenes/environment/ancient/ancient_vegetation_cluster.tscn
scenes/environment/ancient/river_boat.tscn
```

The first implementation slice must establish the layer architecture, camera behavior, sorting contracts, reusable placeholder scenes, and one polished residential cluster per era. It does not pretend to replace the team's final art production.

## Asset Handoff Requirements

Environment source art should be delivered as transparent PNG or lossless WebP at the intended import scale. Large objects must be split when different sections require different sorting behavior.

Each asset handoff records:

- Era.
- District.
- Ground-contact origin.
- Collision footprint.
- Whether it Y-sorts.
- Whether it belongs above the player.
- Whether it is decorative, interactable, searchable, or enterable.
- Optional normal map or light occluder requirement.

## Performance

- Use authored scenes and `TileMapLayer` where repeating ground details benefit from batching.
- Use individual sprites for landmarks, interactables, large vegetation, and split buildings.
- Avoid real-time shadow casting on dense outdoor foliage.
- Use `VisibleOnScreenNotifier2D` or district activation only if final art density creates measurable runtime cost.
- Maintain the Compatibility renderer unless profiling demonstrates a required change.

## Testing

Automated tests verify:

1. Both outdoor scenes expose the required render-layer containers.
2. `DepthSortedWorld` has Y sorting enabled.
3. Player and sample environment objects use foot-based sorting contracts.
4. Camera outdoor and interior profiles apply the approved zoom and look-ahead behavior.
5. Modern and ancient worlds preserve matching geographic anchors.
6. Searchable props, entrances, artifact recovery, minimap, and era transition still function after the visual restructure.

Visual verification captures:

- Modern residential cluster.
- Ancient residential cluster at the matching coordinate.
- Player behind and in front of a tall prop.
- Foreground canopy overlap.
- Interior close-camera composition.
- Fullscreen output at the target aspect ratio.

## Success Criteria

The redesign is successful when:

- A gameplay screenshot reads as an illustrated place rather than a diagram.
- Roofs, trees, props, foreground leaves, and the player create at least four obvious depth planes.
- The player can pass naturally behind and in front of world objects.
- Each district has a recognizable landmark composition.
- Modern and ancient screenshots clearly depict the same geography in different eras.
- Outdoor exploration remains readable in warm daylight.
- Final art can replace placeholders without rewriting gameplay systems.

## Deferred Work

- Final environment and character asset production for every district.
- Full NPC population and schedules.
- Weather and day/night cycles.
- Advanced normal-map lighting on all assets.
- Cinematic camera rails or cutscene authoring tools.
- Full district streaming, unless profiling proves it necessary.
