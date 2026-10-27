extends Node2D

@onready var animador: AnimationPlayer = $AnimatableBody2D/AnimationPlayer
@onready var sensor: Area2D = $SensorPisar

var activado: bool = false

func _ready() -> void:
	sensor.body_entered.connect(_on_sensor_body_entered)

func _on_sensor_body_entered(body: Node2D) -> void:
	# Verifica que sea el jugador y que no se haya activado antes
	if (body.name == "Player" or body.is_in_group("jugador")) and not activado:
		activado = true
		
		# Micro-pausa ragebait opcional: 0.1 segundos para que alcance a apoyarse
		await get_tree().create_timer(0.08).timeout
		
		# Dispara tu animación de caída que ya armaste
		animador.play("caida")
