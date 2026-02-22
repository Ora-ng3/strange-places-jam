extends Node3D

var lateral_open: bool = false

@export var anim_player: AnimationPlayer
@export var left_cabin_door: StaticBody3D
@export var right_cabin_door: StaticBody3D

var is_cabin_door_open: bool = false
var is_exit_door_open: bool = false
var is_lateral_door_open: bool = false

func get_red_button_message() -> String:
	if is_lateral_door_open:
		return "Close lateral doors"
	else:
		return "Open lateral doors"
		
func get_cabin_door_message() -> String:
	if is_cabin_door_open:
		return "Close doors"
	else:
		return "Open doors"
		
func get_exit_door_message() -> String:
	if is_exit_door_open:
		return "Close exit"
	else:
		return "Open exit"

func trigger_cabin_doors() -> String:
	if is_cabin_door_open:
		left_cabin_door.set_collision_layer_value (1, true)
		right_cabin_door.set_collision_layer_value (1, true)
		anim_player.play_backwards("cabin_door_opening")
		is_cabin_door_open = false
	else:
		left_cabin_door.set_collision_layer_value (1, false)
		right_cabin_door.set_collision_layer_value (1, false)
		anim_player.play("cabin_door_opening")
		is_cabin_door_open = true
		
	return ""


func trigger_red_button() -> String:
	$AudioStreamPlayer3D.play()
	if is_lateral_door_open:
		lateral_open = false
		anim_player.play_backwards("lateral_doors_opening")
		is_lateral_door_open = false
	else:
		lateral_open = true
		anim_player.play("lateral_doors_opening")
		is_lateral_door_open = true
		
	return ""
	
func trigger_exit_door() -> String:
	if is_exit_door_open:
		anim_player.play_backwards("exit_door_opening")
		is_exit_door_open = false
	else:
		anim_player.play("exit_door_opening")
		is_exit_door_open = true
		
	return ""
