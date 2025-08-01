# city_generator.gd
@tool
extends Node3D

@export var rows: int = 10
@export var cols: int = 6
@export var spacing: Vector3 = Vector3(4, 0, 6)
@export var height_range: Vector2 = Vector2(2, 10)
@export var building_scene: PackedScene

func _ready():
	if Engine.is_editor_hint():
		regenerate()

func _process(delta):
	if Engine.is_editor_hint():
		# Optionnel : mettre à jour si une propriété change
		pass

func regenerate():
	# nettoyage
	for child in get_children():
		child.queue_free()
	randomize()
	for x in range(cols):
		for z in range(rows):
			var b = building_scene.instantiate()
			var h = randf_range(height_range.x, height_range.y)
			b.scale = Vector3(1, h, 1)
			b.translation = Vector3(
				(x - cols / 2) * spacing.x,
				h * 0.5 + 1.0,
				(z - rows / 2) * spacing.z
			)
			add_child(b)
