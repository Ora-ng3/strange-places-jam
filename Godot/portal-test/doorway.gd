extends StaticBody3D

@export var ExitFront: Node3D
@export var ExitBack: Node3D

@onready var Player = $"../Player"
@onready var Portal: = $Portal3D
@onready var CollisionShape: = $CollisionShapeMain

enum {FRONT, BACK, AWAY}
var placement = AWAY
var closed: bool = true
var linked_door: StaticBody3D = null
var cooldown: bool = false # used to avoid teleporting back immediately


func open(player_pos: Vector3) -> void:
	if closed:
		closed = false
		if transform.basis.z.dot(player_pos - global_position) > 0:
			linked_door = ExitBack
			$AnimationPlayer.play("OpenFront")
			linked_door.get_node("AnimationPlayer").play("OpenFront")
		else:
			linked_door = ExitFront
			$AnimationPlayer.play("OpenBack")
			linked_door.get_node("AnimationPlayer").play("OpenBack")
		
		CollisionShape.disabled = true
		linked_door.CollisionShape.disabled = true
		
		Portal.exit_portal = linked_door.get_node("Portal3D") # set target portall
		linked_door.Portal.exit_portal = Portal
		linked_door.Portal.rotate_y(PI) # orientation bug
		Portal.activate()
		linked_door.Portal.activate()
		Portal.show()
		linked_door.Portal.show()

#
#func _on_area_exited(body: Node3D) -> void:
	#placement = AWAY
	##cooldown = false
	#if $AreaBack.has_overlapping_bodies(): # entered through front
		#placement = FRONT
		#teleport(body)
	#if $AreaFront.has_overlapping_bodies():
		#placement = BACK
		#teleport(body)
#
#func teleport(player: CharacterBody3D) -> void:
	#if not closed:
		#linked_door.cooldown = true
		#var origin = position
		#var dest = linked_door.position
		#player.position += dest - origin
