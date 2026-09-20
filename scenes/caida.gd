extends Area2D

# Arrastra aquí el RigidBody2D que debe caer
@onready var objeto_que_cae: RigidBody2D = $"../Ancla" as RigidBody2D

var ya_activado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and not ya_activado:
		ya_activado = true
		
		if objeto_que_cae:
			# Usa set_deferred para cambiar la física de forma segura
			objeto_que_cae.set_deferred("freeze", false)
			await get_tree().create_timer(1).timeout #Para que se vea pue
			get_tree().reload_current_scene()
