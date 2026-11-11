extends Node2D

func _on_body_entered(body: Node) -> void:
	# Verificamos si lo que entró al área es el Jugador
	if body.name == "Jugador": 
		
		await get_tree().create_timer(3).timeout
		
		$"invisible".show()
