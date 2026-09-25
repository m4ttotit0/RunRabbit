extends Area2D

var activada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# El paréntesis agrupa ambas comprobaciones
	if (body.name == "Player" or body.is_in_group("jugador")) and not activada:
		activada = true
		
		# Esperamos 1 segundo antes de comprobar si sigue en el agujero
		await get_tree().create_timer(1.0).timeout
		
		# Verificamos si el conejito todavía está dentro del área
		var cuerpos_dentro = get_overlapping_bodies()
		if body in cuerpos_dentro:
			print(">>> Reinicio provocado por: TRAMP_2.GD")
			get_tree().reload_current_scene()
