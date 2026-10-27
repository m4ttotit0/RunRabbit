extends Area2D

@export var velocidad: float = 400.0
@export var direccion: Vector2 = Vector2.LEFT  # Sale disparada hacia la izquierda

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Mueve la bala continuamente en línea recta
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		if get_tree().current_scene.has_method("mostrar_screamer"):
			get_tree().current_scene.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
		queue_free()
	elif not body.is_in_group("canon"):
		# Se destruye si choca con paredes o suelo
		queue_free()
