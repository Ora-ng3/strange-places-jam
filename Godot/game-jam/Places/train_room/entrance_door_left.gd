extends MeshInstance3D

@export var train_room: Node 

func get_message(_player: CharacterBody3D) -> String:
	return train_room.get_cabin_door_message()

func trigger(_player: CharacterBody3D) -> String:
	print("entrance left door clicked !")
	return train_room.trigger_cabin_doors()
