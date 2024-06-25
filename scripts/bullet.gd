extends Node3D

@onready var ray = $RayCast3D
@onready var mesh = $MeshInstance3D
@onready var particles = $GPUParticles3D

const speed = 50.0

var damage = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("Enemy"):
			collider.damage(damage)
		
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
		


func _on_timer_timeout():
	queue_free()
