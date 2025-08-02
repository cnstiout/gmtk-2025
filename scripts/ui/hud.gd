class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var speed_label: Label = %SpeedLabel
@onready var radar_noise: AudioStreamPlayer = $RadarNoise
@onready var lives: BoxContainer = %Lives

var max_health: int 

@export var score_anim_speed: float = 0.5
var current_score: int = 0
@export var speed_anim_speed: float = 0.5
var current_speed: int = 0

func _ready() -> void:
	Events.player_speed_changed.connect(change_speed_animate)
	Events.new_run_score.connect(change_run_score_animate)
	Events.player_health_changed.connect(change_health)

func reset(starting_speed: int) -> void:
	change_run_score(0)
	change_speed(starting_speed)
	set_health(max_health)

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
	for life: TextureRect in lives.get_children():
		if life.visible == false:
			life.visible = true
			return

func remove_life() -> void:
	var lives_array: Array[Node] = lives.get_children()
	var nb_lives = lives_array.size()
	for i: int in nb_lives:
		if lives_array[i].visible == false && i > 0:
			lives_array[i - 1].visible = false
			return
	lives_array[nb_lives - 1].visible = false
