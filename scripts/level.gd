class_name Level
extends Node3D

@export var road: Road
@export var countdown_start_time: int = 3
var current_countdown_time:int = countdown_start_time

@onready var player_track_scene = preload("uid://blwdspsggj7au")
@onready var countdown_timer: Timer = %CountdownTimer
@onready var countdown_label: Label = $HUD/CountdownLabel
@onready var hud: HUD = %HUD

var player_track: PlayerTrack

var run_score: int = 0:
	set(value):
		run_score = value

func _ready() -> void:
	Events.radar_triggered.connect(_on_radar_triggered)
	Events.player_died.connect(_on_player_died)
	
	player_track = player_track_scene.instantiate()
	player_track.road = road
	road.add_child(player_track)
	
	hud.reset(player_track.get_converted_speed())
	
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)

# Start the countdown timer
func start_countdown() -> void:
	countdown_timer.start()

# Start the run
func start_run() -> void:
	countdown_label.hide()
	countdown_timer.stop()
	player_track.start()

# Restart the run
func restart() -> void:
	road.reset()
	run_score = 0
	player_track.reset_player()
	hud.reset(player_track.get_converted_speed())
	
	# Countdown
	current_countdown_time = countdown_start_time
	countdown_label.text = str(current_countdown_time)
	countdown_label.show()
	countdown_timer.start()

# Decrease the countdown
func decrease_countdown() -> void:
	if current_countdown_time > 1:
		current_countdown_time -= 1
		countdown_label.text = str(current_countdown_time)
	else:
		start_run()

func update_run_score(new_score: int) -> void:
	run_score = new_score
	Events.new_run_score.emit(run_score)

func _on_player_died() -> void:
	player_track.stop()

func _on_countdown_timer_timeout() -> void:
	decrease_countdown()

func _on_radar_triggered() -> void:
	road.setup_items()
	update_run_score(player_track.get_converted_speed())
