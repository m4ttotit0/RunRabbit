extends Area2D

@onready var animador: AnimationPlayer = $"../AnimationPlayer"

# IMPORTANTE: para que esto funcione de verdad, en el editor hay que
# arrastrar el nodo "CollisionShape2D2" para que quede como HIJO de
# "Trampa2" (el sprite que cae), en vez de hijo directo de Tramp3.
# Así la forma de colisión viaja con el sprite durante la caída, y
# body_entered solo se dispara cuando el objeto que cae te toca de verdad.

var cayendo: bool = false
var activada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jugador"):
		return

	if not cayendo:
		# Primer contacto: dispara la caída, todavía no mata.
		cayendo = true
		animador.play("Caida")
	elif not activada:
		# Si la forma ya viaja con el sprite, este segundo contacto
		# es un golpe real del objeto que cae.
		activada = true
		get_tree().reload_current_scene()
