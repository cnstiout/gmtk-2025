class_name  PlayerTrack
extends PathFollow3D

var road: Road
@onready var player: Player = %Player

@export var max_health: int = 3
var health: int


@export var starting_speed: float = 0.05
var moving = false
var current_speed: float:
	set(value):
		current_speed =	value
		_change_speed_hud(current_speed)
var speed_label: Label
var boost_amount: float = 0.01

func _ready() -> void:
	current_speed = starting_speed
	player.road = road
	health = max_health
	Events.boost_picked_up.connect(_on_boost_picked_up)
	Events.wall_hit.connect(_on_wall_hit)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_up"):
		boost(1)
	if event.is_action_pressed("player_down"):
		boost(-1)

func _process(delta: float) -> void:
	if moving:
		progress_ratio += current_speed * delta

# Make the player track start moving
func start() -> void:
	moving = true

# Make the player track stop moving
func stop() -> void:
	moving = false
	

# Change your speed, negative number slow you down
func boost(amount:int = 1):
	if amount != 0:
		current_speed += boost_amount * amount
		if amount > 0:
			print("Boost!!!")
		else:
			print("Speed down...")
	
func _on_boost_picked_up(_xform: Transform3D):
	boost(1)
	

func _change_speed_hud(value: float) -> void:
	if speed_label:
		speed_label.text = str(get_converted_speed())

func _on_wall_hit():
	take_damage(1)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	Events.player_died.emit()
	print("You died")

func convert_speed(speed) -> int:
	return floor(speed * 1000)

func get_converted_speed() -> int:
	return convert_speed(current_speed)
