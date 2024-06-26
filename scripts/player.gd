extends CharacterBody3D

var SPEED = 7.0
const JUMP_VELOCITY = 6.0
var SENSETIVITY = 0.01

var can_slide = true
var slide_speed = 0
var falling = false
var fall_distance = 0
var sliding = false


var stamina = 100

var health = 100

var canShoot = true

enum {RUN,SPRINTING, SLIDE}

var state : int = 0

var stamina_regen = false

var dead = false

var bullet = load("res://Scenes/bullet.tscn")

var instance

var gravity_vec = Vector3()

@export var air_acceleration : float = 3
@export var acceleration : float = 12

@onready var gun_barrel = $Neck/Camera3D/hand/Gun/RayCast3D
@onready var gun = $Neck/Camera3D/hand/Gun
@onready var hand = $Neck/Camera3D/hand
@onready var health_bar = $Health_Stamina_bars/HealthBar
@onready var stamina_bar = $Health_Stamina_bars/staminaBar

@onready var slidecheck = $SlideCheck


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
		
		
	#slide
	
	if sliding:
		slide_speed -= 2
	
	if falling and is_on_floor() and sliding:
		slide_speed += fall_distance / 10
	fall_distance = -gravity_vec.y
	
	if Input.is_action_just_pressed("slide") and SPEED > 3:
		can_slide = true
	
	if Input.is_action_pressed("slide") and is_on_floor() and Input.is_action_pressed("w") and can_slide == true:
		slide()
		
	if Input.is_action_just_released("slide"):
		state = RUN
		can_slide = false
		sliding = false
		
	var accel = acceleration if is_on_floor() else air_acceleration
	if sliding:
		accel = 1
	else: accel = 0
	
	if sliding and get_floor_angle() > 0.2:
		accel = 2

	
	health_bar.value = health
	stamina_bar.value = stamina
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	# Add the gravity.
	if not is_on_floor():
		falling = true
		$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Jump")
		velocity.y -= gravity * delta
		SPEED += 0.2
	else:
		falling = false
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if sliding:
			slide_speed -= 1
		rotation.x = 0
		floor_stop_on_slope = false
		velocity.y = JUMP_VELOCITY
	
	
	if Input.is_action_pressed("shoot"):
		shoot_state()
	
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	
	match state:
		RUN: run_state()
		SPRINTING: sprint_state()
	
	move_and_slide()
	
	
func run_state():
	
	if not sliding:
		scale.y = 1
		floor_stop_on_slope = true
	
	SPEED = 7.0
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var speed_tween = get_tree().create_tween()
		speed_tween.tween_property(self, "SPEED", 7.0, 1)
		if !$Neck/Camera3D/hand/Gun/AnimationPlayer.is_playing():
			$Neck/Camera3D/hand/Gun/AnimationPlayer.play("Run")
			
		var runFovTween = get_tree().create_tween()
		runFovTween.tween_property($Neck/Camera3D, "fov", 100, 0.5)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if dead == false:
			var idlefovTween = get_tree().create_tween()
			idlefovTween.tween_property($Neck/Camera3D, "fov", 90, 0.5)
		SPEED = 7.0
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("sprint"):
		state = SPRINTING
		
	if Input.is_action_just_pressed("slide") or Input.is_action_just_pressed("slide2"):
		state = SLIDE
	
		
		
	
func shoot_state():
	if canShoot == true:
		canShoot = false
		
		"""if !is_on_floor():
			$Neck/Camera3D/hand/Gun/AnimationPlayer.current_animation = "shoot"""
		
		$Gunshot.play()
		
		$Neck/Camera3D/hand/Gun/AnimationPlayer.play("shoot")
		$Neck/Camera3D/hand/Gun/GPUParticles3D.emitting = true
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		await get_tree().create_timer(0.15).timeout
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
		SPEED = 7.0
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if Input.is_action_just_released("sprint"):
		state = RUN
		
		await get_tree().create_timer(1).timeout
		stamina_regen = true
		
	if stamina <= 0:
		state = RUN
	
		
		
func damage(dmg):
	health -= dmg
	
	if health <= 0:
		await get_tree().create_timer(0.5)
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/death_screen.tscn")
	
	print(dmg)

func heal(hp):
	health = hp


func _on_stamina_timer_timeout():
	if stamina < 100:
		stamina += 1
		
func slide():
	if not sliding:
		if slidecheck.is_colliding() or get_floor_angle() < 0.2:
			floor_stop_on_slope = false
			scale.y = 0.5
			slide_speed = 5
			slide_speed += fall_distance / 5
		else:
			slide_speed = 2
	
	print(slide_speed)
	
	if slidecheck.is_colliding():
		slide_speed += get_floor_angle() / 10
	else:
		slide_speed -= (get_floor_angle() / 5) + 0.03
		
	if slide_speed >= 30:
		slide_speed = 30
		
	"""var slide_speed_tween = get_tree().create_tween()
	slide_speed_tween.tween_property(self, "slide_speed", 0, 2.0)"""
	
	if slide_speed <= 0:
		can_slide = false
		sliding = false
	SPEED = slide_speed


