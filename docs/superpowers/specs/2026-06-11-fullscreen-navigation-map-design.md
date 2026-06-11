# Fullscreen and Navigation Map Design

## Goal

Add fullscreen support and clear large-world navigation without exposing hidden artifact locations.

## Player Experience

- `F11` toggles between windowed and fullscreen mode.
- A compact minimap remains in the top-right while exploring outdoors.
- `M` opens and closes a large centered map overlay.
- Both maps show the current era, shared geography, district landmarks, and the player's current position.
- While inside a building, the maps show the saved outdoor return position and identify the player as indoors.
- Opening the large map pauses player movement but not the game tree.

## Architecture

`NavigationMap` is a reusable `Control` that converts a world-space position inside a `Rect2` into map-space coordinates. It draws a simplified era-colored map, shared district anchors, and a player marker. The HUD owns one minimap and one large-map instance and exposes methods for updating navigation context and toggling the overlay.

`GameRoot` supplies the active world bounds, era, player position, and indoor state. It handles `M` and `F11` input so scene transitions do not reset map or display behavior.

## Visual Rules

- Modern Oton uses muted green land, gray routes, blue water, and cyan location markers.
- Ancient Katagman uses dark green land, ochre paths, blue-green water, and gold location markers.
- The full map includes a legend and coordinate readout.
- Artifact spawn locations are never displayed.

## Testing

- Unit-test world-to-map coordinate conversion and clamping.
- Integration-test minimap presence, `M` visibility toggling, player input locking, era updates, and indoor return-location display.
- Smoke-test the startup scene in headless Godot.
