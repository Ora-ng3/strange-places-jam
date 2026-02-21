extends Node3D

var open: bool = false

func trigger(player: CharacterBody3D) -> String:
	if not open:
		if player.has_key:
			open = true
			$AnimationPlayer.play("open")
			$CollisionShape3D.disabled = true
		else:
			return "Locked."
	return ""
