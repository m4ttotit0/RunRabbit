extends StaticBody2D

const BALA_SCENE = preload("res://scenes/bala_canon.tscn")

@onready var timer: Timer = find_child("Timer", false, false)
@onready var punto_de_disparo: Marker2D = $PuntoDisparo
@onready var zona_proximidad: Area2D = find_child("ZonaProximidad", false, false)

var disparado: bool = false

func _ready() -> void:
	# MODO 1: Si el cañón tiene un Timer (como en el Nivel 3), dispara en bucle
	if timer:
		# Conecta la señal del timer si no está conectada
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
		timer.start()
	
	# MODO 2: Si tiene ZonaProximidad (como en Nivel 2 y 4), dispara al acercarse
	if zona_proximidad:
		zona_proximidad.body_entered.connect(_on_zona_proximidad_body_entered)

func _on_timer_timeout() -> void:
	disparar()

func _on_zona_proximidad_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador")) and not disparado:
		disparado = true
		await get_tree().create_timer(0.08).timeout
		disparar()

func disparar() -> void:
	if BALA_SCENE and punto_de_disparo:
		var bala = BALA_SCENE.instantiate()
		
		# 1. PRIMERO la agregamos a la escena para que tenga padre y espacio global
		get_tree().current_scene.add_child(bala)
		
		# 2. SEGUNDO fijamos su posición y rotación global exacta
		bala.global_position = punto_de_disparo.global_position
		bala.rotation = global_rotation
