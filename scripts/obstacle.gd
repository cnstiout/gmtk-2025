extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	Events.wall_hit.emit()
	queue_free()
