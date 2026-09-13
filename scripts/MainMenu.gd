extends Control


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
