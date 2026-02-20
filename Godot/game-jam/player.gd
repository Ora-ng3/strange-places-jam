extends CharacterBody3D


const SPEED = 5.0
#const JUMP_VELOCITY = 5
const LOOK_SENSITIVITY = 0.003
#const GRAVITY = 17 * Vector3.DOWN
const RUN_FACTOR = 2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D

var is_in_portal: int = 0 # used by doorwayss


func _ready() -> void:
	print("player loaded !")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#$MeshInstance3D.hide()

func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event)



func _physics_process(delta: float) -> void:
	movement(delta)
	if raycast.is_colliding():
		var col: Node = raycast.get_collider().get_parent() # collides with child bounding box area of objects
		if col.has_method("get_message"):
			$UI/Permanent.text = col.get_message(self)
			if not $UI/Popup.visible: $UI/Permanent.show()
		$UI/Center/Crosshair.rotation = PI/4
		if Input.is_action_just_released("Interact"):
			if col.is_in_group("doors"):
				popup(col.trigger(self))
			if col.is_in_group("levers") or col.is_in_group("doors_non_portal"):
				popup(col.trigger())
				
	else:
		$UI/Center/Crosshair.rotation = 0
		$UI/Permanent.hide()

func movement(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#  Jump
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * get_scale_factor()
		velocity.z = direction.z * SPEED * get_scale_factor()
		#if Input.is_action_pressed("Run"):
			#velocity.x *= RUN_FACTOR
			#velocity.z *= RUN_FACTOR
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func rotate_head(event: InputEventMouseMotion) -> void:
	head.rotate_y(-event.relative.x * LOOK_SENSITIVITY)
	camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))


func popup(message: String):
	if message:
		$UI/Permanent.hide()
		$UI/Popup.text = message
		$UI/Popup.show()
		$UI/Popup/Timer.start()

func get_scale_factor():
	if scale.x == 1:
		return 1
	if scale.x > 1:
		scale = Vector3(5,5,5) # just in case there are rounding errors
		return 2
	if scale.x < 1:
		scale = Vector3(0.2,0.2,0.2)
		return 0.3

func _on_popup_timer_timeout() -> void:
	$UI/Popup.hide()
