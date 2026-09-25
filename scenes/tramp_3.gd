extends Area2D

@onready var animador: AnimationPlayer = $"../AnimationPlayer"

var cayendo: bool = false
var activada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not (body.name == "Player" or body.is_in_group("jugador")):
		return

	if not cayendo:
		# Primer contacto: solo inicia la animación de caída
		cayendo = true
		print(">>> TRAMP_3: Activada la caída de la animación")
		animador.play("Caida")
	elif not activada:
		# Segundo contacto (si la colisión cae con el bloque y aplasta al jugador)
		activada = true
		print(">>> Reinicio provocado por: TRAMP_3.GD (segundo contacto)")
		get_tree().reload_current_scene()
