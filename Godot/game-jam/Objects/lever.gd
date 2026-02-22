extends Node3D

enum Orient {UP = 1, DOWN = 0}
@export var correct_value: Orient

var up: bool = false

func _ready():
	pass

func trigger(_player: CharacterBody3D) -> String:
	$AudioStreamPlayer3D.play(5.8)
	up = not up
	if up:
		$AnimationPlayer.play("up")
	else:
		$AnimationPlayer.play_backwards("up")
	get_parent().get_parent().check()
	return ""

func correct() -> bool:
	return correct_value == int(up)
