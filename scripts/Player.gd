extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var particulas_polvo = $CPUParticles2D
var was_on_the_floor = true


const SPEED = 350.0
const JUMP_VELOCITY = -850.0

## 1 = WASD, 2 = flechas.
@export var player_id: int = 1

var _left: Array[String] = []
var _right: Array[String] = []
var _jump: Array[String] = []

func _ready() -> void: #Para que lo reconozcan las trampas
	add_to_group("jugador")
	if player_id == 2:
		_left = ["p2_left"]; _right = ["p2_right"]; _jump = ["p2_jump"]
	elif GameData.two_players:
		_left = ["left"]; _right = ["right"]; _jump = ["jump"]
	else:
		_left = ["left", "p2_left"]; _right = ["right", "p2_right"]; _jump = ["jump", "p2_jump"]

func _pressed(actions: Array[String]) -> bool:
	for a in actions:
		if Input.is_action_pressed(a):
			return true
	return false

func _just_pressed(actions: Array[String]) -> bool:
	for a in actions:
		if Input.is_action_just_pressed(a):
			return true
	return false

func _physics_process(delta: float) -> void:     
	# ANIMACIONES :3
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
	
	if not is_on_floor():          
		velocity += get_gravity() * delta   
		animated_sprite_2d.animation = "jumping"   


	if _just_pressed(_jump) and is_on_floor():          
		velocity.y = JUMP_VELOCITY   
		# AGREGAR SONIDO :3
		jump_sound.play()

	# Get the input direction and handle the movement/deceleration.      
	# As good practice, you should replace UI actions with custom gameplay actions.      
	var direction := float(_pressed(_right)) - float(_pressed(_left))      
	if direction:          
		velocity.x = direction * SPEED      
	else:          velocity.x = move_toward(velocity.x, 0, SPEED)    
  
	move_and_slide()
	var touch_floor_now = is_on_floor() # esta funcion es para agregar particulas de polvo al tocar el suelo :p
	
	if touch_floor_now == true and was_on_the_floor == false:
		particulas_polvo.emitting = true
		
	was_on_the_floor = touch_floor_now
	
	# DIRECCIONES :3
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true
	
	
	
