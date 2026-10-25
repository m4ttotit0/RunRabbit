extends Node2D

@export var bala_scene: PackedScene
@onready var punto_disparo: Marker2D = $PuntoDisparo
@onready var zona_proximidad: Area2D = $ZonaProximidad

var disparado: bool = false

func _ready() -> void:
	add_to_group("canon")
	zona_proximidad.body_entered.connect(_on_zona_proximidad_body_entered)

func _on_zona_proximidad_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("jugador")) and not disparado:
		disparado = true
		
		# Retardo troll opcional (ej: 0.1s para que justo esté en medio del salto)
		await get_tree().create_timer(0.1).timeout
		_disparar()

func _disparar() -> void:
	if bala_scene:
		var bala = bala_scene.instantiate()
		bala.global_position = punto_disparo.global_position
		# Lo agregamos al árbol principal para que se mueva independiente del cañón
		get_tree().current_scene.add_child(bala)
