extends Node2D

const BALA_SCENE = preload("res://scenes/bala_canon.tscn") # Cambia por tu escena de bala

@onready var timer = $Timer
@onready var punto_de_disparo = $PuntoDisparo # O el nodo de donde sale la bala

func _ready() -> void:
	# Si quieres que dispare en bucle continuo al iniciar:
	timer.start()

# Esta función se ejecuta cada vez que el Timer llega a cero
func _on_timer_timeout() -> void:
	disparar()

func disparar() -> void:
	var bala = BALA_SCENE.instantiate()
	# Añade la bala a la escena principal para que no se mueva con el cañón
	get_tree().current_scene.add_child(bala)
	bala.global_position = punto_de_disparo.global_position
	bala.rotation = global_rotation
