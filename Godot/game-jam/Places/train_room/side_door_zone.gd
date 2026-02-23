extends Node3D

func update():
	for i in get_children():
		i.get_child(0).disabled = get_parent().lateral_open

func trigger(player: CharacterBody3D):
	print("hth")
	if not get_parent().lateral_open:
		return "Locked... There must be an emergency button somewhere."
	return ""
