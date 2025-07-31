class_name Player
extends CharacterBody3D

@export var road: Road

var change_lane_speed: float = 0.1
var current_lane: int = 0
var lane_offset: float
var in_movement: bool = false

func _ready() -> void:
	if road:
		lane_offset = road.lane_width
		print(lane_offset)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_left") && current_lane - 1 >= -(road.nb_lane / floor(2)) && !in_movement:
		var tween = get_tree().create_tween()
		in_movement = true
		tween.tween_property(self, "position", Vector3(position.x - lane_offset, position.y, position.z), change_lane_speed)
		await tween.finished
		in_movement = false
		current_lane -= 1
		
	elif Input.is_action_just_pressed("player_right") && current_lane + 1 <= road.nb_lane / floor(2) && !in_movement:
		var tween = get_tree().create_tween()
		in_movement = true
		tween.tween_property(self, "position", Vector3(position.x + lane_offset, position.y, position.z), change_lane_speed)
		await tween.finished
		in_movement = false
		current_lane += 1
