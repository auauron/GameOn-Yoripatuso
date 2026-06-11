class_name ArtifactSpawnPoint
extends Marker2D

@export var location_name := "Unnamed Katagman Location"
@export var searchable_prop_path: NodePath

func get_searchable_prop() -> SearchableProp:
	if searchable_prop_path.is_empty():
		return null
	return get_node_or_null(searchable_prop_path) as SearchableProp
