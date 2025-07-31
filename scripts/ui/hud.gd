class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var speed_label: Label = %SpeedLabel

func change_speed(_speed: int) -> void:
	pass

func show_pause() -> void:
	pass

func show_gameover() -> void:
	pass

func update_highscore(_value) -> void:
	pass
