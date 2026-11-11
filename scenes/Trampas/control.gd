extends Control

# Arrastra tus imágenes aquí desde el panel FileSystem en el Inspector
@export var imagenes_cinematica: Array[Texture2D] = []
@onready var texture_rect: TextureRect = $TextureRect

var indice_actual: int = 0

func _ready() -> void:
	if imagenes_cinematica.size() > 0:
		texture_rect.texture = imagenes_cinematica[indice_actual]
	else:
		print("¡No hay imágenes asignadas a la cinemática!")

func _input(event: InputEvent) -> void:
	# Avanza al hacer clic izquierdo o presionar la barra espaciadora / Enter
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		siguiente_imagen()

func siguiente_imagen() -> void:
	indice_actual += 1
	
	if indice_actual < imagenes_cinematica.size():
		# Cambia a la siguiente imagen
		texture_rect.texture = imagenes_cinematica[indice_actual]
	else:
		# Cuando se acaben las imágenes, pasa al juego principal
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
