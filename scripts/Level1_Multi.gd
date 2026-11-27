extends LevelBase

## Nivel 1 para dos jugadores. Player2 ya viene en la escena; LevelBase
## detecta que hay dos jugadores, centra la cámara entre ambos y no crea
## al enemigo.

func _init() -> void:
	level_id = 1
	supports_two_players = false
	win_text = "¡Nivel completado!"
