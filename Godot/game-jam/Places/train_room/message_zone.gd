extends Area3D

@export_multiline var message_to_display: String = ""
var has_been_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not has_been_triggered and body.has_method("popup"):
		body.popup(message_to_display)
		has_been_triggered = true
