extends CharacterBody3D
class_name Player

# Movement
@export var move_speed = 7.0
@export var jump_force = 12.0
@export var gravity = 20.0
@export var look_sensitivity = 0.003

# Player state
var is_alive = true
var is_sprinting = false
var health = 100.0
var max_health = 100.0

# Nodes
@onready var camera = $Camera3D
@onready var animation_player = $AnimationPlayer
@onready var sprite_3d = $Sprite3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Player spawned with health: ", health)

func _physics_process(delta):
	if not is_alive:
		return
	
	# Handle input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = move_speed * (1.5 if is_sprinting else 1.0)
	
	# Apply movement
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
	
	# Handle camera look
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * look_sensitivity)
		camera.rotation.z = 0

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func heal(amount: float):
	health = min(health + amount, max_health)

func die():
	is_alive = false
	print("Player died")
	# TODO: Show game over screen
