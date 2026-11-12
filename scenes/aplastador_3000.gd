extends Node2D

@onready var barrera: AnimatableBody2D = $AnimatableBody2D
@onready var colision_barrera: CollisionShape2D = $AnimatableBody2D/CollisionShape2D
@onready var animacion: AnimationPlayer = $AnimatableBody2D/AnimationPlayer

var ya_activada: bool = false

func _ready() -> void:
	barrera.visible = false
	colision_barrera.disabled = true

# Asegúrate de conectar la señal body_entered de "sensormuerte" a esta función
func _on_sensormuerte_body_entered(body: Node2D) -> void:
	if ya_activada or not body.is_in_group("jugador"):
		return
		
	ya_activada = true
	
	barrera.visible = true
	colision_barrera.set_deferred("disabled", false)

	animacion.play("aparecer")
	
	await animacion.animation_finished
	
	animacion.play("aplastar")
