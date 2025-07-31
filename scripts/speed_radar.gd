extends Node3D

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(_body: Node3D) -> void:
	Events.radar_triggered.emit()
