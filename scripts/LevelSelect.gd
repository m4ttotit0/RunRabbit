extends Control

## Rutas de las escenas de nivel.
## Cuando desarrolles la etapa 2, 3, 4 o 5, solo agrega su ruta aquí
## y habilita el botón correspondiente en la escena (disabled = false).
const LEVEL_PATHS := {
	1: "res://scenes/Level1.tscn",
	2: "",
	3: "",
	4: "",
	5: "",
}


func _on_stage_1_pressed() -> void:
	_go_to_level(1)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _go_to_level(stage: int) -> void:
	var path: String = LEVEL_PATHS.get(stage, "")
	if path == "":
		return
	get_tree().change_scene_to_file(path)
