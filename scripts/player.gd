class_name Player
extends CharacterBody3D
@onready var model: Node3D = $Model

@export var road: Road:
	set(value):
		road = value
		lane_offset = road.lane_width

@export var max_health: int = 3
var health: int
var change_lane_speed: float = 0.1
var bank_angle_d: float = 30.0
var bank_anim_time: float = 0.1
var bank_anim_rectify_time: float = 0.2

var current_lane: int = 0
var lane_offset: float
var in_movement: bool = false

func _ready() -> void:
	health = max_health
	if road:
		lane_offset = road.lane_width

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_left"):
		change_lane(current_lane - 1)
		
	elif Input.is_action_just_pressed("player_right"):
		change_lane(current_lane + 1)

# Move the player to the specified lane (The middle lane being 0, the most left one being -n and the most right one n)
func change_lane(lane: int) -> void:
	if lane == current_lane || in_movement:
		return
	var move: int = lane - current_lane
	if road._is_valid_lane(lane):
		if move < 0:
			_bank(-1)
		else:
			_bank(1)
		var tween = get_tree().create_tween()
		in_movement = true
		tween.tween_property(self, "position", Vector3(position.x + (lane_offset * move), position.y, position.z), change_lane_speed)
		await tween.finished
		in_movement = false
		current_lane = lane

func take_damage(amount: int) -> void:
	health -=amount
	if health <= 0:
		die()

func die() -> void:
	print("You died")

func _bank(direction: int) -> void:
		var tween = get_tree().create_tween()
		tween.tween_property(model,
			"rotation:z",
			model.rotation.z + deg_to_rad(bank_angle_d) * direction,
			bank_anim_time)
		
		tween.tween_property(model,
			"rotation:z", 
			0,
			bank_anim_rectify_time)
