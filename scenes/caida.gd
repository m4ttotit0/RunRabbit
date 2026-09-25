extends Area2D

# Arrastra aquí el RigidBody2D que debe caer
@onready var objeto_que_cae: RigidBody2D = $"../Ancla" as RigidBody2D

var ya_activado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if objeto_que_cae:
		# IMPORTANTE: en el nodo "Ancla" (RigidBody2D) hay que activar
		# "Contact Monitor" y subir "Max Contacts Reported" a 1 o más
		# en el Inspector, si no esta señal nunca se dispara.
		objeto_que_cae.body_entered.connect(_on_roca_toco_algo)

func _on_body_entered(body: Node2D) -> void:
	# Esta zona SOLO suelta la roca; ya NO mata por sí sola.
	if body.is_in_group("jugador") and not ya_activado:
		ya_activado = true
		if objeto_que_cae:
			objeto_que_cae.set_deferred("freeze", false)

func _on_roca_toco_algo(body: Node) -> void:
	# Muere solo si la roca REALMENTE toca al jugador.
	if body.is_in_group("jugador"):
		get_tree().reload_current_scene()
