# Fullscreen Navigation Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add F11 fullscreen toggling, a live outdoor minimap, and an M-key full map showing the player's current or saved outdoor location.

**Architecture:** A reusable `NavigationMap` Control owns coordinate conversion and drawing. `PrototypeHUD` owns minimap and full-map instances, while persistent `GameRoot` provides navigation state and input coordination across outdoor and interior scene loads.

**Tech Stack:** Godot 4.4, GDScript, custom `Control._draw()`, InputMap actions, existing CanvasLayer HUD, and headless integration tests.

---

## File Map

- Create `scripts/ui/navigation_map.gd`: coordinate conversion and era-specific map drawing
- Create `scenes/ui/navigation_map.tscn`: reusable map surface
- Create `tests/test_navigation_map.gd`: coordinate conversion tests
- Modify `scenes/ui/hud.tscn`: minimap and full map overlay
- Modify `scripts/ui/hud.gd`: navigation update and overlay API
- Modify `scripts/gameplay/game_root.gd`: M/F11 handling and navigation state updates
- Modify `project.godot`: `toggle_map` and `toggle_fullscreen` actions
- Modify `tests/test_game_root_flow.gd`: map integration assertions
- Modify `README.md`: controls

### Task 1: Navigation Map Math

- [ ] Add a failing unit test for converting world origin, center, end, and out-of-bounds positions into map coordinates.
- [ ] Run the suite and confirm failure because `NavigationMap` is missing.
- [ ] Implement `world_to_map(position, bounds, map_size)` with clamping.
- [ ] Rerun the suite and confirm the math test passes.

### Task 2: Reusable Map Rendering

- [ ] Create `navigation_map.tscn` with the new script.
- [ ] Draw era-specific land, river, shared routes, district markers, and player marker.
- [ ] Add `set_navigation_context(bounds, position, era, indoors)` and queue redraws.
- [ ] Verify the scene loads without parse errors.

### Task 3: HUD Map Surfaces

- [ ] Add a top-right minimap panel and a hidden full-screen map overlay.
- [ ] Add HUD methods `update_navigation()`, `toggle_full_map()`, `set_full_map_visible()`, and `is_full_map_visible()`.
- [ ] Include map controls in the HUD hint and show coordinates/indoor status on the full map.

### Task 4: Runtime Input and State

- [ ] Add failing integration assertions for M toggling, movement lock, outdoor location updates, era changes, and indoor saved-position display.
- [ ] Map `M` to `toggle_map` and `F11` to `toggle_fullscreen`.
- [ ] Handle both actions in `GameRoot` and update navigation every frame.
- [ ] Preserve the player's prior input-enabled state when the full map closes.
- [ ] Rerun the integration suite.

### Task 5: Verification and Publish

- [ ] Update README controls.
- [ ] Run all tests and a 30-frame startup smoke test.
- [ ] Run `git diff --check` and ensure the unrelated `main_game.tscn` editor rewrite is unstaged.
- [ ] Commit with `feat: add fullscreen navigation maps` and push to `origin/main`.
