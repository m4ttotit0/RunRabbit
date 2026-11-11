extends Node2D

@onready var animador: AnimationPlayer = $AnimationPlayer
@onready var sensor: Area2D = $SensorAbordaje

var activado: bool = false

func _ready() -> void:
	sensor.body_entered.connect(_on_sensor_body_entered)

func _on_sensor_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador")) and not activado:
		activado = true
		
		# Pequeña pausa de 0.2s para que termine de aterrizar bien el salto
		await get_tree().create_timer(0.2).timeout
		animador.play("subir")
