extends Node2D

@onready var animador: AnimationPlayer = $AnimationPlayer
@onready var sensor_paso: Area2D = $SensorPaso
@onready var zona_danio: Area2D = $bloque/ZonaDanio

var activado: bool = false

func _ready() -> void:
	sensor_paso.body_entered.connect(_on_sensor_paso_body_entered)
	zona_danio.body_entered.connect(_on_zona_danio_body_entered)

func _on_sensor_paso_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador")) and not activado:
		activado = true
		
		# Retardo troll mínimo para que el conejo alcance a meter la cabeza abajo
		await get_tree().create_timer(0.05).timeout
		animador.play("caida_techo")

func _on_zona_danio_body_entered(body: Node2D) -> void:
	# Si toca al conejo mientras baja, lo mata en el acto
	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		if get_tree().current_scene.has_method("mostrar_screamer"):
			get_tree().current_scene.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
