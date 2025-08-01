class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var speed_label: Label = %SpeedLabel
@onready var radar_noise: AudioStreamPlayer = $RadarNoise

func _ready() -> void:
	Events.player_speed_changed.connect(change_speed)
	Events.new_run_score.connect(change_run_score)

func reset(starting_speed: int) -> void:
	speed_label.text = str(starting_speed)
	score_label.text = "0"

func change_speed(speed: int) -> void:
	speed_label.text = str(speed)

func change_run_score(score: int) -> void:
	score_label.text = str(score)
	radar_noise.play()
