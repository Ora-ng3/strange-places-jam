extends CharacterBody3D

var on_menu = true
var on_end = false

const SPEED = 5.0
#const JUMP_VELOCITY = 5
const LOOK_SENSITIVITY = 0.003
const GRAVITY = 100 * Vector3.DOWN
const RUN_FACTOR = 2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D

var is_in_portal: int = 0 # used by doorwayss
var has_magnet = false
var has_key = false

func _ready() -> void:
	print("player loaded !")
	$MeshInstance3D.hide()

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not on_end:
			rotate_head(event)


func end(pos: Vector3):
	on_end = true
	var tween: = get_tree().create_tween()
	tween.tween_property($Head, "rotation", Vector3(0, 0, 0), 1)
	tween.parallel().tween_property($Head/Camera3D, "rotation", Vector3(0, 0, 0), 1)
	var p = global_position
	tween.tween_property(self, "global_position", Vector3(p.x, p.y, pos.z + 12), 3)
	await(tween.finished)
	$end_screen.show()

var just_hovered: bool = false
func _physics_process(delta: float) -> void:
	if not (on_menu or on_end) :
		movement(delta)
		if raycast.is_colliding():
			var col: Node = raycast.get_collider().get_parent() # collides with child bounding box area of objects
			if col.has_method("get_message"):
				$UI/Permanent.text = col.get_message(self)
				if not $UI/Popup.visible: $UI/Permanent.show()
			if not just_hovered:	
				just_hovered = true
				$UI/AnimationPlayer.play("hover")	
			if Input.is_action_just_released("Interact"):
				if col.is_in_group("interactables"):
					$UI.popup(col.trigger(self))
					
		else:
			if just_hovered:
				just_hovered = false
				$UI/AnimationPlayer.play_backwards("hover")
			$UI/Center/Crosshair.rotation = 0
			$UI/Permanent.hide()

func movement(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += GRAVITY * delta
		
	#  Jump
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * get_scale_factor()
		velocity.z = direction.z * SPEED * get_scale_factor()
		if Input.is_action_pressed("Run"):
			velocity.x *= RUN_FACTOR
			velocity.z *= RUN_FACTOR
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func rotate_head(event: InputEventMouseMotion) -> void:
	head.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
	camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))



func get_scale_factor():
	if scale.x > 1.1  	:
		return 2
	elif scale.x < 0.9:
		return 0.3
	else:
		return 1
