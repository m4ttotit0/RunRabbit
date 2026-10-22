extends Node2D

const LEVEL_ID := 2

@onready var player1: CharacterBody2D = $Player
var jugador_muerto: bool = false

# Nota: si tienes un TextureRect para el screamer en la UI, pon su ruta aquí:
# @onready var screamer: TextureRect = $UI/Screamer

func _ready() -> void:
	# Si agregas el nodo visual del screamer, asegúrate de ocultarlo al inicio:
	# if has_node("UI/Screamer"):
	# 	$UI/Screamer.hide()
	pass

func mostrar_screamer() -> void:
	if jugador_muerto:
		return

	jugador_muerto = true

	# Congelar al jugador para que no siga cayendo
	if is_instance_valid(player1):
		player1.velocity = Vector2.ZERO
		player1.set_physics_process(false)
		player1.set_process_input(false)

	# 50% de probabilidad de mostrar el susto
	if randf() < 0.2:
		if has_node("UI/Screamer"):
			$UI/Screamer.show()
			await get_tree().create_timer(1.5).timeout

	get_tree().call_deferred("reload_current_scene")
