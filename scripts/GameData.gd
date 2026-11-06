extends Node

## Autoload. Guarda el progreso del jugador (niveles desbloqueados y
## estrellas recolectadas) y lo lee/escribe en el archivo de guardado.
##
## Carpeta de guardado:
##   - Juego exportado: <carpeta del .exe>/saves/save.json
##     (si esa carpeta no se puede escribir, se usa user://saves/)
##   - Desde el editor: user://saves/save.json
##     (en Windows: %APPDATA%/Godot/app_userdata/Run Rabbit/saves)

const SAVE_DIR_NAME := "saves"
const SAVE_FILE_NAME := "save.json"
const SAVE_VERSION := 1

## Cantidad total de niveles del juego (para el modo debug y la selección).
const TOTAL_LEVELS := 5

## Modo de juego elegido: false = un jugador, true = dos jugadores.
var two_players: bool = false

## Último nivel desbloqueado (el nivel 1 siempre está disponible).
var unlocked_level: int = 1

## Niveles completados (ids).
var completed_levels: Array[int] = []

## Estrellas recolectadas por nivel: level_id (int) -> Array[String] con
## el id de cada estrella (su ruta dentro de la escena del nivel).
var collected_stars: Dictionary = {}

## Modo debug (CTRL + C en la selección de niveles). Solo dura la sesión,
## no se guarda en el archivo.
var debug_unlock_all: bool = false

## Para mostrar la pregunta "¿Desea cargar una partida guardada?" solo una
## vez al abrir el juego.
var load_prompt_shown: bool = false

var save_dir: String = ""
var save_path: String = ""


func _ready() -> void:
	_setup_save_folder()


# ---------------------------------------------------------------------------
# Carpeta / archivo de guardado
# ---------------------------------------------------------------------------

func _setup_save_folder() -> void:
	var candidates: Array[String] = []
	if not OS.has_feature("editor"):
		candidates.append(OS.get_executable_path().get_base_dir().path_join(SAVE_DIR_NAME))
	candidates.append("user://" + SAVE_DIR_NAME)

	for dir in candidates:
		# Solo se crea si no existe: nunca se sobrescribe la carpeta.
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_recursive_absolute(dir)
		if DirAccess.dir_exists_absolute(dir) and _is_writable(dir):
			save_dir = dir
			break

	save_path = save_dir.path_join(SAVE_FILE_NAME)

	# Si todavía no hay archivo de guardado se crea uno vacío
	# (si ya existe NO se toca).
	if not FileAccess.file_exists(save_path):
		_write_file(_empty_data())

	print("[GameData] Archivo de guardado: ", ProjectSettings.globalize_path(save_path))


func _is_writable(dir: String) -> bool:
	var test_path := dir.path_join(".write_test")
	var f := FileAccess.open(test_path, FileAccess.WRITE)
	if f == null:
		return false
	f.close()
	DirAccess.remove_absolute(test_path)
	return true


func has_save_file() -> bool:
	return FileAccess.file_exists(save_path)


func _empty_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"unlocked_level": 1,
		"completed_levels": [],
		"stars": {},
	}


func _to_data() -> Dictionary:
	var stars := {}
	for level_id in collected_stars.keys():
		stars[str(level_id)] = collected_stars[level_id].duplicate()
	return {
		"version": SAVE_VERSION,
		"unlocked_level": unlocked_level,
		"completed_levels": completed_levels.duplicate(),
		"stars": stars,
	}


func _write_file(data: Dictionary) -> bool:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		push_error("No se pudo escribir el guardado: %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true


## Guarda el progreso actual (en memoria) en el archivo save.
func save_game() -> bool:
	return _write_file(_to_data())


## Lee el archivo save y carga el progreso. Devuelve false si no existe o
## está dañado (en ese caso se empieza con progreso vacío).
func load_game() -> bool:
	reset_progress()
	if not has_save_file():
		_write_file(_empty_data())
		return false

	var text := FileAccess.get_file_as_string(save_path)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Archivo de guardado inválido, se ignora.")
		return false

	unlocked_level = clampi(int(data.get("unlocked_level", 1)), 1, TOTAL_LEVELS)
	for id in data.get("completed_levels", []):
		completed_levels.append(int(id))
	var stars: Dictionary = data.get("stars", {})
	for key in stars.keys():
		var list: Array[String] = []
		for star_id in stars[key]:
			list.append(str(star_id))
		collected_stars[int(key)] = list
	return true


## "No, deseo borrar la partida anterior": borra el save y crea uno vacío.
func delete_save_and_start_new() -> void:
	if has_save_file():
		DirAccess.remove_absolute(save_path)
	reset_progress()
	_write_file(_empty_data())


func reset_progress() -> void:
	unlocked_level = 1
	completed_levels.clear()
	collected_stars.clear()


# ---------------------------------------------------------------------------
# Progreso de niveles
# ---------------------------------------------------------------------------

func is_level_unlocked(level_id: int) -> bool:
	return debug_unlock_all or level_id <= unlocked_level


func is_level_completed(level_id: int) -> bool:
	return level_id in completed_levels


## Llamar al terminar un nivel: lo marca como completado y desbloquea el
## siguiente.
func complete_level(level_id: int) -> void:
	if not level_id in completed_levels:
		completed_levels.append(level_id)
	unlocked_level = clampi(maxi(unlocked_level, level_id + 1), 1, TOTAL_LEVELS)


# ---------------------------------------------------------------------------
# Estrellas
# ---------------------------------------------------------------------------

func is_star_collected(level_id: int, star_id: String) -> bool:
	return star_id in collected_stars.get(level_id, [])


func add_collected_stars(level_id: int, star_ids: Array) -> void:
	if star_ids.is_empty():
		return
	var list: Array[String] = []
	list.assign(collected_stars.get(level_id, []))
	for star_id in star_ids:
		if not star_id in list:
			list.append(str(star_id))
	collected_stars[level_id] = list


## Estrellas recolectadas en un nivel.
func get_level_stars(level_id: int) -> int:
	return collected_stars.get(level_id, []).size()


## Total de estrellas recolectadas en todo el juego.
func get_total_stars() -> int:
	var total := 0
	for level_id in collected_stars.keys():
		total += collected_stars[level_id].size()
	return total
