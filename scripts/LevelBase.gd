class_name LevelBase
extends Node2D

## Lógica común de todos los niveles: meta, muerte/screamer, estrellas,
## menú de pausa, música en loop y modo dos jugadores.
##
## Cada nivel tiene su propio script que hace `extends LevelBase` y solo
## define su número de nivel en `_init()`, por ejemplo:
##
##     extends LevelBase
##     func _init() -> void:
##         level_id = 3
##
## Nodos que busca en la escena (si alguno no existe simplemente se ignora):
##   EndPoint (Area2D), Player, Player/Camera2D, Music,
##   UI/WinPanel, UI/WinPanel/.../WinLabel, UI/Screamer, UI/StarLabel
## Las estrellas son instancias de Star.tscn (grupo "stars").

const PLAYER2_OFFSET := Vector2(60, 0)
const PAUSE_MENU_SCENE := preload("res://scenes/PauseMenu.tscn")
const LEVEL_SELECT_SCENE := "res://scenes/LevelSelect.tscn"
## Apariencia del jugador 2 (gato negro). Por ahora es un solo sprite sin
## animaciones: se usa la misma imagen para "idle", "running" y "jumping".
const PLAYER2_TEXTURE := preload("res://assets/characters/8a6-11f1-9440-3ff576f3e298 (1).png")

## Número del nivel (1..5). Se define en el script de cada nivel.
var level_id: int = 1
## Si es true, en modo dos jugadores se crea el jugador 2 automáticamente.
var supports_two_players: bool = false
## Texto que aparece al llegar a la meta.
var win_text: String = "¡Final del nivel!"

@onready var end_point: Area2D = get_node_or_null("EndPoint")
@onready var win_panel: Control = get_node_or_null("UI/WinPanel")
@onready var win_label: Label = get_node_or_null("UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel")
@onready var player1: CharacterBody2D = get_node_or_null("Player")
@onready var camera: Camera2D = get_node_or_null("Player/Camera2D")
@onready var screamer: TextureRect = get_node_or_null("UI/Screamer")
@onready var star_label: Label = get_node_or_null("UI/StarLabel")
@onready var music: Node = get_node_or_null("Music")

var player2: CharacterBody2D = null
var jugador_muerto: bool = false
var pause_menu: CanvasLayer = null

## Estrellas tomadas en este intento que aún no se guardan en GameData.
## Se confirman al terminar el nivel o al usar "Guardar" en la pausa.
var pending_stars: Array[String] = []


func _ready() -> void:
	if win_panel:
		win_panel.visible = false
		# Para que los botones funcionen con el juego en pausa.
		win_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	if screamer:
		screamer.hide()
	if end_point:
		end_point.body_entered.connect(_on_end_point_body_entered)

	_setup_music()
	_setup_stars()

	pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)

	if supports_two_players and GameData.two_players and player1:
		_spawn_player2()


func _process(_delta: float) -> void:
	if player2 != null and camera:
		camera.global_position = _players_center()


# ---------------------------------------------------------------------------
# Música: suena en loop hasta el final del nivel
# ---------------------------------------------------------------------------

func _setup_music() -> void:
	if music == null or not ("stream" in music) or music.stream == null:
		return
	var stream: AudioStream = music.stream
	if "loop" in stream:
		stream.loop = true
	elif not music.finished.is_connected(music.play):
		music.finished.connect(music.play)
	if not music.playing:
		music.play()


# ---------------------------------------------------------------------------
# Estrellas
# ---------------------------------------------------------------------------

func _setup_stars() -> void:
	for star in get_tree().get_nodes_in_group("stars"):
		if not is_ancestor_of(star):
			continue
		var star_id := _star_id(star)
		if GameData.is_star_collected(level_id, star_id):
			# Ya se tomó en una partida anterior: no vuelve a aparecer.
			star.queue_free()
		elif star.has_signal("collected"):
			star.collected.connect(_on_star_collected.bind(star_id))
	_update_star_label()


func _star_id(star: Node) -> String:
	return str(get_path_to(star))


func _on_star_collected(star_id: String) -> void:
	if not star_id in pending_stars:
		pending_stars.append(star_id)
	_update_star_label()


func _commit_pending_stars() -> void:
	GameData.add_collected_stars(level_id, pending_stars)
	pending_stars.clear()


func _update_star_label() -> void:
	if star_label:
		var level_stars := GameData.get_level_stars(level_id) + pending_stars.size()
		star_label.text = "Estrellas: %d" % level_stars


# ---------------------------------------------------------------------------
# Pausa / guardado (lo llama PauseMenu)
# ---------------------------------------------------------------------------

func can_pause() -> bool:
	return not jugador_muerto and not (win_panel and win_panel.visible)


## Botón "Guardar" del menú de pausa.
func save_progress() -> bool:
	_commit_pending_stars()
	_update_star_label()
	return GameData.save_game()


# ---------------------------------------------------------------------------
# Jugador 2
# ---------------------------------------------------------------------------

func _spawn_player2() -> void:
	player2 = player1.duplicate()
	player2.name = "Player2"
	player2.player_id = 2
	player2.position = player1.position + PLAYER2_OFFSET

	var cam2: Node = player2.get_node_or_null("Camera2D")
	if cam2:
		player2.remove_child(cam2)
		cam2.free()

	_apply_player2_skin()

	add_child(player2)

	if camera:
		camera.top_level = true
		camera.global_position = _players_center()
		camera.reset_smoothing()


func _apply_player2_skin() -> void:
	var sprite: AnimatedSprite2D = player2.get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return
	var frames := SpriteFrames.new()
	for anim in ["idle", "running", "jumping"]:
		if not frames.has_animation(anim):
			frames.add_animation(anim)
		frames.add_frame(anim, PLAYER2_TEXTURE)
	sprite.sprite_frames = frames
	sprite.play("idle")


func _players_center() -> Vector2:
	return (player1.global_position + player2.global_position) / 2.0


# ---------------------------------------------------------------------------
# Meta / reintentar / menú
# ---------------------------------------------------------------------------

func _on_end_point_body_entered(body: Node) -> void:
	if jugador_muerto:
		return
	if not (body.name == "Player" or body.is_in_group("jugador") or body.is_in_group("player")):
		return
	_win()


func _win() -> void:
	if jugador_muerto or (win_panel and win_panel.visible):
		return

	_commit_pending_stars()
	GameData.complete_level(level_id)
	_update_star_label()

	if win_panel:
		if win_label:
			win_label.text = win_text
		win_panel.visible = true
		get_tree().paused = true
	else:
		get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


# ---------------------------------------------------------------------------
# Muerte
# ---------------------------------------------------------------------------

func mostrar_screamer() -> void:
	if jugador_muerto or (win_panel and win_panel.visible):
		return

	jugador_muerto = true

	for p in [player1, player2]:
		if is_instance_valid(p):
			p.velocity = Vector2.ZERO
			p.set_physics_process(false)
			p.set_process_input(false)

	if screamer and randf() < 0.2:
		screamer.show()
		await get_tree().create_timer(1.5).timeout

	get_tree().call_deferred("reload_current_scene")
