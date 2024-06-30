extends Node3D

@onready var mesh = $MeshInstance3D
@onready var particles = $GPUParticles3D

const speed = 60.0

var damage = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	if $RayCast3D.is_colliding():
		var collider = $RayCast3D.get_collider()
		if collider.get_parent().get_node(collider.get_path()).has_method("damage"):
			get_parent().get_node(collider.get_path()).damage(damage)
		else:
			particles.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
		
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
		


func _on_timer_timeout():
	queue_free()
