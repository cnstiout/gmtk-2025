extends Area3D

func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	Events.boost_picked_up.emit()
	queue_free()
