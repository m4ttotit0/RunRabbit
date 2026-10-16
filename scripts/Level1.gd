extends Node2D

const LEVEL_ID := 1
const PLAYER2_OFFSET := Vector2(60, 0)

@onready var end_point: Area2D = $EndPoint
@onready var win_panel: Control = $UI/WinPanel
@onready var win_label: Label = $UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel
@onready var player1: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

var player2: CharacterBody2D = null

func _ready() -> void:
	win_panel.visible = false
	end_point.body_entered.connect(_on_end_point_body_entered)
	if GameData.two_players:
		_spawn_player2()

func _spawn_player2() -> void:
	player2 = player1.duplicate()
	player2.name = "Player2"
	player2.player_id = 2
	player2.position = player1.position + PLAYER2_OFFSET
	var cam2: Node = player2.get_node("Camera2D")
	player2.remove_child(cam2)
	cam2.free()
	add_child(player2)
	camera.top_level = true
	camera.global_position = _players_center()
	camera.reset_smoothing()

func _process(_delta: float) -> void:
	if player2 != null:
		camera.global_position = _players_center()

func _players_center() -> Vector2:
	return (player1.global_position + player2.global_position) / 2.0

func _on_end_point_body_entered(body: Node) -> void:
	if not (body.name == "Player" or body.is_in_group("jugador") or body.is_in_group("player")):
		return
	_win()

func _win() -> void:
	if win_panel.visible:
		return
	win_label.text = "¡Nivel completado!"
	win_panel.visible = true
	get_tree().paused = true

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
