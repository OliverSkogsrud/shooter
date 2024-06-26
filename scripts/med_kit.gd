extends Area3D

func _on_body_entered(body):
	if body.has_method("heal"):
		body.heal(100)
		queue_free()
