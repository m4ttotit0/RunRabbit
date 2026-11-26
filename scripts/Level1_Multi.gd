extends LevelBase

## Nivel 1 para dos jugadores.

func _init() -> void:
	level_id = 1
	supports_two_players = false
	win_text = "¡Nivel completado!"

func _ready() -> void:
	super._ready()

	if camera:
		camera.top_level = true
