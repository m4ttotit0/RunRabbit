extends Area2D

# Arrastra aquí el RigidBody2D que debe caer
@onready var objeto_que_cae: RigidBody2D = $"../Ancla" as RigidBody2D

var ya_activado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if objeto_que_cae:
		# En el nodo "Ancla" (RigidBody2D):
		# Activar "Contact Monitor" y subir "Max Contacts Reported" a 1 o más en el Inspector.
		objeto_que_cae.body_entered.connect(_on_roca_toco_algo)

func _on_body_entered(body: Node2D) -> void:
	# Esta zona SOLO detecta al jugador para soltar el bloque, NUNCA mata aquí
	if (body.name == "Player" or body.is_in_group("jugador")) and not ya_activado:
		ya_activado = true
		if objeto_que_cae:
			objeto_que_cae.set_deferred("freeze", false)

func _on_roca_toco_algo(body: Node) -> void:
	if body.name == "Player" or body.is_in_group("jugador"):
		if objeto_que_cae and objeto_que_cae.linear_velocity.y > 50:
			# Desconectamos para que no se dispare más de una vez en físicas
			if objeto_que_cae.body_entered.is_connected(_on_roca_toco_algo):
				objeto_que_cae.body_entered.disconnect(_on_roca_toco_algo)
			
			print(">>> Reinicio provocado por: CAIDA.GD (Roca)")
			# Usamos call_deferred para que espere al final del frame y no rompa el motor de físicas
			get_tree().call_deferred("reload_current_scene")
