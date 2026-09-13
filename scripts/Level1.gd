extends Node2D

const LEVEL_ID := 1
const REQUIRED_STARS := 3

@onready var end_point: Area2D = $EndPoint
@onready var win_panel: Control = $UI/WinPanel
@onready var win_label: Label = $UI/WinPanel/CenterContainer/PanelContainer/VBoxContainer/WinLabel
@onready var star_label: Label = $UI/StarLabel
@onready var need_stars_label: Label = $UI/NeedStarsLabel
@onready var need_stars_timer: Timer = $UI/NeedStarsTimer

var stars_collected: int = 0


func _ready() -> void:
	win_panel.visible = false
	need_stars_label.visible = false

	end_point.body_entered.connect(_on_end_point_body_entered)
	need_stars_timer.timeout.connect(_on_need_stars_timer_timeout)

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

	if stars_collected >= REQUIRED_STARS:
		_win()
	else:
		_show_need_stars_message()


func _win() -> void:
	if win_panel.visible:
		return
	win_label.text = "¡Nivel completado!\nEstrellas: %d/%d" % [stars_collected, REQUIRED_STARS]
	win_panel.visible = true
	get_tree().paused = true
	GameData.set_level_stars(LEVEL_ID, stars_collected)


func _show_need_stars_message() -> void:
	need_stars_label.text = "Necesitas las %d estrellas para completar el nivel (%d/%d)" % [REQUIRED_STARS, stars_collected, REQUIRED_STARS]
	need_stars_label.visible = true
	need_stars_timer.start()


func _on_need_stars_timer_timeout() -> void:
	need_stars_label.visible = false


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
