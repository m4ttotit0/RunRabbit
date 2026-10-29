extends Node2D

const LEVEL_ID := 2

@onready var end_point: Area2D = $EndPoint
@onready var win_panel: Control = $UI/WinPanel
@onready var win_label: Label = $UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel
@onready var player1: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var screamer: TextureRect = $UI/Screamer

var player2: CharacterBody2D = null
var jugador_muerto: bool = false

# Nota: si tienes un TextureRect para el screamer en la UI, pon su ruta aquí:
# @onready var screamer: TextureRect = $UI/Screamer

func _ready() -> void:
	win_panel.visible = false
	screamer.hide()

	end_point.body_entered.connect(
		_on_end_point_body_entered
	)

func _on_end_point_body_entered(body: Node) -> void:
	if jugador_muerto:
		return

	if not (
		body.name == "Player"
		or body.is_in_group("jugador")
		or body.is_in_group("player")
	):
		return

	_win()

func _win() -> void:
	if win_panel.visible or jugador_muerto:
		return

	win_label.text = "¡Final del nivel!"
	win_panel.visible = true
	get_tree().paused = true

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(
        "res://scenes/LevelSelect.tscn"
	)

func mostrar_screamer() -> void:
	if jugador_muerto or win_panel.visible:
		return

	jugador_muerto = true

	player1.velocity = Vector2.ZERO
	player1.set_physics_process(false)
	player1.set_process_input(false)

	if is_instance_valid(player2):
		player2.velocity = Vector2.ZERO
		player2.set_physics_process(false)
		player2.set_process_input(false)

	if randf() < 0.2:
		screamer.show()
		await get_tree().create_timer(1.5).timeout

	get_tree().call_deferred("reload_current_scene")
