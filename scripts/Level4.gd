extends LevelBase

# Variable para recordar dónde debe reaparecer
var respawn_position: Vector2 = Vector2.ZERO
var tiene_checkpoint: bool = false

func _ready() -> void:
	win_panel.visible = false
	screamer.hide()
	
	# Guardamos la posición inicial por defecto
	if is_instance_valid(player1):
		respawn_position = player1.global_position

	end_point.body_entered.connect(_on_end_point_body_entered)

func actualizar_checkpoint(nueva_pos: Vector2) -> void:
	respawn_position = nueva_pos
	tiene_checkpoint = true

func reaparecer_jugador() -> void:
	jugador_muerto = false
	
	# Devolvemos al jugador al punto guardado y reactivamos su física
	if is_instance_valid(player1):
		player1.global_position = respawn_position
		player1.velocity = Vector2.ZERO
		player1.set_physics_process(true)
		player1.set_process_input(true)
		player1.show()

func mostrar_screamer() -> void:
	if jugador_muerto or win_panel.visible:
		return

	jugador_muerto = true

	player1.velocity = Vector2.ZERO
	player1.set_physics_process(false)
	player1.set_process_input(false)

	# Si toca screamer
	if randf() < 0.2:
		screamer.show()
		await get_tree().create_timer(1.5).timeout
		screamer.hide()

	# Si tiene checkpoint, reaparece en el punto sin reiniciar la escena
	if tiene_checkpoint:
		reaparecer_jugador()
	else:
		get_tree().call_deferred("reload_current_scene")
func _init() -> void:
	level_id = 4
	supports_two_players = false
