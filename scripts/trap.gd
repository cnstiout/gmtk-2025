extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	Events.trap_triggered.emit(global_transform)
	queue_free()
