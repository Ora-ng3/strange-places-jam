extends Node3D

@export var anim_player: AnimationPlayer

var is_cabin_door_open: bool = false
var is_exit_door_open: bool = false

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
		anim_player.play_backwards("cabin_door_opening")
		is_cabin_door_open = false
	else:
		anim_player.play("cabin_door_opening")
		is_cabin_door_open = true
		
	return ""
	
func trigger_exit_door() -> String:
	if is_exit_door_open:
		anim_player.play_backwards("exit_door_opening")
		is_exit_door_open = false
	else:
		anim_player.play("exit_door_opening")
		is_exit_door_open = true
		
	return ""
