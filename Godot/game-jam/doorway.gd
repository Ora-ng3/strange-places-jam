extends StaticBody3D


@export var ExitFront: Node3D = null
@export var ExitBack: Node3D = null
@export var DoorID: global.DoorID

@onready var PortalEnter: = $PortalEnter
@onready var PortalExit: = $PortalExit
@onready var CollisionShape: = $CollisionShapeMain
@onready var FrontPivot: = $door/FrontPivot
@onready var BackPivot: = $door/FrontPivot/BackPivot

var portal_to_disable: Portal3D = null

var linked_door: StaticBody3D = null

var closed: bool = true
#var just_entered: bool = false

func _ready() -> void:
	global.id_to_node[DoorID] = self

# when the player opens the door
func open(player_pos: Vector3) -> void:
	if closed:
		if ExitFront == null:
			ExitFront = global.id_to_node[global.map[DoorID][0]]
		if ExitBack == null:
			ExitBack = global.id_to_node[global.map[DoorID][1]]
		linked_door = null # reset linked door
			
		if transform.basis.z.dot(player_pos - global_position) > 0:
			$AnimationPlayer.play("OpenFront")
			if ExitBack != null:
				linked_door = ExitBack
				linked_door.get_node("AnimationPlayer").play("OpenFront")
		else:
			$AnimationPlayer.play("OpenBack")
			if ExitFront != null:
				linked_door = ExitFront
				linked_door.get_node("AnimationPlayer").play("OpenBack")
		if linked_door != null:
			start(PortalExit, linked_door.get_node("PortalEnter"))
			linked_door.open_linked(self)

func start(portal: Portal3D, linked: Portal3D):
	# common code for both open and open_linked
	closed = false
	CollisionShape.disabled = true
	portal.exit_portal = linked # set target portall
	portal.activate()
	portal.show()

func stop(portal: Portal3D):
	portal_to_disable = portal
	close_animation()
	closed = true
	CollisionShape.disabled = false

func open_linked(door: Node3D) -> void:
	linked_door = door
	#just_entered = true
	start(PortalEnter, linked_door.PortalExit)

func close_animation():
	if FrontPivot.rotation:
		$AnimationPlayer.play("CloseFront")
	elif BackPivot.rotation:
		$AnimationPlayer.play("CloseBack")
	else:
		print("problem: called close on a door that was not open")
		

func _on_zone_exited(body: Node3D) -> void:
	if not closed and global_position.distance_squared_to(body.global_position) < 9:
			# used to be just_entered and $GreaterZone.has_overlapping_bodies() which was when the player
			# left the door zone just after having entered a new place,
			# and the the player is in the greaterzone so didn't come back through the doorr
			stop(PortalEnter)
			linked_door.stop(linked_door.PortalExit)
			#just_entered = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("Close"):
		portal_to_disable.deactivate()
		portal_to_disable.hide()
