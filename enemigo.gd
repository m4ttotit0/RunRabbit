extends CharacterBody2D

@export var velocidad: float = 200.0
@export var fuerza_salto: float = -1100.0
@export var distancia_obstaculo: float = 350.0
@export var distancia_precipicio: float = 350.0
@export var tiempo_espera: float = 2.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: RayCast2D = $RayCast2D
@onready var detector_suelo: RayCast2D = $DetectorSuelo
@onready var area: Area2D = $Area2D

var jugador: CharacterBody2D = null
var direccion: float = 1.0
var atrapado: bool = false
var puede_moverse: bool = false


func _ready() -> void:
	if not area.body_entered.is_connected(_on_area_2d_body_entered):
		area.body_entered.connect(_on_area_2d_body_entered)

	velocity = Vector2.ZERO

	await get_tree().create_timer(tiempo_espera).timeout

	puede_moverse = true


func _physics_process(delta: float) -> void:
	if atrapado:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if not puede_moverse:
		velocity.x = 0
		move_and_slide()
		return

	jugador = buscar_jugador()

	if jugador != null:
		var diferencia = jugador.global_position.x - global_position.x

		if abs(diferencia) > 5:
			direccion = sign(diferencia)
			velocity.x = direccion * velocidad
		else:
			velocity.x = 0

		detector.target_position.x = direccion * distancia_obstaculo
		detector.force_raycast_update()

		detector_suelo.position.x = direccion * distancia_precipicio
		detector_suelo.force_raycast_update()

		var hay_suelo = detector_suelo.is_colliding()
		var hay_obstaculo = false

		if detector.is_colliding():
			var obstaculo = detector.get_collider()

			if obstaculo != jugador and obstaculo != self:
				hay_obstaculo = true

		if is_on_floor() and abs(diferencia) > 5:
			if not hay_suelo or hay_obstaculo:
				velocity.y = fuerza_salto
	else:
		velocity.x = 0

	move_and_slide()
	actualizar_animacion()


func buscar_jugador() -> CharacterBody2D:
	var jugadores = get_tree().get_nodes_in_group("jugador")

	if jugadores.is_empty():
		jugadores = get_tree().get_nodes_in_group("player")

	var cercano: CharacterBody2D = null
	var distancia_minima: float = INF

	for personaje in jugadores:
		if personaje is CharacterBody2D and personaje != self:
			var distancia = global_position.distance_to(
				personaje.global_position
			)

			if distancia < distancia_minima:
				distancia_minima = distancia
				cercano = personaje

	return cercano


func actualizar_animacion() -> void:
	if not is_on_floor():
		if direccion > 0:
			sprite.play("jump_right")
		else:
			sprite.play("jump_left")
	else:
		if direccion > 0:
			sprite.play("run_right")
		else:
			sprite.play("run_left")


func _on_area_2d_body_entered(body: Node2D) -> void:

	if atrapado:
		return

	if body == self:
		return

	if body.is_in_group("jugador") or body.is_in_group("player"):
		atrapado = true

		var nivel = get_parent()

		if nivel.has_method("mostrar_screamer"):
			nivel.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
