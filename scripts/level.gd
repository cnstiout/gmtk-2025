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

var highscore: int = 0:
	set(value):
		highscore = value

func _ready() -> void:
	Events.radar_triggered.connect(_on_radar_triggered)
	Events.player_died.connect(_on_player_died)
	
	player_track = player_track_scene.instantiate()
	player_track.road = road
	player_track.speed_label = hud.speed_label
	road.add_child(player_track)
	
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)


func start_countdown() -> void:
	countdown_timer.start()

func start_run() -> void:
	countdown_label.hide()
	countdown_timer.stop()
	player_track.start()

func restart() -> void:
	road.reset()
	player_track.reset_player()
	current_countdown_time = countdown_start_time
	countdown_label.text = str(current_countdown_time)
	countdown_label.show()
	countdown_timer.start()

func decrease_countdown() -> void:
	if current_countdown_time > 1:
		current_countdown_time -= 1
		countdown_label.text = str(current_countdown_time)
	else:
		start_run()

func _on_player_died() -> void:
	player_track.stop()
	show_gameover()

func show_gameover() -> void:
	hud.show_gameover()

func _on_countdown_timer_timeout() -> void:
	decrease_countdown()

func _on_radar_triggered() -> void:
	road.setup_items()
	update_highscore(player_track.get_converted_speed())

func update_highscore(new_score: int) -> void:
	if new_score > highscore:
		highscore = new_score
		hud.update_highscore(highscore)
