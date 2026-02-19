extends Node3D

var up: bool = false

func _ready():
	pass

func trigger() -> String:
	up = not up
	if up:
		$AnimationPlayer.play("up")
	else:
		$AnimationPlayer.play_backwards("up")
	return ""
