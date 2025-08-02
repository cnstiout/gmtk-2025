class_name PlayerCamera
extends Camera3D

@export var max_x: float = 10.0
@export var max_y: float = 10.0
@export var max_z: float = 5.0
@export var max_offset: float = 0.2

@export var noise_gen: FastNoiseLite
var gen_seed: int = 0

var default_rotation: Vector3
var default_xform: Transform3D

var shake_time: float = 0
var noise_speed: float = 50
var trauma_reduction_rate: float = 1.0
var trauma: float = 0

var default_fov: float
var current_fov: float
@export var fov_anim_speed: float = 0.2
@export var boost_anim_fov_amount: float = 3.0
@export var boost_anim_time: float = 0.2

func _ready() -> void:
	default_rotation = rotation_degrees
	default_fov = fov
	current_fov = fov

func _process(delta: float) -> void:
	shake_time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	if trauma > 0:
		rotation_degrees.x =  default_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
		rotation_degrees.y =  default_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
		rotation_degrees.z =  default_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

func reset() -> void:
	fov = default_fov

func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(p_seed: int) -> float:
	noise_gen.seed = p_seed
	return noise_gen.get_noise_1d(shake_time * noise_speed)

func change_fov(target_fov: float) -> void:
	fov = target_fov
	current_fov = fov

func change_fov_animate(target_fov: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(change_fov, current_fov, target_fov, fov_anim_speed).set_trans(Tween.TRANS_QUINT)

func animate_boost_fov() -> void:
	var tween: Tween = get_tree().create_tween()
	var starting_fov = current_fov
	tween.tween_property(self, "fov", current_fov + boost_anim_fov_amount, fov_anim_speed).set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "fov", starting_fov, fov_anim_speed).from_current()

func change_effect_speed(speed: int) -> void :
	pass
