class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var speed_label: Label = %SpeedLabel
@onready var radar_noise: AudioStreamPlayer = $RadarNoise
@onready var speed_lines: ColorRect = %SpeedLines
@onready var life_animation: AnimationPlayer = $Health/MarginContainer2/HBoxContainer/TextureLife/LifeAnimation

@onready var lives: BoxContainer = %Lives

@export var nb_life_alert: int = 1
var max_health: int 

@export var score_anim_speed: float = 0.5
var current_score: int = 0
@export var speed_anim_speed: float = 0.5
var current_speed: int = 0

@export_group("Speed lines")
@export var speed_lines_max: float = 0.8
@export var speed_lines_min: float = 0.5
@export var speed_lines_in: float = 0.5
@export var speed_lines_out: float = 1.0
@onready var current_speed_lines: float = 0.8



func _ready() -> void:
	Events.player_speed_changed.connect(change_speed_animate)
	Events.new_run_score.connect(change_run_score_animate)
	Events.player_health_changed.connect(change_health)

func reset(starting_speed: int) -> void:
	change_run_score(0)
	change_speed(starting_speed)
	set_health(max_health)
	set_speed_lines(speed_lines_max)
	life_animation.play("RESET")

func change_speed(speed: int) -> void:
	speed_label.text = str(speed)
	current_speed = speed

func change_speed_animate(speed: int) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(change_speed, current_speed, speed, speed_anim_speed).set_trans(Tween.TRANS_EXPO)
	

func change_run_score(score: int) -> void:
	score_label.text = str(round(score))
	current_score = score

func change_run_score_animate(score: int) -> void:
	radar_noise.play()
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(change_run_score, current_score, score, score_anim_speed).set_trans(Tween.TRANS_EXPO)

func set_health(value: int) -> void:
	var lives_array: Array[Node] = lives.get_children()
	if value >= 0 && value <= max_health:
		for i in lives_array.size():
			if i <= value - 1:
				lives_array[i].visible = true
			else:
				lives_array[i].visible = false

func change_health(amount: int) -> void:
	if amount > 0:
		for i in amount:
			add_life()
	elif amount < 0:
		for i in -amount:
			remove_life()

func add_life() -> void:
	var lives_array: Array[Node] = lives.get_children()
	var nb_lives = lives_array.size()
	for i: int in nb_lives:
		if lives_array[i].visible == false:
			lives_array[i].visible = true
			if i > nb_life_alert - 1:
				life_animation.play("RESET")
			return
	#for life: TextureRect in lives.get_children():
		#if life.visible == false:
			#life.visible = true
			#return

func remove_life() -> void:
	var lives_array: Array[Node] = lives.get_children()
	var nb_lives = lives_array.size()
	for i: int in nb_lives:
		if lives_array[i].visible == false && i > 0:
			lives_array[i - 1].visible = false
			if i == nb_life_alert + 1:
				life_animation.play("low_health")
			return
	lives_array[nb_lives - 1].visible = false

func speed_line_animate() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(set_speed_lines, current_speed_lines, speed_lines_min, speed_lines_in).set_trans(Tween.TRANS_QUINT)
	tween.tween_method(set_speed_lines, speed_lines_min, speed_lines_max, speed_lines_out).set_trans(Tween.TRANS_SINE)
	

func set_speed_lines(amount: float) -> void:
	amount = clampf(amount, speed_lines_min, speed_lines_max)
	current_speed_lines = amount
	var speed_lines_shader: ShaderMaterial  = speed_lines.get_material()
	var speed_line_curve: CurveTexture = speed_lines_shader.get_shader_parameter("falloff")
	speed_line_curve.curve.set_point_offset(0, amount)
	speed_lines_shader.set_shader_parameter("falloff",speed_line_curve)
