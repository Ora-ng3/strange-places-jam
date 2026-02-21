extends Node3D

func trigger(player: CharacterBody3D) -> String:
	player.has_magnet = true
	$BoundingBox/CollisionShape3D.disabled = true
	hide()
	return "Got Magnet!"
