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
		"status": "found",
	}

func trigger_portal_unlock_placeholder(payload: Dictionary) -> void:
	portal_unlock_requested.emit(payload)
	print("Portal Unlock Event Triggered: ", JSON.stringify(payload))
	portal_result_received.emit(
		true,
		"PORTAL UNLOCKED\nOton Gold Death Mask Collection Restored.\nWaiting for organizer API integration.",
		payload
	)
