extends StaticBody3D

var already_clicked: bool = false

func trigger(player: CharacterBody3D):
	already_clicked = true # message only appears on first hover
	if player.has_key:
		return "There doesn't seem to be anything more to find..."
	if player.has_magnet:
		player.has_key = true
		return "Got key!"
	return "There's no way I'm searching through there by hand"

func get_message(_player: CharacterBody3D):
	if already_clicked:
		return ""
	return "A pile of fake keys."
