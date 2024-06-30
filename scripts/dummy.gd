extends CharacterBody3D

var health = 20

@onready var ray = $RayCast3D
@onready var barrel = $EnemyGun/Barrel
@onready var shootParticles = $EnemyGun/GPUParticles3D



var instance

var bullet = load("res://Scenes/enemy_bullet.tscn")


var blood_splash_pre = load("res://Scenes/blood_splash.tscn")

var loop = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
func _physics_process(delta):
	
	if loop == true:
		
		
		loop = false
		
		look_at(get_parent_node_3d().get_parent_node_3d().get_node("Player").global_position)
		
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("Player"):
				shootParticles.emitting = true
				instance = bullet.instantiate()
				instance.position = barrel.global_position
				instance.transform.basis = barrel.global_transform.basis
				get_parent().add_child(instance)
		
		
		await get_tree().create_timer(0.2).timeout
		
		loop = true
		
			
	
	
	move_and_slide()


func damage(dmg):
	health -= dmg
	
	if health <= 0:
		var blood_splash = blood_splash_pre.instantiate()
		blood_splash.global_position = global_position
		
		get_parent().add_child(blood_splash)
		
		blood_splash.emitting = true
		
		$AudioStreamPlayer3D.play()
		
		await get_tree().create_timer(0.3).timeout
		
		visible = false
		
		await get_tree().create_timer(0.8).timeout
		
		queue_free()
	
	print(dmg)
