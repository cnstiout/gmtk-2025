class_name Player
extends CharacterBody3D

var moving_speed: float = 0.5
var current_position: int = 0
var lane_offset: float = 0.5

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_left"):
		position.x -= lane_offset
	elif Input.is_action_just_pressed("player_right"):
		position.x += lane_offset
