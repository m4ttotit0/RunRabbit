extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
# Busca el CollisionShape2D directo del bloque sólido
@onready var colision_solida: CollisionShape2D = $ColisionSolida if has_node("ColisionSolida") else find_child("*CollisionShape*", false, false)
@onready var sensor_cabeza: Area2D = $SensorCabeza

var revelado: bool = false

func _ready() -> void:
	# Inicia oculto e intangible
	if sprite:
		sprite.visible = false
	if colision_solida:
		colision_solida.set_deferred("disabled", true)
	
	if sensor_cabeza:
		sensor_cabeza.body_entered.connect(_on_sensor_cabeza_body_entered)

func _on_sensor_cabeza_body_entered(body: Node2D) -> void:
	if revelado:
		return

	if body.name == "Player" or body.name == "Player2" or body.is_in_group("jugador"):
		# Solo se activa si el conejo viene subiendo en el salto (velocidad vertical hacia arriba)
		if "velocity" in body and body.velocity.y < 0:
			revelado = true
			
			# 1. Revelar imagen
			if sprite:
				sprite.visible = true
			
			# 2. Volver sólida la colisión
			if colision_solida:
				colision_solida.set_deferred("disabled", false)
			
			# 3. Frenar en seco el impulso hacia arriba para que caiga
			body.velocity.y = 0.0
			
			# Rebote visual clásico estilo Cat Mario
			if sprite:
				var tween = create_tween()
				tween.tween_property(sprite, "position:y", -4.0, 0.05)
				tween.tween_property(sprite, "position:y", 0.0, 0.05)
