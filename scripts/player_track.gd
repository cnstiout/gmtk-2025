class_name  PlayerTrack
extends PathFollow3D

var road: Road
@onready var player: Player = %Player

@export var max_health: int = 3
var health: int

var moving = false
var speed: float = 0.05:
	set(value):
		speed =	value
		_change_speed_hud(speed)
var speed_label: Label
var boost_amount: float = 0.02

func _ready() -> void:
	player.road = road
	health = max_health
	Events.boost_picked_up.connect(_on_boost_picked_up)
	Events.wall_hit.connect(_on_wall_hit)

func _process(delta: float) -> void:
	if moving:
		progress_ratio += speed * delta

# Make the player track start moving
func start() -> void:
	moving = true

# Make the player track stop moving
func stop() -> void:
	moving = false
	

# Change your speed, negative number slow you down
func boost(amount:int = 1):
	if amount != 0:
		speed += boost_amount * amount
		if amount > 0:
			print("Boost!!!")
		else:
			print("Speed down...")
	
func _on_boost_picked_up(_xform: Transform3D):
	boost(1)
	

func _change_speed_hud(value: float) -> void:
	if speed_label:
		speed_label.text = str(value * 100)

func _on_wall_hit():
	take_damage(1)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	Events.player_died.emit()
	print("You died")
