extends CharacterBody2D

## "Enemigo" stalker.
##
## - Cuando el jugador (re)aparece en el nivel (inicio, recarga tras morir,
##   con o sin checkpoint) guarda esa posición. Después de `tiempo_espera`
##   segundos aparece ahí; si el jugador todavía no se alejó, espera otros
##   `tiempo_espera` segundos (y así hasta que se mueva).
## - Obedece a la física del mundo (gravedad, suelo, paredes), pero tiene su
##   propia IA: camina hacia el jugador y "mira" el terreno con sensores para
##   saltar paredes, huecos y subir a plataformas donde está el jugador.
## - Va al 50% de la velocidad del jugador por tierra y por aire.
## - Las trampas no lo matan (no está en ninguna capa de colisión, así que
##   púas, balas, anclas y zonas de muerte no lo detectan).
## - Si cae a un precipicio (o se queda atascado) desaparece y repite el
##   protocolo de aparición desde la posición actual del jugador.
## - Si toca al jugador es una muerte normal (LevelBase.mostrar_screamer).
## - Al acercarse suena (suave y gradualmente) la interferencia de radio y la
##   música del nivel baja un poco.

enum Estado { ESPERANDO, PERSIGUIENDO, DETENIDO }

const SCRIPTS_ZONA_MUERTE := ["zona_muerte.gd", "dead.gd", "die.gd"]

@export_group("Movimiento")
## Velocidad base del jugador (Player.gd -> SPEED).
@export var velocidad_jugador: float = 500.0
## Multiplicador de velocidad por el suelo.
@export_range(0.0, 2.0, 0.05) var factor_tierra: float = 0.5
## Multiplicador de velocidad en el aire.
@export_range(0.0, 2.0, 0.05) var factor_aire: float = 0.5
## Fuerza de salto (Player.gd -> JUMP_VELOCITY).
@export var fuerza_salto: float = -850.0
## Diferencia de altura (px) a partir de la cual el jugador "está arriba" y
## el enemigo intenta saltar hacia él.
@export var altura_para_saltar: float = 70.0
## Distancia (px) hacia adelante a la que mira si hay suelo o pared.
@export var distancia_sensor: float = 40.0
## Segundos sin avanzar antes de considerar que se atascó.
@export var tiempo_atascado: float = 3.0
## Segundos en el aire antes de considerar que cayó al vacío (por si el
## nivel no tiene zona de muerte en ese lugar).
@export var tiempo_caida_max: float = 3.0

@export_group("Aparición")
## Segundos de espera antes de aparecer (se repite si el jugador no se movió).
@export var tiempo_espera: float = 5.0
## Distancia mínima (px) que el jugador debe alejarse del punto de aparición
## para considerar que "ya se movió".
@export var distancia_movimiento: float = 80.0
## Tiempo máximo (s) que se espera a que el jugador toque el suelo antes de
## guardar su posición.
@export var espera_aterrizaje_max: float = 1.5

@export_group("Audio")
## Sonido de interferencia (radio de Silent Hill).
@export var sonido_interferencia: AudioStream
## Distancia (px) a partir de la cual se empieza a oír la interferencia.
@export var radio_audio_max: float = 1000.0
## Distancia (px) a la que la interferencia llega a su máximo.
@export var radio_audio_min: float = 150.0
## Volumen máximo de la interferencia (dB). Negativo = más sutil.
@export var volumen_interferencia_db: float = -10.0
## Cuánto baja la música como máximo (0 = nada, 1 = silencio total).
@export_range(0.0, 1.0, 0.05) var atenuacion_musica_max: float = 0.4
## Qué tan rápido cambia el volumen (más bajo = transición más suave).
@export var suavizado_audio: float = 1.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var forma: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

var estado: Estado = Estado.ESPERANDO
var nivel: Node = null
var jugador: CharacterBody2D = null
var punto_aparicion: Vector2 = Vector2.ZERO
var direccion: float = 1.0

var _tiempo_en_aire: float = 0.0
var _tiempo_sin_avanzar: float = 0.0
var _ultima_x: float = 0.0
var _esperando_aparicion: bool = false

var interferencia: AudioStreamPlayer = null
var musica: Node = null
var musica_volumen_original: float = 0.0
## Cercanía suavizada (0 = lejos, 1 = encima) que controla el audio.
var _cercania_suave: float = 0.0


func _ready() -> void:
	add_to_group("enemigo_perseguidor")

	# Capa 0: nada lo detecta (trampas, zonas de muerte, balas, anclas).
	# Máscara 1: choca con el suelo y las paredes del nivel.
	collision_layer = 0
	collision_mask = 1
	z_index = 5
	velocity = Vector2.ZERO

	# El área atrapa al jugador y detecta las zonas de muerte (precipicios).
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	area.monitoring = false
	if not area.area_entered.is_connected(_on_area_entered):
		area.area_entered.connect(_on_area_entered)

	_ocultar()
	_crear_audio()

	# Esperamos a que el nivel termine su _ready (puede haber movido al
	# jugador al checkpoint) antes de guardar el punto de aparición.
	_iniciar.call_deferred()


func _iniciar() -> void:
	nivel = get_tree().current_scene
	jugador = _buscar_jugador()
	if jugador == null:
		estado = Estado.DETENIDO
		return

	# No choca con los jugadores (los atraviesa y los atrapa con el área).
	for p in get_tree().get_nodes_in_group("jugador"):
		if p is PhysicsBody2D:
			add_collision_exception_with(p)

	musica = nivel.get_node_or_null("Music") if nivel else null
	if musica and "volume_db" in musica:
		musica_volumen_original = musica.volume_db
	else:
		musica = null

	_protocolo_aparicion()


# ---------------------------------------------------------------------------
# Aparición
# ---------------------------------------------------------------------------

## Guarda la posición actual del jugador, espera y aparece ahí cuando el
## jugador ya se alejó. Se usa al empezar y cada vez que cae al vacío.
func _protocolo_aparicion() -> void:
	if _esperando_aparicion:
		return
	_esperando_aparicion = true
	estado = Estado.ESPERANDO
	_ocultar()

	# El jugador suele aparecer un poco en el aire: se guarda la posición
	# cuando toca el suelo, para que esa caída no cuente como "se movió".
	var limite := Time.get_ticks_msec() + int(espera_aterrizaje_max * 1000.0)
	while not jugador.is_on_floor() and Time.get_ticks_msec() < limite:
		await get_tree().physics_frame
		if not _sigue_valido():
			return
	punto_aparicion = jugador.global_position

	while true:
		await get_tree().create_timer(tiempo_espera, false).timeout
		if not _sigue_valido():
			return
		if jugador.global_position.distance_to(punto_aparicion) > distancia_movimiento:
			break

	_esperando_aparicion = false
	_aparecer()


func _sigue_valido() -> bool:
	if not is_inside_tree() or estado == Estado.DETENIDO or not is_instance_valid(jugador):
		_esperando_aparicion = false
		return false
	return true


func _aparecer() -> void:
	# Se alinean los pies del enemigo con los pies que tenía el jugador.
	global_position = punto_aparicion + Vector2(0, _pies_jugador() - _pies_propios())
	velocity = Vector2.ZERO
	_tiempo_en_aire = 0.0
	_tiempo_sin_avanzar = 0.0
	_ultima_x = global_position.x
	direccion = signf(jugador.global_position.x - global_position.x)
	if direccion == 0.0:
		direccion = 1.0

	estado = Estado.PERSIGUIENDO
	show()
	set_deferred("collision_mask", 1)
	area.set_deferred("monitoring", true)


func _ocultar() -> void:
	hide()
	velocity = Vector2.ZERO
	collision_mask = 0
	area.set_deferred("monitoring", false)


## Distancia del centro del jugador a sus pies (en píxeles del mundo).
func _pies_jugador() -> float:
	var cs := jugador.get_node_or_null("CollisionShape2D") as CollisionShape2D
	return _pies_de(cs, jugador) if cs else 36.0


func _pies_propios() -> float:
	return _pies_de(forma, self)


func _pies_de(cs: CollisionShape2D, cuerpo: Node2D) -> float:
	var r := cs.shape as RectangleShape2D
	if r == null:
		return 0.0
	var local_bottom := cs.position.y + r.size.y * 0.5
	return local_bottom * cuerpo.global_scale.y


# ---------------------------------------------------------------------------
# IA de persecución
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if estado == Estado.DETENIDO:
		_actualizar_audio(delta, 0.0)
		return
	if not is_instance_valid(jugador) or (nivel and nivel.get("jugador_muerto") == true):
		_detener()
		return
	if estado != Estado.PERSIGUIENDO:
		_actualizar_audio(delta, 0.0)
		return

	var en_suelo := is_on_floor()
	var velocidad := velocidad_jugador * (factor_tierra if en_suelo else factor_aire)

	# Gravedad normal del mundo
	if not en_suelo:
		velocity += get_gravity() * delta

	var dx := jugador.global_position.x - global_position.x
	var dy := jugador.global_position.y - global_position.y  # negativo = jugador arriba
	if absf(dx) > 12.0:
		direccion = signf(dx)
		velocity.x = direccion * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidad)

	if en_suelo and _debe_saltar(dx, dy):
		velocity.y = fuerza_salto

	move_and_slide()

	_revisar_caida_y_atasco(delta, dx)
	_actualizar_animacion()
	_actualizar_audio(delta, _cercania())


func _debe_saltar(dx: float, dy: float) -> bool:
	var jugador_arriba := dy < -altura_para_saltar
	var avanzando := absf(dx) > 12.0

	# 1) Pared delante
	if avanzando and (is_on_wall() or _hay_pared_delante()):
		return true

	# 2) Hueco delante: salta, salvo que el jugador esté abajo y haya suelo
	#    al que bajar (en ese caso simplemente se deja caer).
	if avanzando and not _hay_suelo_delante(60.0):
		var bajar_hasta: float = _profundidad_suelo_delante(900.0)
		var jugador_abajo := dy > altura_para_saltar
		if jugador_abajo and bajar_hasta >= 0.0:
			return false
		return true

	# 3) El jugador está arriba y cerca: intenta subir a su plataforma.
	if jugador_arriba and absf(dx) < 220.0:
		return true

	return false


func _rayo(desde: Vector2, hasta: Vector2) -> Dictionary:
	var params := PhysicsRayQueryParameters2D.create(desde, hasta, 1)
	var excluir: Array[RID] = [get_rid()]
	for p in get_tree().get_nodes_in_group("jugador"):
		if p is CollisionObject2D:
			excluir.append(p.get_rid())
	params.exclude = excluir
	params.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_ray(params)


func _pie_delantero() -> Vector2:
	var r := forma.shape as RectangleShape2D
	var medio_ancho := r.size.x * 0.5 * global_scale.x if r else 15.0
	var centro := forma.global_position
	return Vector2(centro.x + direccion * medio_ancho, global_position.y + _pies_propios())


func _hay_pared_delante() -> bool:
	var pie := _pie_delantero()
	var altura := pie + Vector2(0, -20)
	return not _rayo(altura, altura + Vector2(direccion * distancia_sensor, 0)).is_empty()


func _hay_suelo_delante(profundidad: float) -> bool:
	return _profundidad_suelo_delante(profundidad) >= 0.0


## Devuelve a cuántos px hacia abajo hay suelo delante (-1 si no hay).
func _profundidad_suelo_delante(profundidad: float) -> float:
	var desde := _pie_delantero() + Vector2(direccion * distancia_sensor, -10)
	var hit := _rayo(desde, desde + Vector2(0, profundidad))
	if hit.is_empty():
		return -1.0
	return hit.position.y - desde.y


func _revisar_caida_y_atasco(delta: float, dx: float) -> void:
	# Cayendo demasiado tiempo = cayó al vacío.
	_tiempo_en_aire = 0.0 if is_on_floor() else _tiempo_en_aire + delta
	if _tiempo_en_aire > tiempo_caida_max:
		_reaparecer()
		return

	# Sin avanzar mientras el jugador está lejos = atascado.
	if absf(dx) > 40.0 and absf(global_position.x - _ultima_x) < 2.0:
		_tiempo_sin_avanzar += delta
		if _tiempo_sin_avanzar > tiempo_atascado:
			_reaparecer()
	else:
		_tiempo_sin_avanzar = 0.0
	_ultima_x = global_position.x


## Cayó a un precipicio o se atascó: repite el protocolo de aparición.
func _reaparecer() -> void:
	if estado != Estado.PERSIGUIENDO:
		return
	_protocolo_aparicion()


func _actualizar_animacion() -> void:
	var anim := ("run_" if is_on_floor() else "jump_") + ("right" if direccion > 0 else "left")
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


# ---------------------------------------------------------------------------
# Audio: interferencia sube suave, la música baja un poco
# ---------------------------------------------------------------------------

func _crear_audio() -> void:
	if sonido_interferencia == null:
		return
	var stream := sonido_interferencia.duplicate() as AudioStream
	if "loop" in stream:
		stream.loop = true
	interferencia = AudioStreamPlayer.new()
	interferencia.name = "Interferencia"
	interferencia.stream = stream
	interferencia.volume_db = -80.0
	add_child(interferencia)


## 0 = lejos (no se oye), 1 = muy cerca. Curva suave (ease-in) para que la
## interferencia no entre de golpe.
func _cercania() -> float:
	var distancia := global_position.distance_to(jugador.global_position)
	var t := clampf(inverse_lerp(radio_audio_max, radio_audio_min, distancia), 0.0, 1.0)
	return t * t


func _actualizar_audio(delta: float, objetivo: float) -> void:
	# Transición gradual hacia el volumen objetivo.
	_cercania_suave = move_toward(_cercania_suave, objetivo, suavizado_audio * delta * 0.5)
	var t := _cercania_suave

	if interferencia:
		if t > 0.001:
			interferencia.volume_db = volumen_interferencia_db + linear_to_db(t)
			if not interferencia.playing:
				interferencia.play()
		elif interferencia.playing:
			interferencia.stop()

	if musica and is_instance_valid(musica):
		musica.volume_db = musica_volumen_original + linear_to_db(1.0 - atenuacion_musica_max * t)


func _detener() -> void:
	estado = Estado.DETENIDO
	velocity = Vector2.ZERO
	area.set_deferred("monitoring", false)


func _exit_tree() -> void:
	if musica and is_instance_valid(musica):
		musica.volume_db = musica_volumen_original


# ---------------------------------------------------------------------------
# Jugador / zonas
# ---------------------------------------------------------------------------

func _buscar_jugador() -> CharacterBody2D:
	# Persigue al jugador 1 (en modo dos jugadores igual atrapa a cualquiera).
	if nivel and nivel.get("player1") is CharacterBody2D:
		return nivel.player1
	for p in get_tree().get_nodes_in_group("jugador"):
		if p is CharacterBody2D and p.get("player_id") != 2:
			return p
	for p in get_tree().get_nodes_in_group("player"):
		if p is CharacterBody2D:
			return p
	return null


func _on_area_2d_body_entered(body: Node2D) -> void:
	if estado != Estado.PERSIGUIENDO or body == self:
		return
	if body.is_in_group("jugador") or body.is_in_group("player"):
		_detener()
		if nivel and nivel.has_method("mostrar_screamer"):
			nivel.mostrar_screamer()
		else:
			get_tree().call_deferred("reload_current_scene")


## Las trampas no le hacen nada; solo las zonas de muerte (precipicios)
## lo hacen reaparecer.
func _on_area_entered(otra: Area2D) -> void:
	if estado != Estado.PERSIGUIENDO:
		return
	if _es_zona_muerte(otra):
		_reaparecer.call_deferred()


func _es_zona_muerte(otra: Area2D) -> bool:
	if String(otra.name).to_lower().contains("muerte"):
		return true
	var s: Script = otra.get_script()
	return s != null and s.resource_path.get_file() in SCRIPTS_ZONA_MUERTE
