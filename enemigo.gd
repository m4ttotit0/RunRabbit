
extends CharacterBody2D

@export var velocidad: float = 100.0
@export var fuerza_salto: float = -850.0
@export var distancia_deteccion: float = 70.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: RayCast2D = $RayCast2D
@onready var detector_suelo: RayCast2D = $DetectorSuelo

var jugador: CharacterBody2D = null
var direccion: float = 1.0
var atrapado: bool = false


func _physics_process(delta: float) -> void:
	if atrapado:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	jugador = buscar_jugador()

	if jugador != null:
		var diferencia = jugador.global_position.x - global_position.x

		if abs(diferencia) > 5:
			direccion = sign(diferencia)
			velocity.x = direccion * velocidad
		else:
			velocity.x = 0

		detector.target_position.x = direccion * distancia_deteccion
		detector.force_raycast_update()

		detector_suelo.position.x = direccion * distancia_deteccion
		detector_suelo.force_raycast_update()

		var hay_suelo = detector_suelo.is_colliding()
		var hay_obstaculo = false

		if detector.is_colliding():
			var obstaculo = detector.get_collider()

			if obstaculo != jugador:
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
	var cercano: CharacterBody2D = null
	var distancia_minima: float = INF

	for personaje in jugadores:
		if personaje is CharacterBody2D:
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

	if body.is_in_group("jugador"):
		atrapado = true

		var nivel = get_parent()

		if nivel.has_method("mostrar_screamer"):
			nivel.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")
