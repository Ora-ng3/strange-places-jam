extends Node3D

var open: bool = false

func trigger(player: CharacterBody3D) -> String:
	if not open:
		if player.has_key:
			open = true
			$AudioOpen.play()
			$AnimationPlayer.play("open")
			$CollisionShape3D.disabled = true
		else:
			$AudioRattle.play()
			return "Locked."
	return ""
