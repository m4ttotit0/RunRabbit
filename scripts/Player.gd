extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound

const SPEED = 350.0
const JUMP_VELOCITY = -850.0


func _physics_process(delta: float) -> void:     
	# ANIMACIONES :3
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
	
	# Add the gravity.      
	if not is_on_floor():          
		velocity += get_gravity() * delta   
		animated_sprite_2d.animation = "jumping"   

# Handle jump con la flechita hacia arriba (o Espacio si quieres dejar ambas):
	if Input.is_action_just_pressed("jump") and is_on_floor():          
		velocity.y = JUMP_VELOCITY   
		# AGREGAR SONIDO :3
		jump_sound.play()

	# Get the input direction and handle the movement/deceleration.      
	# As good practice, you should replace UI actions with custom gameplay actions.      
	var direction := Input.get_axis("left", "right")      
	if direction:          
		velocity.x = direction * SPEED      
	else:          velocity.x = move_toward(velocity.x, 0, SPEED)    
  
	move_and_slide()
	
	# DIRECCIONES :3
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
	
	
	
