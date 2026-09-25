extends Node2D

const LEVEL_ID := 1
const REQUIRED_STARS := 3  # Se usa solo para mostrar "X/3", ya no bloquea la meta.

@onready var end_point: Area2D = $EndPoint
@onready var win_panel: Control = $UI/WinPanel
@onready var win_label: Label = $UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel
@onready var star_label: Label = $UI/StarLabel

var stars_collected: int = 0


func _ready() -> void:
	win_panel.visible = false

	end_point.body_entered.connect(_on_end_point_body_entered)

	# Conecta la señal "collected" de cada estrella presente en el nivel.
	for star in get_tree().get_nodes_in_group("stars"):
		star.collected.connect(_on_star_collected)

	_update_star_label()


func _on_star_collected() -> void:
	stars_collected += 1
	_update_star_label()


func _update_star_label() -> void:
	star_label.text = "Estrellas: %d/%d" % [stars_collected, REQUIRED_STARS]


func _on_end_point_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_win()


func _win() -> void:
	if win_panel.visible:
		return
	win_label.text = "¡Nivel completado!\nEstrellas: %d/%d" % [stars_collected, REQUIRED_STARS]
	win_panel.visible = true
	get_tree().paused = true
	GameData.set_level_stars(LEVEL_ID, stars_collected)


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
