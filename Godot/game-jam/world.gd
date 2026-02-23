extends Node3D
#
#func _ready() -> void:
	#$Camera3D.current = true
	#
#var nb_rooms = 7 # without starting hallway
#var i = 0
#func _process(delta: float) -> void:
	#$Camera3D.current = true
	#if i < nb_rooms:
		#var room =  get_child(2+i)
		#print(room.name)
		#$Camera3D.global_position = room.global_position
		#i+=1
		#room.hide()
	#if i == nb_rooms:
		#$Player.camera.current = true
