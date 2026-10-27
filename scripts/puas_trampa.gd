extends Area2D

# Elegir la dirección hacia donde salen las púas desde el Inspector:
# (0, -1) = Hacia arriba (suelo normal)
# (-1, 0) = Hacia la izquierda (pared derecha)
# (1, 0)  = Hacia la derecha (pared izquierda)
@export var direccion_salida: Vector2 = Vector2.UP
@export var distancia_oculta: float = 20.0

@onready var colision_pua: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else find_child("*CollisionShape*", false, false)
@onready var sensor: Area2D = $SensorPiso

var activado: bool = false
var pos_activa: Vector2
var pos_oculta: Vector2

func _ready() -> void:
	pos_activa = position
	# Se oculta en la dirección contraria a la salida:
	pos_oculta = position - (direccion_salida.normalized() * distancia_oculta)
	
	position = pos_oculta
	
	if colision_pua:
		colision_pua.set_deferred("disabled", true)
	
	if sensor:
		sensor.body_entered.connect(_on_sensor_body_entered)
	body_entered.connect(_on_pua_body_entered)

func _on_sensor_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("jugador")) and not activado:
		activado = true
		_disparar_puas()

func _disparar_puas() -> void:
	if colision_pua:
		colision_pua.set_deferred("disabled", false)
	
	var tween = create_tween()
	# Anima la posición completa hacia su lugar visible en 0.05 segundos
	tween.tween_property(self, "position", pos_activa, 0.05).set_trans(Tween.TRANS_QUAD)

func _on_pua_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("jugador"):
		if get_tree().current_scene.has_method("mostrar_screamer"):
			get_tree().current_scene.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
