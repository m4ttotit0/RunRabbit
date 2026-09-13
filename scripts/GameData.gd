extends Node

## Autoload. Guarda el número de estrellas conseguidas por nivel durante
## la sesión de juego (para persistencia real entre partidas habría que
## guardarlo en disco con FileAccess/ConfigFile, pero para el prototipo
## basta con mantenerlo en memoria).

var level_stars: Dictionary = {}  # level_id (int) -> estrellas conseguidas (int)


func set_level_stars(level_id: int, stars: int) -> void:
	var current: int = level_stars.get(level_id, 0)
	if stars > current:
		level_stars[level_id] = stars


func get_level_stars(level_id: int) -> int:
	return level_stars.get(level_id, 0)
