extends Area3D

@export_multiline var message_to_display: String = "Am I locked in this train ?"
var has_been_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print("Player entered message zone")
	if not has_been_triggered and body.has_method("popup"):
		print("Sending message")
		body.popup(message_to_display)
		has_been_triggered = true
