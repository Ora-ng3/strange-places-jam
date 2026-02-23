extends Control

var on_start_menu = true
@onready var player = get_parent()

func _ready() -> void:
	set_render_scale(1)

func _unhandled_input(event: InputEvent) -> void:
	# Change mouse capture mode with escape
	if event.is_action_released("Escape"):
		get_tree().paused = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
		if $Settings.visible:
			$Settings.hide()
		else:
			if not on_start_menu:
				$Menu.visible = !$Menu.visible
				toggle_mouse_mode()	
				player.on_menu = !player.on_menu
	
func start():
	on_start_menu = false
	player.on_menu = false
	get_tree().paused = false
	$Menu/Play.text = "UNPAUSE"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Menu.hide()
	

func toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	$Debug/FPS.text = "FPS: " + str(Engine.get_frames_per_second())

func popup(message: String):
	if message:
		$Permanent.hide()
		$Popup.text = message
		$Popup.show()
		$Popup/Timer.start()
		
func _on_popup_timer_timeout() -> void:
	$Popup.hide()


 #AFAIK it's not possible to globally disable shadows. You can add the Light3D nodes you want to enable/disable shadows to the same group (for example, lights) and then call SceneTree.set_group() like:
#
#extends Node
#
#
#func set_shadows(enabled:bool) -> void:
	#get_tree().set_group("lights", "shadow_enabled", enabled)
#
#If you don't want to manually add each light to a group you can create an autoload with this:
#
#extends Node
#
#
#func _enter_tree() -> void:
	#get_tree().node_added.connect(func(node:Node):
		#if node is Light3D:
			#node.add_to_group("lights")
	#)


func _on_play_pressed() -> void:
	start()


func _on_settings_pressed() -> void:
	$Settings.visible = true


func _on_close_pressed() -> void:
	$Settings.visible = false


func _on_close_credits_pressed() -> void:
	$Credits.visible = false


func _on_view_credits_pressed() -> void:
	$Credits.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_show_debug_pressed() -> void:
	if $Debug.visible :
		$Debug.visible = false
	else :
		$Debug.visible = true


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		set_render_scale($Settings/HSlider.value / 50)
	
func set_render_scale(scale: float) -> void:
	# Clamp between 0.5 and 1.0 (or whatever you want)
	scale = clamp(scale, 0.25, 2.0)

	var vp := get_viewport()

	# This API exists in Godot 4: it scales the 3D rendering resolution.
	# UI (2D) can remain at window resolution depending on your setup.
	vp.scaling_3d_scale = scale
