extends Area2D

## Estrella recolectable. Al tocarla el jugador, emite la señal "collected"
## y se destruye a sí misma.

signal collected


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		collected.emit()
		queue_free()
