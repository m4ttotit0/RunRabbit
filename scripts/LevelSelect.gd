extends Control

## Rutas de las escenas de nivel. Un nivel solo se puede jugar si ya se
## completó el anterior (ver GameData.unlocked_level).
## CTRL + C desbloquea todos los niveles (modo debug, solo esta sesión).
const LEVEL_PATHS := {
	1: "res://scenes/Level1.tscn",
	2: "res://scenes/Level2.tscn",
	3: "res://scenes/Level3.tscn",
	4: "res://scenes/Level4.tscn",
	5: "res://scenes/Level5.tscn",
}

## El nivel 1 empieza con la cinemática.
const LEVEL1_INTRO := "res://scenes/cinematica.tscn"

@onready var stars_label: Label = $StarsLabel
@onready var debug_label: Label = $DebugLabel
@onready var background: TextureRect = $Background


func _ready() -> void:
	if GameData.two_players:
		background.texture = load(
			"res://assets/fondo/SeleccionMultijugador.png"
		)

	_refresh()


func _refresh() -> void:
	for stage in LEVEL_PATHS.keys():
		var button: Button = get_node_or_null("Stage%d" % stage)
		if button == null:
			continue
		var unlocked: bool = GameData.is_level_unlocked(stage) and LEVEL_PATHS[stage] != ""
		button.disabled = not unlocked
		button.tooltip_text = "Estrellas: %d" % GameData.get_level_stars(stage)

	stars_label.text = "Estrellas: %d" % GameData.get_total_stars()
	debug_label.visible = GameData.debug_unlock_all


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_C and event.ctrl_pressed:
		GameData.debug_unlock_all = true
		_refresh()
		get_viewport().set_input_as_handled()


func _on_stage_1_pressed() -> void:
	if GameData.is_level_unlocked(1):
		get_tree().change_scene_to_file(LEVEL1_INTRO)


func _on_stage_2_pressed() -> void:
	_go_to_level(2)


func _on_stage_3_pressed() -> void:
	_go_to_level(3)


func _on_stage_4_pressed() -> void:
	_go_to_level(4)


func _on_stage_5_pressed() -> void:
	_go_to_level(5)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _go_to_level(stage: int) -> void:
	if not GameData.is_level_unlocked(stage):
		return
	var path: String = LEVEL_PATHS.get(stage, "")
	if path == "":
		return
	get_tree().change_scene_to_file(path)
	
