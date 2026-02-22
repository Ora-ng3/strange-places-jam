extends Node3D

var unlocked: = false

func check():
	for i in $Levers.get_children():
		if not i.correct():
			print(i.name)
			if unlocked:
				block_door()
			return
	if not unlocked:
		open_door()

func block_door():
	unlocked = false
	var frame = -1
	if $AnimationPlayer.is_playing()	:
		frame = $AnimationPlayer.current_animation_position
	$AnimationPlayer.play_section_backwards("Retract", 0, frame)
	
func open_door():
	unlocked = true
	var frame = -1
	if $AnimationPlayer.is_playing()	:
		frame = $AnimationPlayer.current_animation_position
	$AnimationPlayer.play_section("Retract", frame)
