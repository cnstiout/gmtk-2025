class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var speed_label: Label = %SpeedLabel
@onready var radar_noise: AudioStreamPlayer = $RadarNoise
@onready var lives: BoxContainer = %Lives

func _ready() -> void:
	Events.player_speed_changed.connect(change_speed)
	Events.new_run_score.connect(change_run_score)
	Events.player_health_changed.connect(change_health)

func reset(starting_speed: int) -> void:
	speed_label.text = str(starting_speed)
	score_label.text = "0"

func change_speed(speed: int) -> void:
	speed_label.text = str(speed)

func change_run_score(score: int) -> void:
	score_label.text = str(score)
	radar_noise.play()


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
		print(i)
		if lives_array[i].visible == false && i > 0:
			lives_array[i - 1].visible = false
			return
	lives_array[nb_lives - 1].visible = false
