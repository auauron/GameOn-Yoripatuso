extends RefCounted

const PortalGatewayScript = preload("res://scripts/integration/portal_gateway.gd")

func run() -> bool:
	var payload := PortalGatewayScript.build_discovery_payload("Player_001", "Wooden Storage Chest")
	assert(payload["player_id"] == "Player_001")
	assert(payload["artifact_name"] == "Oton Gold Death Mask")
	assert(payload["artifact_component"] == "Nose Piece")
	assert(payload["discovered_location"] == "Wooden Storage Chest")
	assert(payload["status"] == "found")
	return true
