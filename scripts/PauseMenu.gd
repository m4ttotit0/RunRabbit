extends CanvasLayer

## Menú de pausa. Se agrega automáticamente a cada nivel (ver LevelBase.gd).
## ESC abre/cierra el menú.

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

@onready var root: Control = $Root
@onready var resume_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var save_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/SaveButton
@onready var main_menu_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MainMenuButton
@onready var status_label: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/StatusLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	status_label.text = ""
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode != KEY_ESCAPE:
		return
	get_viewport().set_input_as_handled()
	if root.visible:
		close()
	else:
		open()


func open() -> void:
	var level := get_parent()
	if level and level.has_method("can_pause") and not level.can_pause():
		return
	if get_tree().paused:
		return
	status_label.text = ""
	root.visible = true
	get_tree().paused = true
	resume_button.grab_focus()


func close() -> void:
	root.visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	close()


func _on_save_pressed() -> void:
	var level := get_parent()
	var ok: bool = level.save_progress() if level and level.has_method("save_progress") else GameData.save_game()
	status_label.text = "Partida guardada" if ok else "Error al guardar"


func _on_main_menu_pressed() -> void:
	# Sale sin guardar: las estrellas tomadas en este intento se descartan.
	GameData.clear_checkpoint()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
