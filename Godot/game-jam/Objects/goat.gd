extends CharacterBody3D


const SPEED = 4.5
const JUMP_VELOCITY = 4.5

var direction: Vector3
var dir = 1
var preferred_dir = 1 # the turning preference of the goat
var turning: bool = false

func _ready() -> void:
	$AnimationPlayer.play("goat_anim")
	preferred_dir = round(randf()) * 2 - 1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if $RayCast3D.is_colliding():
		rotation.y += 5 * delta * preferred_dir * randf()
	elif turning:
		rotation.y += 3 * delta * dir * randf()
		
	
		
	direction = (transform.basis * Vector3.FORWARD) * randf()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	move_and_slide()


func _on_timer_timeout() -> void:
	if randf() < 0.2:
		if get_parent().visible:
			$Audio.play()
	$Timer.wait_time = randf() * (2 if not turning else 1)
	turning = not turning
	dir = round(randf()) * 2 - 1
	$Timer.start()

func trigger(player: CharacterBody3D):
	return "Useless goat."
