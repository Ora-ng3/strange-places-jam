extends MeshInstance3D

@export var train_room: Node 

func get_message(_player: CharacterBody3D) -> String:
	return train_room.get_red_button_message()

func trigger(_player: CharacterBody3D) -> String:
	print("red_button clicked !")
	return train_room.trigger_red_button()
