extends LevelBase

## Nivel 1. Toda la lógica común está en LevelBase.gd.

func _init() -> void:
	level_id = 1
	supports_two_players = true
	win_text = "¡Nivel completado!"
