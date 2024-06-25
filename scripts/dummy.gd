extends CharacterBody3D

var health = 40

# Get the gravity from the project settings to be synced with RigidBody nodes.
func _physics_process(delta):
	
	
	
	move_and_slide()


func damage(dmg):
	health -= dmg
	
	if health <= 0:
		queue_free()
	
	print(dmg)
