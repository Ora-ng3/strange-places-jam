extends Node3D


func trigger(player: CharacterBody3D):
	print("hth")
	if not get_parent().lateral_open:
		return "Locked... There must be an emergency button somewhere."
	return ""
