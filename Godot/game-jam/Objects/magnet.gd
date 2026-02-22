extends Node3D

func get_message(_player: CharacterBody3D) -> String:
	return "A very strong magnet."

func trigger(player: CharacterBody3D) -> String:
	player.has_magnet = true
	$BoundingBox/CollisionShape3D.disabled = true
	hide()
	return "Got Magnet!"
