extends Area2D

## Zona que suelta un ancla (RigidBody2D) cuando el jugador la pisa.
##
## Cada zona debe apuntar a SU PROPIA ancla. Antes todas usaban "../Ancla",
## por lo que en el nivel 4 las tres zonas soltaban la misma ancla y
## Ancla2 / Ancla3 nunca caían.
##
## Asigna el ancla en el Inspector (objeto_que_cae). Si se deja vacío se busca
## automáticamente por nombre: "Caida" -> "../Ancla", "Caida2" -> "../Ancla2", etc.
@export var objeto_que_cae: RigidBody2D

var ya_activado: bool = false


func _ready() -> void:
	if objeto_que_cae == null:
		objeto_que_cae = _buscar_ancla_por_nombre()

	body_entered.connect(_on_body_entered)
	if objeto_que_cae:
		# En el nodo Ancla (RigidBody2D) deben estar activados
		# "Contact Monitor" y "Max Contacts Reported" >= 1.
		objeto_que_cae.body_entered.connect(_on_roca_toco_algo)
	else:
		push_warning("%s: no se encontró el ancla que debe caer." % get_path())


func _buscar_ancla_por_nombre() -> RigidBody2D:
	# "Caida3" -> sufijo "3" -> "Ancla3"
	var sufijo := String(name).trim_prefix("Caida").trim_prefix("caida")
	var ancla := get_parent().get_node_or_null("Ancla" + sufijo) as RigidBody2D
	if ancla == null:
		ancla = get_parent().get_node_or_null("Ancla") as RigidBody2D
	return ancla


func _es_jugador(body: Node) -> bool:
	return body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador")


func _on_body_entered(body: Node2D) -> void:
	# Esta zona SOLO detecta al jugador para soltar el ancla, NUNCA mata aquí
	if ya_activado or not _es_jugador(body):
		return
	ya_activado = true
	if objeto_que_cae:
		objeto_que_cae.set_deferred("freeze", false)


func _on_roca_toco_algo(body: Node) -> void:
	if not _es_jugador(body):
		return
	if objeto_que_cae and objeto_que_cae.linear_velocity.y > 50:
		# Desconectamos para que no se dispare más de una vez en físicas
		if objeto_que_cae.body_entered.is_connected(_on_roca_toco_algo):
			objeto_que_cae.body_entered.disconnect(_on_roca_toco_algo)
		# call_deferred para no romper el motor de físicas a mitad del frame
		get_tree().current_scene.call_deferred("mostrar_screamer")
