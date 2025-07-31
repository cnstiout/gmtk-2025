extends Sprite2D

@export var skew_strength: float = 0.4
@export var rotation_smoothness: float = 8.0

var shader_material: ShaderMaterial

func _ready():
	if material is ShaderMaterial:
		shader_material = material as ShaderMaterial
	else:
		push_error("Le Sprite2D doit avoir un ShaderMaterial avec le shader de skew.")
		return
	shader_material.set_shader_parameter("skew_strength", skew_strength)
	shader_material.set_shader_parameter("angle", 0.0)

func _process(delta):
	if not shader_material:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var local_mouse = to_local(mouse_pos)  # conversion correcte en Godot 4

	var center = Vector2.ZERO
	var dir = local_mouse - center
	if dir.length() == 0:
		return
	dir = dir.normalized()
	var target_angle = atan2(dir.y, dir.x)

	var current_angle = shader_material.get_shader_parameter("angle")
	if typeof(current_angle) != TYPE_REAL:
		current_angle = 0.0
	var blended = lerp_angle(current_angle, target_angle, clamp(delta * rotation_smoothness, 0.0, 1.0))

	shader_material.set_shader_parameter("angle", blended)

	# Si tu veux modulation par distance (optionnel) :
	# var dist = (local_mouse - center).length()
	# var max_dist = 200.0
	# var dynamic_strength = clamp(1.0 - (dist / max_dist), 0.0, 1.0) * skew_strength
	# shader_material.set_shader_parameter("skew_strength", dynamic_strength)
