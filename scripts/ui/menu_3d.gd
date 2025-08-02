extends Node3D

@onready var camera_3d: Camera3D = %Camera3D

func hide_menu() -> void:
	camera_3d.current = false
	hide()

func show_menu() -> void:
	camera_3d.current = true
	show()
