extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var activado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if activado:
		return
	
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		activado = true
		
		# Le avisa al nivel que actualice la posición de respawn
		if get_tree().current_scene.has_method("actualizar_checkpoint"):
			get_tree().current_scene.actualizar_checkpoint(global_position)
		
		# Feedback visual opcional: cambia de color o brilla al activarse
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.15)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
