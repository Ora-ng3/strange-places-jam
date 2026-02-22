@tool
extends MeshInstance3D

@export var strength: float = 1:
	set(new_value):
		strength = new_value
		$OmniLight3D.light_energy = new_value
