extends Control

@onready var mode_panel: Control = $ModePanel


func _ready() -> void:
	mode_panel.visible = false


func _on_level_select_button_pressed() -> void:
	mode_panel.visible = true


func _on_one_player_button_pressed() -> void:
	GameData.two_players = false
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_two_players_button_pressed() -> void:
	GameData.two_players = true
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_mode_back_button_pressed() -> void:
	mode_panel.visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
