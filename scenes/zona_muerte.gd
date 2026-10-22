
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		get_tree().current_scene.mostrar_screamer()
	else:
		body.queue_free()
