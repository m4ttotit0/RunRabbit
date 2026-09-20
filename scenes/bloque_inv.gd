extends Area2D

# Arrastra desde el editor o asigna los nodos de tu bloque
@export var bloque_sprite: Sprite2D
@export var bloque_colision: CollisionShape2D

var ya_aparecio: bool = false

func _ready() -> void:
	# Conectamos la señal de detección cuando algo entra al área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que tocó el área es el jugador y si no ha aparecido aún
	if body.is_in_group("jugador") and not ya_aparecio:
		ya_aparecio = true
		
		# 1. Hacemos visible la imagen del bloque inmediatamente
		if bloque_sprite:
			bloque_sprite.show()
		
		if bloque_colision:
			bloque_colision.set_deferred("disabled", false)
