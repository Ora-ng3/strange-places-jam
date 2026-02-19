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
	# Change mouse capture mode with escape
	if event.is_action_released("Escape"):
		toggle_mouse_mode()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_head(event)



func _physics_process(delta: float) -> void:
	movement(delta)
	if raycast.is_colliding():
		var col: Node = raycast.get_collider().get_parent() # collides with child bounding box area of objects
		if col.has_method("get_message"):
			$UI/Permanent.text = col.get_message()
			if not $UI/Popup.visible: $UI/Permanent.show()
		$UI/Center/Crosshair.rotation = PI/4
		if Input.is_action_just_released("Interact"):
			if col.is_in_group("doors") or col.is_in_group("levers"):
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
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
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
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))

func toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func popup(message: String):
	if message:
		$UI/Permanent.hide()
		$UI/Popup.text = message
		$UI/Popup.show()
		$UI/Popup/Timer.start()

func _on_popup_timer_timeout() -> void:
	$UI/Popup.hide()
