extends Node3D

@export var connected_platform: Node

@onready var wheel = $rudder/Wheel

const ANIM_TIME = 1
var running: bool = false

func _ready():
	$Timer.wait_time = ANIM_TIME

func trigger(_player: CharacterBody3D) -> String:
	if not running:
		$AudioStreamPlayer3D.play()
		running = true
		$Timer.start()
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween1.tween_property(wheel, "rotation",
							wheel.rotation + Vector3(-PI/3, 0, 0), ANIM_TIME)
		tween2.tween_property(connected_platform, "rotation",
							connected_platform.rotation + Vector3(0, PI/3, 0), ANIM_TIME)

	return ""


func _on_timer_timeout() -> void:
	running = false
