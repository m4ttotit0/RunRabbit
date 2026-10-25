extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Si es el jugador, muere y activa la lógica de reinicio/screamer
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		get_tree().current_scene.mostrar_screamer()
	elif body is CharacterBody2D or body is RigidBody2D:
		# Solo elimina proyectiles o enemigos que caigan al vacío, ignorando plataformas
		body.queue_free()
