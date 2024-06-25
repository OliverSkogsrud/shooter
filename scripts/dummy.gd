extends CharacterBody3D

var health = 40

var blood_splash_pre = load("res://Scenes/blood_splash.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
func _physics_process(delta):
	
	
	
	move_and_slide()


func damage(dmg):
	health -= dmg
	
	if health <= 0:
		var blood_splash = blood_splash_pre.instantiate()
		blood_splash.global_position = global_position
		
		blood_splash.emitting = true
		
		get_parent().add_child(blood_splash)
		
		await get_tree().create_timer(0.1).timeout
		
		queue_free()
	
	print(dmg)
