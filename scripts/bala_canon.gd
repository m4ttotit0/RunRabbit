extends Area2D

@export var velocidad: float = 380.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Moverse directamente hacia la izquierda en pantalla
	position.x -= velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		if get_tree().current_scene.has_method("mostrar_screamer"):
			get_tree().current_scene.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
		queue_free()
	elif body.is_in_group("canon") or body.name.begins_with("canion") or body.is_in_group("proyectil"):
		return
	else:
		queue_free()
