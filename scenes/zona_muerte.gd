extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Solo reinicia si quien cayó al abismo es el jugador
	if body.name == "Player" or body.is_in_group("jugador"):
		get_tree().call_deferred("reload_current_scene")
	else:
		# Si cae el bloque roto o cualquier otra cosa, simplemente lo elimina del juego
		body.queue_free()
