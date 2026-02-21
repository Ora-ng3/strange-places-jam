extends Control

func _unhandled_input(event: InputEvent) -> void:
	# Change mouse capture mode with escape
	if event.is_action_released("Escape"):
		get_tree().paused = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		toggle_mouse_mode()
	

func toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	$Debug/Label.text = "FPS: " + str(Engine.get_frames_per_second())
