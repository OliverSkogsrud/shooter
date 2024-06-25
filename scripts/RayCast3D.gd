extends RayCast3D

var damage = 20

func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()
		var colliderShape = get_collider_shape()
		if collider.is_in_group("Player"):
			collider.damage(damage)
			enabled = false
		
