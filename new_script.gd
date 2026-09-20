extends Area2D

@onready var animador: AnimationPlayer = $"../AnimationPlayer"

var activada: bool = false

func _on_body_entered(body: Node2D) -> void:
	# Detecta si el nodo que entra pertenece al grupo "jugador"
	if body.is_in_group("jugador") and not activada:
		activada = true
		animador.play("abrir_trampa")
