extends CSGCylinder3D

var speed:float = 0.5

func _process(delta: float) -> void:
	rotate(Vector3.RIGHT, speed * delta)
