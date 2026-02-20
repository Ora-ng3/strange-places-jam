extends BoneAttachment3D

@export var train_room: Node 

func get_message(_player: CharacterBody3D) -> String:
	return train_room.get_exit_door_message()

func trigger(_player: CharacterBody3D) -> String:
	print("exit door clicked !")
	return train_room.trigger_exit_door()
