extends Area2D

## Bandera de checkpoint. Al tocarla avisa al nivel (LevelBase), que guarda
## la posición en GameData. Si el jugador muere después, el nivel se recarga
## completo y el jugador reaparece aquí.

@onready var sprite: CanvasItem = get_node_or_null("AnimatedSprite2D")

var activado: bool = false


func _ready() -> void:
	add_to_group("checkpoints")
	body_entered.connect(_on_body_entered)


## Lo usa LevelBase al recargar el nivel para que la bandera ya tomada
## no vuelva a activarse.
func marcar_activado() -> void:
	activado = true


func _on_body_entered(body: Node2D) -> void:
	if activado:
		return

	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		activado = true

		var nivel := get_tree().current_scene
		if nivel.has_method("actualizar_checkpoint"):
			nivel.actualizar_checkpoint(global_position)

		# Feedback visual: brilla al activarse
		if sprite:
			var tween := create_tween()
			tween.tween_property(sprite, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.15)
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
