extends StaticBody3D

const ZONE_RADIUS = 2 # radius of FrontZone and BackZone

@export var ExitFront: Node3D = null
@export var ExitBack: Node3D = null
@export var DoorID: global.DoorID

@onready var PortalEnter: = $PortalEnter
@onready var PortalExit: = $PortalExit
@onready var CollisionShape: = $CollisionShapeMain
@onready var FrontPivot: = $door/FrontPivot
@onready var BackPivot: = $door/FrontPivot/BackPivot

var current_portal: Portal3D = null
var current_room = false
var linked_door: StaticBody3D = null

var closed: bool = true
#var just_entered: bool = false

func _ready() -> void:
	global.id_to_node[DoorID] = self


func only_on_one_zone(): # just an XOR between both areas
		var front = $FrontZone.has_overlapping_bodies()
		var back = $BackZone.has_overlapping_bodies()
		return (front or back) and not (front and back)
		
# when the player clicks on the door
func trigger(player: CharacterBody3D) -> String:
	#open(transform.basis.z.dot(player_pos - global_position) > 0)
	if closed and not $AnimationPlayer.is_playing():
		if abs(scale.x - player.scale.x) > 0.01:
			if player.scale.x > scale.x:
				return "There's no way I'll fit in there."
			if player.scale.x < scale.x:
				return "Hmmm... Perhaps a bit too high for me right now."
		if only_on_one_zone(): # the player is only on one zone
			open($FrontZone.has_overlapping_bodies())
		else:
			return "Can't open from here"
	else:
		if not closed:
		#if $AnimationPlayer.is_playing():
			#return "Wait a bit"
		#else:
			close()
	return ""

func open(from_front: bool) -> void:
	if ExitFront == null:
		ExitFront = global.id_to_node[global.map[DoorID][0]]
	if ExitBack == null:
		ExitBack = global.id_to_node[global.map[DoorID][1]]
	linked_door = null # reset linked door
	
	$AudioOpen.play()
	if from_front:
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
		current_room = true
		start(PortalExit, linked_door.get_node("PortalEnter"))
		linked_door.open_linked(self)
		linked_door.get_parent().show()

func close():
	current_room = true
	linked_door.current_room = linked_door.get_parent() == get_parent()
	stop()
	linked_door.stop()
		


func start(portal: Portal3D, linked: Portal3D):
	# common code for both open and open_linked
	current_portal = portal
	closed = false
	CollisionShape.disabled = true
	portal.exit_portal = linked #CollisionShape.disabled = true set target portall
	portal.activate()
	portal.show()

func stop():
	close_animation()
	closed = true
	CollisionShape.disabled = false

func open_linked(door: Node3D) -> void:
	$AudioOpen.play()
	linked_door = door
	#just_entered = true
	start(PortalEnter, linked_door.PortalExit)

func close_animation():
	if $AnimationPlayer.is_playing():
		var anim = $AnimationPlayer.current_animation
		var frame = $AnimationPlayer.current_animation_position
		$AnimationPlayer.speed_scale = 3
		$AnimationPlayer.play_section_backwards(anim, 0, frame)
		$AnimationPlayer.speed_scale = 2
	else:
		if FrontPivot.rotation:
			$AnimationPlayer.play("CloseFront")
		elif BackPivot.rotation:
			$AnimationPlayer.play("CloseBack")
		else:
			print("problem: called close on a door that was not open")


func get_message(player: CharacterBody3D) -> String:
	#if not $AnimationPlayer.is_playing() and abs(scale.x - player.scale.x) < 0.01:
		#if closed:
			#if only_on_one_zone():
				#return "Click to open"
		#else:
				#return "Click to close"
	return ""

func _on_zone_exited(body: Node3D) -> void:
	if not closed and not body.is_in_portal > 0:
			# used to be just_entered and $GreaterZone.has_overlapping_bodies() which was when the player
			# left the door zone just after having entered a new place,
			# and the the player is in the greaterzone so didn't come back through the doorr
		close()
			

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if closed:
		$AudioClose.play(0.25)
		current_portal.deactivate()
		current_portal.hide()
		if not current_room:
			if $LargerArea.has_overlapping_bodies():
				current_room = true # bug fix hopefully
			else:
				get_parent().hide()


func _on_portal_zone_body_entered(body: Node3D) -> void:
	body.is_in_portal += 1


func _on_portal_zone_body_exited(body: Node3D) -> void:
	body.is_in_portal -= 1
