extends Control

@onready var mode_panel: Control = $ModePanel
@onready var load_panel: Control = $LoadPanel


func _ready() -> void:
	mode_panel.visible = false
	# Al abrir el juego se pregunta (una sola vez) si cargar la partida.
	load_panel.visible = not GameData.load_prompt_shown


func _on_load_yes_button_pressed() -> void:
	GameData.load_game()
	GameData.load_prompt_shown = true
	load_panel.visible = false


func _on_load_no_button_pressed() -> void:
	GameData.delete_save_and_start_new()
	GameData.load_prompt_shown = true
	load_panel.visible = false


func _on_level_select_button_pressed() -> void:
	mode_panel.visible = true


func _on_one_player_button_pressed() -> void:
	GameData.two_players = false
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_two_players_button_pressed() -> void:
	GameData.two_players = true
	get_tree().change_scene_to_file("res://scenes/LevelSelect_multi.tscn")


func _on_mode_back_button_pressed() -> void:
	mode_panel.visible = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
