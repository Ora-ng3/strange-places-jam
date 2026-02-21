extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var direction: Vector3
var dir = 1
var preferred_dir = 1 # the turning preference of the goat
var turning: bool = false

func _ready() -> void:
	$AnimationPlayer.play("global/goat_anim")
	preferred_dir = round(randf()) * 2 - 1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if get_slide_collision_count():
		rotation.y += 5 * delta * preferred_dir * randf()
	elif turning:
		rotation.y += delta * dir * randf()
		
	
		
	direction = (transform.basis * Vector3.FORWARD) * randf()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	move_and_slide()


func _on_timer_timeout() -> void:
	$Timer.wait_time = randf()
	turning = not turning
	dir = round(randf()) * 2 - 1
	$Timer.start()
	
