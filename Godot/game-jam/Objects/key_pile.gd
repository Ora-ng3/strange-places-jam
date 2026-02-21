extends StaticBody3D

var already_clicked: bool = false

func trigger(_player: CharacterBody3D):
	already_clicked = true
	return "There's no way I'm searching through there by hand"

func get_message(_player: CharacterBody3D):
	if already_clicked:
		return ""
	return "A pile of fake keys."
