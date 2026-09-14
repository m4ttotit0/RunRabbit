extends CharacterBody2D

## Script básico del jugador: movimiento lateral + salto.
## El "sprite" es por ahora un ColorRect blanco (placeholder).

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Salto (usa la acción integrada de Godot "ui_accept" -> Espacio / Enter)
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or Input.is_key_pressed(KEY_W)) and is_on_floor():
		velocity.y = jump_velocity

	# Movimiento horizontal (usa acciones integradas "ui_left" / "ui_right" -> flechas)
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	move_and_slide()


func reset_to(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
