extends Area2D

@export var bloque_invisible: StaticBody2D
@export var collision_bloque: CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("player"):
		await get_tree().create_timer(3).timeout
		
		if bloque_invisible:
			bloque_invisible.visible = true
		if collision_bloque:
			collision_bloque.disabled = false
