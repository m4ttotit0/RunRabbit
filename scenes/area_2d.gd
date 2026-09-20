extends Area2D

@onready var animador: AnimationPlayer = $"../AnimationPlayer"

# Evita que se active varias veces
var activada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and not activada:
		activada = true
		animador.play("position")
		await get_tree().create_timer(1).timeout #Para que se vea pue
		get_tree().reload_current_scene()
