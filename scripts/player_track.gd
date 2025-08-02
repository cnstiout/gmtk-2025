class_name  PlayerTrack
extends PathFollow3D

var road: Road
@onready var player: Player = %Player
@onready var player_camera: Camera3D = %PlayerCamera

@export var max_health: int = 3
var health: int

@export var starting_speed: float = 10
var moving = false
var current_speed: float:
	set(value):
		current_speed =	value

var boost_amount: float = 1

func _ready() -> void:
	current_speed = starting_speed
	player.road = road
	health = max_health
	Events.boost_picked_up.connect(_on_boost_picked_up)
	Events.wall_hit.connect(_on_wall_hit)

func _input(event: InputEvent) -> void:
	# Cheats
	if event.is_action_pressed("player_up"):
		boost(1)
	if event.is_action_pressed("player_down"):
		boost(-1)

func _process(delta: float) -> void:
	if moving:
		progress += current_speed * delta
		#progress_ratio += current_speed * delta

# Make the player track start moving
func start() -> void:
	player.can_move = true
	moving = true
	player_camera.add_trauma(0.8)

# Make the player track stop moving
func stop() -> void:
	moving = false

# Put the player back at the start
func reset_player() -> void:
	player.reset()
	stop()
	current_speed = starting_speed
	health = max_health
	progress_ratio = 0

# Change your speed, negative number slow you down
func boost(amount:int = 1):
	if amount != 0:
		current_speed += boost_amount * amount
		Events.player_speed_changed.emit(get_converted_speed())
	
func _on_boost_picked_up(_xform: Transform3D):
	boost(1)

func _on_wall_hit():
	take_damage(1)

func take_damage(amount: int) -> void:
	health -= amount
	Events.player_health_changed.emit(-amount)
	if health <= 0:
		die()
	else:
		player.hurt_fx()

func die() -> void:
	stop()
	player.die_fx()
	player.can_move = false
	Events.player_died.emit()

func convert_speed(speed) -> int:
	return floor(speed * 10)

func get_converted_speed() -> int:
	return convert_speed(current_speed)
