extends Node2D

const LEVEL_ID := 1

@onready var end_point: Area2D = $EndPoint
@onready var win_panel: Control = $UI/WinPanel
@onready var win_label: Label = $UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel

func _ready() -> void:
	win_panel.visible = false
	end_point.body_entered.connect(_on_end_point_body_entered)

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
