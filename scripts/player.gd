extends CharacterBody3D

var SPEED = 7.0
const JUMP_VELOCITY = 6.0
var SENSETIVITY = 0.01


var stamina = 100

var health = 100

var canShoot = true

enum {RUN, JUMP, SPRINTING}

var state : int = 0

var stamina_regen = false

var bullet = load("res://Scenes/bullet.tscn")

var instance

@onready var gun_barrel = $Neck/Camera3D/hand/Gun/RayCast3D
@onready var gun = $Neck/Camera3D/hand/Gun
@onready var hand = $Neck/Camera3D/hand
@onready var health_bar = $Health_Stamina_bars/HealthBar
@onready var stamina_bar = $Health_Stamina_bars/staminaBar





# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck = $Neck
@onready var camera = $Neck/Camera3D

@onready var cam = $Neck/Camera3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * SENSETIVITY)
		camera.rotate_x(-event.relative.y * SENSETIVITY)
		
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _physics_process(delta):
	#disable/enable camera lock
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if Input.is_action_just_pressed("ui_cancel"):
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				
	if Input.is_action_pressed("ui_down"):
		$"../".exit_game(name.to_int())
		
			
	health_bar.value = health
	stamina_bar.value = stamina
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("shoot"):
		shoot_state()
	
	# Handle jump.


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	
	match state:
		RUN: run_state()
		JUMP: jump_state()
		SPRINTING: sprint_state()
	
	move_and_slide()
	
	
func run_state():
	SPEED = 7.0
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !$Neck/Camera3D/hand/Gun/AnimationPlayer.is_playing():
			$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Run")
			
		var sprintFovTween = get_tree().create_tween()
		sprintFovTween.tween_property($Neck/Camera3D, "fov", 100, 0.5)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		var sprintFovTween = get_tree().create_tween()
		sprintFovTween.tween_property($Neck/Camera3D, "fov", 90, 0.5)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if !is_on_floor():
		$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Jump")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		state = JUMP
		
	if Input.is_action_just_pressed("sprint"):
		state = SPRINTING
		
		
	
func jump_state():
	SPEED = 7.0
	velocity.y = JUMP_VELOCITY
	$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Jump")
	
	if is_on_floor():
		state = RUN
	
func shoot_state():
	if canShoot == true:
		canShoot = false
		
		"""if !is_on_floor():
			$Neck/Camera3D/hand/Gun/AnimationPlayer.current_animation = "shoot"""
		
		$Neck/Camera3D/hand/Gun/AnimationPlayer.play("shoot")
		$Neck/Camera3D/hand/Gun/GPUParticles3D.emitting = true
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		await get_tree().create_timer(0.1).timeout
		canShoot = true
		
func sprint_state():
	SPEED = 9.0
	stamina -= 1
	
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !$Neck/Camera3D/hand/Gun/AnimationPlayer.is_playing():
			$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Run")
		var sprintFovTween = get_tree().create_tween()
		sprintFovTween.tween_property($Neck/Camera3D, "fov", 110, 0.5)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		state = JUMP
		
	if Input.is_action_just_released("sprint"):
		state = RUN
		
		await get_tree().create_timer(1).timeout
		stamina_regen = true
		
	if stamina <= 0:
		state = RUN
	
		
		
func damage(dmg):
	health -= dmg
	
	if health <= 0:
		queue_free()
	
	print(dmg)



func _on_stamina_timer_timeout():
	if stamina < 100:
		stamina += 1
		

