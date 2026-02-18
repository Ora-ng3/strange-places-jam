extends StaticBody3D


@export var ExitFront: Node3D
@export var ExitBack: Node3D

@onready var PortalEnter: = $PortalEnter
@onready var PortalExit: = $PortalExit
@onready var CollisionShape: = $CollisionShapeMain
@onready var FrontPivot: = $door/FrontPivot
@onready var BackPivot: = $door/FrontPivot/BackPivot


var linked_door: StaticBody3D = null

var closed: bool = true
var just_entered: bool = false

# when the player opens the door
func open(player_pos: Vector3) -> void:
	if closed:
		if transform.basis.z.dot(player_pos - global_position) > 0:
			linked_door = ExitBack
			$AnimationPlayer.play("OpenFront")
			linked_door.get_node("AnimationPlayer").play("OpenFront")
		else:
			linked_door = ExitFront
			$AnimationPlayer.play("OpenBack")
			linked_door.get_node("AnimationPlayer").play("OpenBack")
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
	close_animation()
	closed = true
	CollisionShape.disabled = false
	portal.deactivate()
	portal.hide()

func open_linked(door: Node3D) -> void:
	linked_door = door
	just_entered = true
	start(PortalEnter, linked_door.PortalExit)

func close_animation():
	if FrontPivot.rotation:
		$AnimationPlayer.play("CloseFront")
	elif BackPivot.rotation:
		$AnimationPlayer.play("CloseBack")
	else:
		print("problem: called close on a door that was not open")
		

func _on_zone_exited(body: Node3D) -> void:
	if just_entered and $GreaterZone.has_overlapping_bodies(): 
		# left the door zone just after having entered a new place,
		# and the the player is in the greaterzone so didn't come back through the doorr
		print(get_node("../..").name)
		stop(PortalEnter)
		linked_door.stop(linked_door.PortalExit)
		just_entered = false
