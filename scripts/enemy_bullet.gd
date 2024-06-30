extends Node3D

@onready var area = $Area3D
@onready var mesh = $Area3D/MeshInstance3D
@onready var particles = $GPUParticles3D

const speed = 60.0

var damage = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	

func _on_timer_timeout():
	queue_free()



func _on_area_3d_body_entered(body):
	if body.has_method("damage"):
		particles.emitting = true
		get_parent().get_node(body.get_path()).damage(damage)
		#get_tree().create_timer(1.0).timeout
		queue_free()
